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
Provides detailed info about the token object from the TPP server response as an output.
PSCustomObject with the following properties:
    AuthUrl
    AccessToken
    RefreshToken
    Scope
    Identity
    TokenType
    ClientId
    Expires

.INPUTS
Accesstoken

.OUTPUTS
Boolean (default). PSCustomObject (GrantDetail). Throws error if a 400 status is returned.

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
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Public/Test-TppToken.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/AuthSDK/r-SDKa-GET-Authorize-Verify.php?tocpath=Auth%20SDK%20reference%20for%20token%20management%7C_____13

#>
function Test-TppToken {

    [CmdletBinding(DefaultParameterSetName = 'Session')]
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
                $params.VenafiSession = $VenafiSession
            }

            'AccessToken' {
                $AuthUrl = $AuthServer
            # add prefix if just server url was provided
                if ( $AuthServer -notlike 'https://*') {
                    $AuthUrl = 'https://{0}' -f $AuthUrl
                }

                $params.ServerUrl = $AuthUrl
                $params.Header = @{'Authorization' = 'Bearer {0}' -f $AccessToken.GetNetworkCredential().password }
            }

            'TppToken' {
                if ( -not $TppToken.Server -or -not $TppToken.AccessToken ) {
                    throw 'Not a valid TppToken'
                }

                $params.ServerUrl = $TppToken.Server
                $params.Header = @{'Authorization' = 'Bearer {0}' -f $TppToken.AccessToken.GetNetworkCredential().password }
            }

            Default {
                throw ('Unknown parameter set {0}' -f $PSCmdlet.ParameterSetName)
            }
        }

        Write-Verbose ($params | Out-String)

        if ($GrantDetail) {
            $response = Invoke-VenafiRestMethod @params -FullResponse

            switch ([int]$response.StatusCode) {
                '200' {
                    [PSCustomObject] @{
                        Application    = $response.application
                        AccessIssued   = ([datetime] '1970-01-01 00:00:00').AddSeconds($response.access_issued_on_unix_time)
                        GrantIssued    = ([datetime] '1970-01-01 00:00:00').AddSeconds($response.grant_issued_on_unix_time)
                        Scope          = $response.scope
                        Identity       = $response.identity
                        RefreshExpires = ([datetime] '1970-01-01 00:00:00').AddSeconds($response.expires_unix_time)
                        ValidFor       = $response.valid_for
                    }
                }

                Default {
                    throw ('Grant has been revoked, has expired, or the refresh token is invalid')
                }
            }

        } else {
            $response = Invoke-VenafiRestMethod @params -FullResponse

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