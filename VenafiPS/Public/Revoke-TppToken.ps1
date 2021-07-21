<#
.SYNOPSIS
Revoke a token

.DESCRIPTION
Revoke a token and invalidate the refresh token if provided/available.
This could be an access token retrieved from this module or from other means.

.PARAMETER AuthServer
Server name or URL for the vedauth service

.PARAMETER AccessToken
Access token to be revoked.  Provide a credential object with the access token as the password.

.PARAMETER TppToken
Token object obtained from New-TppToken

.PARAMETER Force
Bypass the confirmation prompt

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
TppToken

.OUTPUTS
Version

.EXAMPLE
Revoke-TppToken
Revoke token stored in session variable from New-VenafiSession

.EXAMPLE
Revoke-TppToken -Force
Revoke token bypassing confirmation prompt

.EXAMPLE
Revoke-TppToken -AuthServer venafi.company.com -AccessToken $cred
Revoke a token obtained from TPP, not necessarily via VenafiPS

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Revoke-TppToken/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Revoke-TppToken.ps1

.LINK
https://docs.venafi.com/Docs/20.1SDK/TopNav/Content/SDK/AuthSDK/r-SDKa-GET-Revoke-Token.php?tocpath=Auth%20SDK%20reference%20for%20token%20management%7C_____13

#>
function Revoke-TppToken {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'Session')]

    param (
        [Parameter(Mandatory, ParameterSetName = 'AccessToken')]
        [ValidateScript( {
                if ( $_ -match '^(https?:\/\/)?(((?!-))(xn--|_{1,1})?[a-z0-9-]{0,61}[a-z0-9]{1,1}\.)*(xn--)?([a-z0-9][a-z0-9\-]{0,60}|[a-z0-9-]{1,30}\.[a-z]{2,})$' ) {
                    $true
                } else {
                    throw 'Please enter a valid server, https://venafi.company.com or venafi.company.com'
                }
            }
        )]
        [Alias('Server')]
        [string] $AuthServer,

        [Parameter(Mandatory, ParameterSetName = 'AccessToken')]
        [PSCredential] $AccessToken,

        [Parameter(Mandatory, ParameterSetName = 'TppToken', ValueFromPipeline)]
        [pscustomobject] $TppToken,

        [Parameter()]
        [switch] $Force,

        [Parameter(ParameterSetName = 'Session')]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $params = @{
            Method  = 'Get'
            UriRoot = 'vedauth'
            UriLeaf = 'Revoke/Token'
        }
    }

    process {

        Write-Verbose ('Parameter set: {0}' -f $PSCmdlet.ParameterSetName)

        switch ($PsCmdlet.ParameterSetName) {
            'Session' {
                $params.VenafiSession = $VenafiSession
                $target = $VenafiSession.ServerUrl
            }

            'AccessToken' {
                $AuthUrl = $AuthServer
                # add prefix if just server was provided
                if ( $AuthServer -notlike 'https://*') {
                    $AuthUrl = 'https://{0}' -f $AuthUrl
                }

                $params.ServerUrl = $target = $AuthUrl
                $params.Header = @{'Authorization' = 'Bearer {0}' -f $AccessToken }
            }

            'TppToken' {
                if ( -not $TppToken.Server -or -not $TppToken.AccessToken ) {
                    throw 'Not a valid TppToken'
                }

                $params.ServerUrl = $target = $TppToken.Server
                $params.Header = @{'Authorization' = 'Bearer {0}' -f $TppToken.AccessToken.GetNetworkCredential().password }
            }

            Default {
                throw ('Unknown parameter set {0}' -f $PSCmdlet.ParameterSetName)
            }
        }

        Write-Verbose ($params | Out-String)

        if ( $Force ) {
            $ConfirmPreference = 'None'
        }

        if ( $PSCmdlet.ShouldProcess($target) ) {
            Invoke-TppRestMethod @params
        }
    }
}
