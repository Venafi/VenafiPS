<#
.SYNOPSIS
Test if a Tpp token is valid

.DESCRIPTION
Use the TPP API call 'Authorize/Verify' to test if the current token is valid.

.PARAMETER AuthServer
Auth server or url, venafi.company.com or https://venafi.company.com.
If just the server name is provided, https:// will be appended.

.PARAMETER AccessToken
Access token retrieved outside this module.  Provide a credential object with the access token as the password.

.PARAMETER TppToken
Token object obtained from New-TppToken

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.PARAMETER GrantDetail
Provides detailed info about the token object from the TPP server response as an output.  Supported on TPP 20.4 and later.

.INPUTS
AccessToken, TppToken

.OUTPUTS
Boolean (default)
PSCustomObject (GrantDetail)
    ClientId
    AccessIssued
    GrantIssued
    Scope
    Identity
    RefreshExpires

.EXAMPLE
Test-TppToken
Verify that accesstoken stored in $VenafiSession object is valid.

.EXAMPLE
$TppToken | Test-TppToken
Verify that token object from pipeline is valid. Can be used to validate directly object from New-TppToken.

.EXAMPLE
Test-TppToken -AuthServer 'mytppserver.example.com' -AccessToken $cred
Verify that PsCredential object containing accesstoken is valid.

.EXAMPLE
Test-TppToken -GrantDetail
Verify that accesstoken stored in $VenafiSession object is valid and return PsCustomObject as output with details.

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Test-TppToken/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Test-TppToken.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-GET-Authorize-Verify.php

#>
function Test-TppToken {

    [CmdletBinding(DefaultParameterSetName = 'AccessToken')]
    [OutputType([System.Boolean])]

    param (
        [Parameter(Mandatory, ParameterSetName = 'AccessToken')]
        [ValidateScript( {
                if ( $_ -match '^(https?:\/\/)?(((?!-))(xn--|_{1,1})?[a-z0-9-]{0,61}[a-z0-9]{1,1}\.)*(xn--)?([a-z0-9][a-z0-9\-]{0,60}|[a-z0-9-]{1,30}\.[a-z]{2,})$' ) {
                    $true
                }
                else {
                    throw 'Please enter a valid server, https://venafi.company.com or venafi.company.com'
                }
            }
        )]
        [Alias('Server')]
        [string] $AuthServer,

        [Parameter(Mandatory, ParameterSetName = 'AccessToken', ValueFromPipeline)]
        [PSCredential] $AccessToken,

        [Parameter(Mandatory, ParameterSetName = 'TppToken', ValueFromPipeline)]
        [pscustomobject] $TppToken,

        [Parameter()]
        [switch] $GrantDetail,

        [Parameter(ParameterSetName = 'Session')]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $params = @{
            Method  = 'Get'
            UriRoot = 'vedauth'
            UriLeaf = 'Authorize/Verify'
        }
    }

    process {

        Write-Verbose ('Parameter set: {0}' -f $PSCmdlet.ParameterSetName)

        switch ($PsCmdlet.ParameterSetName) {
            'Session' {
                if ( $VenafiSession.Version -lt [Version]::new('20', '3', '0') ) {
                    throw 'Test-TppToken is only supported on version 20.3 and later.'
                }

                if ( $GrantDetail.IsPresent ) {
                    if ( $VenafiSession.Version -lt [Version]::new('20', '4', '0') ) {
                        throw 'Test-TppToken -GrantDetail is only supported on version 20.4 and later.'
                    }
                }

                $params.VenafiSession = $VenafiSession
            }

            'AccessToken' {
                $AuthUrl = $AuthServer
                # add prefix if just server url was provided
                if ( $AuthServer -notlike 'https://*') {
                    $AuthUrl = 'https://{0}' -f $AuthUrl
                }

                $params.Server = $AuthUrl
                $params.Header = @{'Authorization' = 'Bearer {0}' -f $AccessToken.GetNetworkCredential().password }
            }

            'TppToken' {
                if ( -not $TppToken.Server -or -not $TppToken.AccessToken ) {
                    throw 'Not a valid TppToken'
                }

                $params.Server = $TppToken.Server
                $params.Header = @{'Authorization' = 'Bearer {0}' -f $TppToken.AccessToken.GetNetworkCredential().password }
            }

            Default {
                throw ('Unknown parameter set {0}' -f $PSCmdlet.ParameterSetName)
            }
        }

        Write-Verbose ($params | Out-String)

        $response = Invoke-VenafiRestMethod @params -FullResponse

        if ( $GrantDetail.IsPresent ) {

            switch ([int]$response.StatusCode) {

                '200' {
                    $responseData = $response.Content | ConvertFrom-Json
                    [PSCustomObject] @{
                        ClientId       = $responseData.application
                        AccessIssued   = ([datetime] '1970-01-01 00:00:00').AddSeconds($responseData.access_issued_on_unix_time)
                        GrantIssued    = ([datetime] '1970-01-01 00:00:00').AddSeconds($responseData.grant_issued_on_unix_time)
                        Scope          = $responseData.scope
                        Identity       = $responseData.identity
                        RefreshExpires = ([datetime] '1970-01-01 00:00:00').AddSeconds($responseData.expires_unix_time)
                    }
                }

                Default {
                    throw ('Grant has been revoked, has expired, or the refresh token is invalid')
                }
            }

        }
        else {

            switch ([int]$response.StatusCode) {
                '200' {
                    $true
                }

                '401' {
                    $false
                }

                Default {
                    throw ('Grant has been revoked, has expired, or the refresh token is invalid')
                }
            }
        }
    }
}