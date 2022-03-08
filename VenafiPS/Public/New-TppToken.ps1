<#
.SYNOPSIS
Get a new access token or refresh an existing one

.DESCRIPTION
Get an access token and refresh token (if enabled) to be used with New-VenafiSession or other scripts/utilities that take such a token.
You can also refresh an existing access token if you have the associated refresh token.
Authentication can be provided as integrated, credential, or certificate.

.PARAMETER AuthServer
Auth server or url, eg. venafi.company.com

.PARAMETER ClientId
Applcation Id configured in Venafi for token-based authentication

.PARAMETER Scope
Hashtable with Scopes and privilege restrictions.
The key is the scope and the value is one or more privilege restrictions separated by commas.
A privilege restriction of none or read, use a value of $null.
Scopes include Agent, Certificate, Code Signing, Configuration, Restricted, Security, SSH, and statistics.
See https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-OAuthScopePrivilegeMapping.php

.PARAMETER Credential
Username / password credential used to request API Token

.PARAMETER State
A session state, redirect URL, or random string to prevent Cross-Site Request Forgery (CSRF) attacks

.PARAMETER Certificate
Certificate used to request API token.  Certificate authentication must be configured for remote web sdk clients, https://docs.venafi.com/Docs/current/TopNav/Content/CA/t-CA-ConfiguringInTPPandIIS-tpp.php.

.PARAMETER RefreshToken
Provide RefreshToken along with ClientId to obtain a new access and refresh token.  Format should be a pscredential where the password is the refresh token.

.PARAMETER VenafiSession
VenafiSession object created from New-VenafiSession method.

.EXAMPLE
New-TppToken -AuthServer 'https://mytppserver.example.com' -Scope @{ Certificate = "manage,discover"; Configuration = "manage" } -ClientId 'MyAppId' -Credential $credential
Get a new token with OAuth

.EXAMPLE
New-TppToken -AuthServer 'mytppserver.example.com' -Scope @{ Certificate = "manage,discover"; Configuration = "manage" } -ClientId 'MyAppId'
Get a new token with Integrated authentication

.EXAMPLE
New-TppToken -AuthServer 'mytppserver.example.com' -Scope @{ Certificate = "manage,discover"; Configuration = "manage" } -ClientId 'MyAppId' -Certificate $cert
Get a new token with certificate authentication

.EXAMPLE
New-TppToken -AuthServer 'mytppserver.example.com' -ClientId 'MyApp' -RefreshToken $refreshCred
Refresh an existing access token by providing the refresh token directly

.EXAMPLE
New-TppToken -VenafiSession $mySession
Refresh an existing access token by providing a VenafiSession object

.INPUTS
None

.OUTPUTS
PSCustomObject with the following properties:
    Server
    AccessToken
    RefreshToken
    Scope
    Identity
    TokenType
    ClientId
    Expires
    RefreshExpires (This property is null when TPP version is less than 21.1)
