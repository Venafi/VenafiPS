<#
.SYNOPSIS
Get an API Access and Refresh Token from TPP

.DESCRIPTION
Get an api access and refresh token to be used with New-VenafiSession or other scripts/utilities that take such a token.
Accepts username/password credential, scope, and ClientId to get a token grant from specified TPP server.

.PARAMETER AuthServer
Auth server or url, venafi.company.com or https://venafi.company.com.
If just the server name is provided, https:// will be appended.

.PARAMETER Credential
Username / password credential used to request API Token

.PARAMETER Certificate
Certificate used to request API token

.PARAMETER ClientId
Applcation Id configured in Venafi for token-based authentication

.PARAMETER Scope
Hashtable with Scopes and privilege restrictions.
The key is the scope and the value is one or more privilege restrictions separated by commas.
A privilege restriction of none or read, use a value of $null.
Scopes include Agent, Certificate, Code Signing, Configuration, Restricted, Security, SSH, and statistics.
See https://docs.venafi.com/Docs/20.1/TopNav/Content/SDK/AuthSDK/r-SDKa-OAuthScopePrivilegeMapping.php?tocpath=Topics%20by%20Guide%7CDeveloper%27s%20Guide%7CAuth%20SDK%20reference%20for%20token%20management%7C_____6 for more info.

.EXAMPLE
New-TppToken -AuthServer 'https://mytppserver.example.com' -Scope @{ Certificate = "manage,discover"; Configuration = "manage" } -ClientId 'MyAppId' -Credential $credential
Get a new token with OAuth

.EXAMPLE
New-TppToken -AuthServer 'mytppserver.example.com' -Scope @{ Certificate = "manage,discover"; Configuration = "manage" } -ClientId 'MyAppId'
Get a new token with Integrated authentication

.EXAMPLE
New-TppToken -AuthServer 'mytppserver.example.com' -Scope @{ Certificate = "manage,discover"; Configuration = "manage" } -ClientId 'MyAppId' -Certificate $cert
Get a new token with certificate authentication

.INPUTS
None

.OUTPUTS
PSCustomObject with the following properties:
    AuthUrl
    AccessToken
    RefreshToken
    Scope
    Identity
    TokenType
    ClientId
    Expires
#>
function New-TppToken {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Integrated')]
    [OutputType([PSCustomObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Generating cred from api call response data')]


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
        [string] $ClientId,

        [Parameter(Mandatory)]
        [hashtable] $Scope,

        [Parameter(Mandatory, ParameterSetName = 'OAuth')]
        [System.Management.Automation.PSCredential] $Credential,

        [Parameter(ParameterSetName = 'Integrated')]
        [Parameter(ParameterSetName = 'OAuth')]
        [string] $State,

        [Parameter(Mandatory, ParameterSetName = 'Certificate')]
        [X509Certificate] $Certificate
    )

    $AuthUrl = $AuthServer
    # add prefix if just server url was provided
    if ( $AuthServer -notlike 'https://*') {
        $AuthUrl = 'https://{0}' -f $AuthUrl
    }

    $scopeString = @(
        $scope.GetEnumerator() | ForEach-Object {
            if ($_.Value) {
                '{0}:{1}' -f $_.Key, $_.Value
            }
            else {
                $_.Key
            }
        }
    ) -join ';'

    $params = @{
        Method    = 'Post'
        ServerUrl = $AuthUrl
        UriRoot   = 'vedauth'
        Body      = @{
            client_id = $ClientId
            scope     = $scopeString
        }
    }

    switch ($PsCmdlet.ParameterSetName) {

        'Integrated' {
            $params.UriLeaf = 'authorize/integrated'
            $params.UseDefaultCredentials = $true
        }

        'OAuth' {
            $params.UriLeaf = 'authorize/oauth'
            $params.Body.username = $Credential.UserName
            $params.Body.password = $Credential.GetNetworkCredential().Password
        }

        'Certificate' {
            $params.UriLeaf = 'authorize/certificate'
            $params.Certificate = $Certificate
        }

        Default {
            throw ('Unknown parameter set {0}' -f $PSCmdlet.ParameterSetName)
        }
    }

    if ( $State ) {
        $params.Body.state = $State
    }

    if ( $PSCmdlet.ShouldProcess($AuthUrl, 'New token') ) {

        $response = Invoke-TppRestMethod @params

        $response | Write-VerboseWithSecret

        [PSCustomObject] @{
            Server       = $AuthUrl
            AccessToken  = New-Object System.Management.Automation.PSCredential('AccessToken', ($response.access_token | ConvertTo-SecureString -AsPlainText -Force))
            RefreshToken = New-Object System.Management.Automation.PSCredential('RefreshToken', ($response.refresh_token | ConvertTo-SecureString -AsPlainText -Force))
            Scope        = $response.scope
            Identity     = $response.identity
            TokenType    = $response.token_type
            ClientId     = $ClientId
            Expires      = ([datetime] '1970-01-01 00:00:00').AddSeconds($response.Expires)
        }
    }
}
<#
## Refresh Token

 Write-Verbose ("RefreshUntil: {0}, Current: {1}" -f $this.Token.RefreshUntil, (Get-Date).ToUniversalTime())
                if ( $this.Token.RefreshUntil -and $this.Token.RefreshUntil -lt (Get-Date) ) {
                    throw "The refresh token has expired.  You must create a new session with New-VenafiSession."
                }

                if ( $this.Token.RefreshToken ) {

                    $params = @{
                        Method    = 'Post'
                        AuthServer = $this.AuthServer
                        UriRoot   = 'vedauth'
                        UriLeaf   = 'authorize/token'
                        Body      = @{
                            refresh_token = $this.Token.RefreshToken
                            client_id     = $this.Token.ClientId
                        }
                    }
                    $response = Invoke-TppRestMethod @params

                    Write-Verbose ($response | Out-String)

                    $this.Expires = ([datetime] '1970-01-01 00:00:00').AddSeconds($response.expires)
                    $this.Token = [PSCustomObject]@{
                        AccessToken  = $response.access_token
                        RefreshToken = $response.refresh_token
                        Scope        = $response.scope
                        Identity     = $this.Token.Identity
                        ClientId     = $this.Token.ClientId
                        TokenType    = $response.token_type
                        RefreshUntil = ([datetime] '1970-01-01 00:00:00').AddSeconds($response.refresh_until)
                    }

                } else {
                    throw "The token has expired and no refresh token exists.  You must create a new session with New-VenafiSession."
                }
#>