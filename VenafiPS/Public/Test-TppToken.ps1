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

.INPUTS
Accesstoken

.OUTPUTS
Boolean or PSCustomObject with the following properties:
    AuthUrl
    AccessToken
    RefreshToken
    Scope
    Identity
    TokenType
    ClientId
    Expires

.EXAMPLE
Test-TppToken -AuthServer 'mytppserver.example.com' -AccessToken $cred
Verify that current accesstoken is valid

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Test-TppToken/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Test-TppToken.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/AuthSDK/r-SDKa-GET-Authorize-Verify.php?tocpath=Auth%20SDK%20reference%20for%20token%20management%7C_____13

#>
function Test-TppToken {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
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

        [Parameter(Mandatory)]
        [PSCredential] $AccessToken,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $authType = $VenafiSession.Validate()

        $AuthUrl = $AuthServer
        # add prefix if just server url was provided
        if ( $AuthServer -notlike 'https://*') {
            $AuthUrl = 'https://{0}' -f $AuthUrl
        }

        if ($authType -eq 'token') {
            $hdr = @{'Authorization' = 'Bearer {0}' -f $AccessToken.GetNetworkCredential().password }

            $params = @{
                Method  = 'Get'
                UriRoot = 'vedauth'
                UriLeaf = 'Authorize/Verify'
                ServerUrl = $AuthUrl
                Header = $hdr
            }
        }
    }

    process {

        try {
            if ($authType -eq 'token') {
                $response = Invoke-VenafiRestMethod @params

                [PSCustomObject] @{
                    Server         = $AuthUrl
                    Application    = $response.application
                    AccessIssued   = ([datetime] '1970-01-01 00:00:00').AddSeconds($response.access_issued_on_unix_time)
                    GrantIssued    = ([datetime] '1970-01-01 00:00:00').AddSeconds($response.grant_issued_on_unix_time)
                    Scope          = $response.scope
                    Identity       = $response.identity
                    RefreshExpires = ([datetime] '1970-01-01 00:00:00').AddSeconds($response.expires_unix_time)
                    ValidFor       = $response.valid_for
                }
            } else {
                Write-Error "No oauth token to check"
            }
        } catch {
            if ($PSitem.Exception.Message -match 401) {
                Write-Error $PSitem.Exception.Message
            } else {
                Write-Error "Grant has been revoked, has expired, or the refresh token is invalid"
            }                    
        }
    }
}