#>
function New-TppToken {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Integrated')]
    [OutputType([PSCustomObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Generating cred from api call response data')]
    [OutputType([System.Boolean])]

    param (
        [Parameter(ParameterSetName = 'OAuth', Mandatory)]
        [Parameter(ParameterSetName = 'Integrated', Mandatory)]
        [Parameter(ParameterSetName = 'Certificate', Mandatory)]
        [Parameter(ParameterSetName = 'RefreshToken', Mandatory)]
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

        [Parameter(ParameterSetName = 'OAuth', Mandatory)]
        [Parameter(ParameterSetName = 'Integrated', Mandatory)]
        [Parameter(ParameterSetName = 'Certificate', Mandatory)]
        [Parameter(ParameterSetName = 'RefreshToken', Mandatory)]
        [string] $ClientId,

        [Parameter(ParameterSetName = 'OAuth', Mandatory)]
        [Parameter(ParameterSetName = 'Integrated', Mandatory)]
        [Parameter(ParameterSetName = 'Certificate', Mandatory)]
        [hashtable] $Scope,

        [Parameter(ParameterSetName = 'OAuth', Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,

        [Parameter(ParameterSetName = 'Integrated')]
        [Parameter(ParameterSetName = 'OAuth')]
        [string] $State,

        [Parameter(ParameterSetName = 'Certificate', Mandatory)]
        [X509Certificate] $Certificate,

        [Parameter(ParameterSetName = 'RefreshToken', Mandatory)]
        [pscredential] $RefreshToken,

        [Parameter(ParameterSetName = 'RefreshSession', Mandatory)]
        [ValidateScript( {
                if ( -not $_.Token.RefreshToken ) {
                    throw 'VenafiSession does not have a refresh token.  To get a new access token, create a new session with New-VenafiSession.'
                }

                if ( $_.Token.RefreshExpires -and $_.Token.RefreshExpires -lt (Get-Date) ) {
                    throw "The refresh token has expired.  Retrieve a new access token with New-VenafiSession."
                }

                $true
            })]
        [VenafiSession] $VenafiSession

    )

    $params = @{
        Method  = 'Post'
        UriRoot = 'vedauth'
        Body    = @{}
    }

    if ( $PsCmdlet.ParameterSetName -eq 'RefreshSession' ) {
        $params.Server = $VenafiSession.Token.Server
        $params.UriLeaf = 'authorize/token'
        $params.Body = @{
            client_id     = $VenafiSession.Token.ClientId
            refresh_token = $VenafiSession.Token.RefreshToken.GetNetworkCredential().password
        }

        # workaround for bug pre 21.3 where client id needs to be lowercase
        if ( $VenafiSession.Version -lt [Version]::new('21', '3', '0') ) {
            $params.Body.client_id = $params.Body.client_id.ToLower()
        }
    }
    else {

        $AuthUrl = $AuthServer
        # add prefix if just server url was provided
        if ( $AuthServer -notlike 'https://*') {
            $AuthUrl = 'https://{0}' -f $AuthUrl
        }
        $params.Server = $AuthUrl

        if ( $PsCmdlet.ParameterSetName -eq 'RefreshToken' ) {
            $params.UriLeaf = 'authorize/token'
            $params.Body = @{
                client_id     = $ClientId
                refresh_token = $RefreshToken.GetNetworkCredential().Password
            }
        }
        else {
            # obtain new token
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

            $params.Body = @{
                client_id = $ClientId
                scope     = $scopeString
            }
            $params.UriLeaf = 'authorize/{0}' -f $PSCmdlet.ParameterSetName.ToLower()

            switch ($PsCmdlet.ParameterSetName) {

                'Integrated' {
                    $params.UseDefaultCredentials = $true
                }

                'OAuth' {
                    $params.Body.username = $Credential.UserName
                    $params.Body.password = $Credential.GetNetworkCredential().Password
                }

                'Certificate' {
                    $params.Certificate = $Certificate
                }

                Default {
                    throw ('Unknown parameter set {0}' -f $PSCmdlet.ParameterSetName)
                }
            }

            if ( $State ) {
                $params.Body.state = $State
            }

        }
    }

    if ( $PSCmdlet.ShouldProcess($params.Server, 'New access token') ) {

        if ( $PsCmdlet.ParameterSetName -eq 'RefreshToken' ) {
            try {
                $response = Invoke-VenafiRestMethod @params
            }
            catch {
                # workaround bug pre 21.3 where client_id must be lowercase
                if ( $_ -like '*The client_id value being requested with the refresh token does not match the client_id of the access token making the call*') {
                    $params.Body.client_id = $params.Body.client_id.ToLower()
                    $response = Invoke-VenafiRestMethod @params
                }
                else {
                    throw $_
                }
            }
        }
        else {
            $response = Invoke-VenafiRestMethod @params
        }

        $response | Write-VerboseWithSecret

        $newToken = [PSCustomObject] @{
            Server         = $params.Server
            AccessToken    = New-Object System.Management.Automation.PSCredential('AccessToken', ($response.access_token | ConvertTo-SecureString -AsPlainText -Force))
            RefreshToken   = $null
            Scope          = $Scope
            Identity       = $response.identity
            TokenType      = $response.token_type
            ClientId       = $params.Body.client_id
            Expires        = ([datetime] '1970-01-01 00:00:00').AddSeconds($response.Expires)
            RefreshExpires = $null
        }

        if ( $response.refresh_token ) {
            $newToken.RefreshToken = New-Object System.Management.Automation.PSCredential('RefreshToken', ($response.refresh_token | ConvertTo-SecureString -AsPlainText -Force))
            # refresh_until added in 21.1
            if ($response.refresh_until) {
                $newToken.RefreshExpires = ([datetime] '1970-01-01 00:00:00').AddSeconds($response.refresh_until)
            }
        }

        $newToken
    }

}
