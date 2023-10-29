function Revoke-VdcToken {
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

    .PARAMETER VenafiPsToken
    Token object obtained from New-VdcToken

    .PARAMETER Force
    Bypass the confirmation prompt

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token can also be provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    VenafiPsToken

    .OUTPUTS
    none

    .EXAMPLE
    Revoke-VdcToken
    Revoke token stored in session variable $VenafiSession from New-VenafiSession

    .EXAMPLE
    Revoke-VdcToken -Force
    Revoke token bypassing confirmation prompt

    .EXAMPLE
    Revoke-VdcToken -AuthServer venafi.company.com -AccessToken $cred
    Revoke a token obtained from TPP, not necessarily via VenafiPS

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Revoke-VdcToken/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Revoke-VdcToken.ps1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-GET-Revoke-Token.php

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'Session')]
    [Alias('Revoke-TppToken')]

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

        [Parameter(Mandatory, ParameterSetName = 'VenafiPsToken', ValueFromPipeline)]
        [pscustomobject] $VenafiPsToken,

        [Parameter()]
        [switch] $Force,

        [Parameter(ParameterSetName = 'Session')]
        [psobject] $VenafiSession
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
                $target = $VenafiSession.Server
            }

            'AccessToken' {
                $AuthUrl = $AuthServer
                # add prefix if just server was provided
                if ( $AuthServer -notlike 'https://*') {
                    $AuthUrl = 'https://{0}' -f $AuthUrl
                }

                $params.Server = $target = $AuthUrl
                $params.Header = @{'Authorization' = 'Bearer {0}' -f $AccessToken.GetNetworkCredential().Password }
            }

            'VenafiPsToken' {
                if ( -not $VenafiPsToken.Server -or -not $VenafiPsToken.AccessToken ) {
                    throw 'Not a valid VenafiPsToken'
                }

                $params.Server = $target = $VenafiPsToken.Server
                $params.Header = @{'Authorization' = 'Bearer {0}' -f $VenafiPsToken.AccessToken.GetNetworkCredential().password }
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
            Invoke-VenafiRestMethod @params
        }
    }
}
