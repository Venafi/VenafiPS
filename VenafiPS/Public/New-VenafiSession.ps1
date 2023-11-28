function New-VenafiSession {
    <#
    .SYNOPSIS
    Create a new Venafi TLSPDC or TLSPC session

    .DESCRIPTION
    Authenticate a user and create a new session with which future calls can be made.
    Key based username/password and windows integrated are supported as well as token-based integrated, oauth, and certificate.
    By default, a session variable will be created and automatically used with other functions unless -PassThru is used.
    Tokens and TLSPC keys can be saved in a vault for future calls.

    .PARAMETER Server
    Server or url to access vedsdk, venafi.company.com or https://venafi.company.com.
    If AuthServer is not provided, this will be used to access vedauth as well for token-based authentication.
    If just the server name is provided, https:// will be appended.

    .PARAMETER Credential
    Username and password used for key and token-based authentication.  Not required for integrated authentication.

    .PARAMETER ClientId
    Application/integration ID configured in Venafi for token-based authentication.
    Case sensitive.

    .PARAMETER Scope
    Hashtable with Scopes and privilege restrictions.
    The key is the scope and the value is one or more privilege restrictions separated by commas, @{'certificate'='delete,manage'}.
    Scopes include Agent, Certificate, Code Signing, Configuration, Restricted, Security, SSH, and statistics.
    For no privilege restriction or read access, use a value of $null.
    For a scope to privilege mapping, see https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-OAuthScopePrivilegeMapping.php
    Using a scope of {'all'='core'} will set all scopes except for admin.
    Using a scope of {'all'='admin'} will set all scopes including admin.
    Usage of the 'all' scope is not suggested for production.

    .PARAMETER State
    A session state, redirect URL, or random string to prevent Cross-Site Request Forgery (CSRF) attacks

    .PARAMETER AccessToken
    Provide an existing access token to create a session.
    You can either provide a String, SecureString, or PSCredential.
    If providing a credential, the username is not used.

    .PARAMETER VaultAccessTokenName
    Name of the SecretManagement vault entry for the access token; the name of the vault must be VenafiPS.
    This value can be provided standalone or with credentials.  First time use requires it to be provided with credentials to retrieve the access token to populate the vault.
    With subsequent uses, it can be provided standalone and the access token will be retrieved without the need for credentials.

    .PARAMETER RefreshToken
    Provide an existing refresh token to create a session.
    You can either provide a String, SecureString, or PSCredential.
    If providing a credential, the username is not used.

    .PARAMETER VaultRefreshTokenName
    Name of the SecretManagement vault entry for the refresh token; the name of the vault must be VenafiPS.
    This value can be provided standalone or with credentials.  Each time this is used, a new access and refresh token will be obtained.
    First time use requires it to be provided with credentials to retrieve the refresh token and populate the vault.
    With subsequent uses, it can be provided standalone and the refresh token will be retrieved without the need for credentials.

    .PARAMETER Jwt
    JSON web token.
    Available in TLSPDC v22.4 and later.
    Ensure jwt mapping has been configured in VCC, Access Management->JWT Mappings.

    .PARAMETER Certificate
    Certificate for token-based authentication

    .PARAMETER AuthServer
    If you host your authentication service, vedauth, is on a separate server than vedsdk, use this parameter to specify the url eg., venafi.company.com or https://venafi.company.com.
    If AuthServer is not provided, the value provided for Server will be used.
    If just the server name is provided, https:// will be appended.

    .PARAMETER VcKey
    Api key from your TLSPC instance.  The api key can be found under your user profile->preferences.
    You can either provide a String, SecureString, or PSCredential.
    If providing a credential, the username is not used.

    .PARAMETER VaultVcKeyName
    Name of the SecretManagement vault entry for the TLSPC key.
    First time use requires it to be provided with -VcKey to populate the vault.
    With subsequent uses, it can be provided standalone and the key will be retrieved without the need for -VcKey.

    .PARAMETER SkipCertificateCheck
    Bypass certificate validation when connecting to the server.
    This can be helpful for pre-prod environments where ssl isn't setup on the website or you are connecting via IP.

    .PARAMETER PassThru
    Optionally, send the session object to the pipeline instead of script scope.

    .OUTPUTS
    VenafiSession, if -PassThru is provided

    .EXAMPLE
    New-VenafiSession -Server venafitpp.mycompany.com
    Create key-based session using Windows Integrated authentication

    .EXAMPLE
    New-VenafiSession -Server venafitpp.mycompany.com -Credential $cred
    Create key-based session using Windows Integrated authentication

    .EXAMPLE
    New-VenafiSession -Server venafitpp.mycompany.com -ClientId MyApp -Scope @{'certificate'='manage'}
    Create token-based session using Windows Integrated authentication with a certain scope and privilege restriction

    .EXAMPLE
    New-VenafiSession -Server venafitpp.mycompany.com -Credential $cred -ClientId MyApp -Scope @{'certificate'='manage'}
    Create token-based session

    .EXAMPLE
    New-VenafiSession -Server venafitpp.mycompany.com -Certificate $myCert -ClientId MyApp -Scope @{'certificate'='manage'}
    Create token-based session using a client certificate

    .EXAMPLE
    New-VenafiSession -Server venafitpp.mycompany.com -AuthServer tppauth.mycompany.com -ClientId MyApp -Credential $cred
    Create token-based session using oauth authentication where the vedauth and vedsdk are hosted on different servers

    .EXAMPLE
    $sess = New-VenafiSession -Server venafitpp.mycompany.com -Credential $cred -PassThru
    Create session and return the session object instead of setting to script scope variable

    .EXAMPLE
    New-VenafiSession -Server venafitpp.mycompany.com -AccessToken $accessCred
    Create session using an access token obtained outside this module

    .EXAMPLE
    New-VenafiSession -Server venafitpp.mycompany.com -RefreshToken $refreshCred -ClientId MyApp
    Create session using a refresh token

    .EXAMPLE
    New-VenafiSession -Server venafitpp.mycompany.com -RefreshToken $refreshCred -ClientId MyApp -VaultRefreshTokenName TppRefresh
    Create session using a refresh token and store the newly created refresh token in the vault

    .EXAMPLE
    New-VenafiSession -VcKey $cred
    Create session against TLSPC

    .EXAMPLE
    New-VenafiSession -VaultVcKeyName vaas-key
    Create session against TLSPC with a key stored in a vault

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/New-VenafiSession/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-VenafiSession.ps1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/API_Reference/r-SDK-POST-Authorize.php

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/API_Reference/r-SDK-GET-Authorize-Integrated.php

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-Authorize-Integrated.php

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-AuthorizeOAuth.php

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-AuthorizeCertificate.php

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-AuthorizeJwt.php

    .LINK
    https://github.com/PowerShell/SecretManagement

    .LINK
    https://github.com/PowerShell/SecretStore
    #>

    [CmdletBinding(DefaultParameterSetName = 'KeyIntegrated')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Not needed')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Converting secret to credential')]

    param(
        [Parameter(Mandatory, ParameterSetName = 'KeyCredential')]
        [Parameter(Mandatory, ParameterSetName = 'KeyIntegrated')]
        [Parameter(Mandatory, ParameterSetName = 'TokenOAuth')]
        [Parameter(Mandatory, ParameterSetName = 'TokenIntegrated')]
        [Parameter(Mandatory, ParameterSetName = 'TokenCertificate')]
        [Parameter(Mandatory, ParameterSetName = 'TokenJwt')]
        [Parameter(Mandatory, ParameterSetName = 'AccessToken')]
        [Parameter(Mandatory, ParameterSetName = 'RefreshToken')]
        [Parameter(ParameterSetName = 'VaultAccessToken')]
        [Parameter(ParameterSetName = 'VaultRefreshToken')]
        [Alias('ServerUrl', 'Url')]
        [string] $Server,

        [Parameter(Mandatory, ParameterSetName = 'KeyCredential')]
        [Parameter(Mandatory, ParameterSetName = 'TokenOAuth')]
        [System.Management.Automation.PSCredential] $Credential,

        [Parameter(Mandatory, ParameterSetName = 'TokenIntegrated')]
        [Parameter(Mandatory, ParameterSetName = 'TokenOAuth')]
        [Parameter(Mandatory, ParameterSetName = 'TokenCertificate')]
        [Parameter(Mandatory, ParameterSetName = 'TokenJwt')]
        [Parameter(ParameterSetName = 'RefreshToken', Mandatory)]
        [Parameter(ParameterSetName = 'VaultRefreshToken')]
        [string] $ClientId,

        [Parameter(Mandatory, ParameterSetName = 'TokenIntegrated')]
        [Parameter(Mandatory, ParameterSetName = 'TokenOAuth')]
        [Parameter(Mandatory, ParameterSetName = 'TokenCertificate')]
        [Parameter(Mandatory, ParameterSetName = 'TokenJwt')]
        [Parameter(ParameterSetName = 'VaultAccessToken')]
        [Parameter(ParameterSetName = 'VaultRefreshToken')]
        [hashtable] $Scope,

        [Parameter(ParameterSetName = 'TokenIntegrated')]
        [Parameter(ParameterSetName = 'TokenOAuth')]
        [string] $State,

        [Parameter(Mandatory, ParameterSetName = 'AccessToken')]
        [psobject] $AccessToken,

        [Parameter(Mandatory, ParameterSetName = 'RefreshToken')]
        [psobject] $RefreshToken,

        [Parameter(Mandatory, ParameterSetName = 'TokenJwt')]
        [string] $Jwt,

        [Parameter(Mandatory, ParameterSetName = 'TokenCertificate')]
        [X509Certificate] $Certificate,

        [Parameter(Mandatory, ParameterSetName = 'VaultAccessToken')]
        [Parameter(ParameterSetName = 'AccessToken')]
        [Parameter(ParameterSetName = 'TokenIntegrated')]
        [Parameter(ParameterSetName = 'TokenOAuth')]
        [Parameter(ParameterSetName = 'TokenCertificate')]
        [string] $VaultAccessTokenName,

        [Parameter(Mandatory, ParameterSetName = 'VaultRefreshToken')]
        [Parameter(ParameterSetName = 'RefreshToken')]
        [Parameter(ParameterSetName = 'TokenIntegrated')]
        [Parameter(ParameterSetName = 'TokenOAuth')]
        [Parameter(ParameterSetName = 'TokenCertificate')]
        [string] $VaultRefreshTokenName,

        [Parameter(ParameterSetName = 'TokenOAuth')]
        [Parameter(ParameterSetName = 'TokenIntegrated')]
        [Parameter(ParameterSetName = 'TokenCertificate')]
        [Parameter(ParameterSetName = 'RefreshToken')]
        [ValidateScript( {
                if ( $_ -match '^(https?:\/\/)?(((?!-))(xn--|_{1,1})?[a-z0-9-]{0,61}[a-z0-9]{1,1}\.)*(xn--)?([a-z0-9][a-z0-9\-]{0,60}|[a-z0-9-]{1,30}\.[a-z]{2,})$' ) {
                    $true
                }
                else {
                    throw 'Please enter a valid server, https://venafi.company.com or venafi.company.com'
                }
            }
        )]
        [string] $AuthServer,

        [Parameter(Mandatory, ParameterSetName = 'Vaas')]
        [Alias('VaasKey')]
        [psobject] $VcKey,

        [Parameter(ParameterSetName = 'Vaas')]
        [Parameter(Mandatory, ParameterSetName = 'VaultVcKey')]
        [Alias('VaultVaasKeyName')]
        [string] $VaultVcKeyName,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [switch] $SkipCertificateCheck
    )

    $isVerbose = if ($PSBoundParameters.Verbose -eq $true) { $true } else { $false }

    $serverUrl = $Server
    # add prefix if just server url was provided
    if ( $Server -notlike 'https://*') {
        $serverUrl = 'https://{0}' -f $serverUrl
    }

    $authServerUrl = $serverUrl
    if ( $AuthServer ) {
        $authServerUrl = $AuthServer
        if ( $authServerUrl -notlike 'https://*') {
            $authServerUrl = 'https://{0}' -f $authServerUrl
        }
    }

    $newSession = [VenafiSession] @{
        Server = $serverUrl
    }

    $newSession | Add-Member @{ 'SkipCertificateCheck' = $SkipCertificateCheck.IsPresent }

    Write-Verbose ('Parameter set: {0}' -f $PSCmdlet.ParameterSetName)

    if ( $PSBoundParameters.Keys -like 'Vault*') {
        # ensure the appropriate setup has been performed
        if ( -not (Get-Module -Name Microsoft.PowerShell.SecretManagement -ListAvailable)) {
            throw 'Vault functionality requires the module Microsoft.PowerShell.SecretManagement as well as a vault named ''VenafiPS''.  See the github readme for guidance, https://github.com/Venafi/VenafiPS#tokenkey-secret-storage.'
        }

        $vault = Get-SecretVault -Name 'VenafiPS' -ErrorAction SilentlyContinue
        if ( -not $vault ) {
            throw 'A SecretManagement vault named ''VenafiPS'' could not be found'
        }
    }

    # if ( $PSCmdlet.ShouldProcess($Server, 'New session') ) {
    Switch ($PsCmdlet.ParameterSetName)	{

        { $_ -in 'KeyCredential', 'KeyIntegrated' } {

            Write-Warning 'Key-based authentication is being deprecated in favor of token-based.  Get started with token authentication today, https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/t-SDKa-Setup-OAuth.php.'

            if ( $PsCmdlet.ParameterSetName -eq 'KeyCredential' ) {
                $newSession.Connect($Credential)
            }
            else {
                # integrated
                $newSession.Connect($null)
            }

        }

        { $_ -in 'TokenOAuth', 'TokenIntegrated', 'TokenCertificate', 'TokenJwt' } {
            $params = @{
                AuthServer           = $authServerUrl
                ClientId             = $ClientId
                Scope                = $Scope
                SkipCertificateCheck = $SkipCertificateCheck
            }

            if ($Credential) {
                $params.Credential = $Credential
            }

            if ($Certificate) {
                $params.Certificate = $Certificate
            }

            if ( $PSBoundParameters.ContainsKey('Jwt') ) {
                $params.Jwt = $Jwt
            }

            if ($State) {
                $params.State = $State
            }

            $token = New-VdcToken @params -Verbose:$isVerbose
            $newSession.Token = $token
        }

        'AccessToken' {
            $newSession.Token = [PSCustomObject]@{
                Server  = $authServerUrl
                # we don't have the expiry so create one
                # rely on the api call itself to fail if access token is invalid
                Expires = (Get-Date).AddMonths(12)
            }
            $newSession.Token.AccessToken = if ( $AccessToken -is [string] ) { New-Object System.Management.Automation.PSCredential('AccessToken', ($AccessToken | ConvertTo-SecureString -AsPlainText -Force)) }
            elseif ($AccessToken -is [pscredential]) { $AccessToken }
            elseif ($AccessToken -is [securestring]) { New-Object System.Management.Automation.PSCredential('AccessToken', $AccessToken) }
            else { throw 'Unsupported type for -AccessToken.  Provide either a String, SecureString, or PSCredential.' }

        }

        'VaultAccessToken' {
            $tokenSecret = Get-Secret -Name $VaultAccessTokenName -Vault 'VenafiPS' -ErrorAction SilentlyContinue
            if ( -not $tokenSecret ) {
                throw "'$VaultAccessTokenName' secret not found in vault VenafiPS."
            }

            # check if metadata was stored or we should get from params
            $secretInfo = Get-SecretInfo -Name $VaultAccessTokenName -Vault 'VenafiPS' -ErrorAction SilentlyContinue

            if ( $secretInfo.Metadata.Count -gt 0 ) {
                $newSession.Server = $secretInfo.Metadata.Server
                $newSession.Expires = $secretInfo.Metadata.Expires
                $newSession.Token = [PSCustomObject]@{
                    Server      = $secretInfo.Metadata.AuthServer
                    AccessToken = $tokenSecret
                    ClientId    = $secretInfo.Metadata.ClientId
                    Scope       = $secretInfo.Metadata.Scope
                }
                $newSession.SkipCertificateCheck = [bool] $secretInfo.Metadata.SkipCertificateCheck
            }
            else {
                throw 'Server and ClientId metadata not found.  Execute New-VenafiSession -Server $server -Credential $cred -ClientId $clientId -Scope $scope -VaultAccessToken $secretName and attempt the operation again.'
            }

        }

        'RefreshToken' {
            $params = @{
                AuthServer = $authServerUrl
                ClientId   = $ClientId
            }
            $params.RefreshToken = if ( $RefreshToken -is [string] ) { New-Object System.Management.Automation.PSCredential('RefreshToken', ($RefreshToken | ConvertTo-SecureString -AsPlainText -Force)) }
            elseif ($RefreshToken -is [pscredential]) { $RefreshToken }
            elseif ($RefreshToken -is [securestring]) { New-Object System.Management.Automation.PSCredential('RefreshToken', $RefreshToken) }
            else { throw 'Unsupported type for -RefreshToken.  Provide either a String, SecureString, or PSCredential.' }

            $newToken = New-VdcToken @params
            $newSession.Token = $newToken
            # $newSession.Expires = $newToken.Expires
        }

        'VaultRefreshToken' {
            $tokenSecret = Get-Secret -Name $VaultRefreshTokenName -Vault 'VenafiPS' -ErrorAction SilentlyContinue
            if ( -not $tokenSecret ) {
                throw "'$VaultRefreshTokenName' secret not found in vault VenafiPS."
            }

            # check if metadata was stored or we should get from params
            $secretInfo = Get-SecretInfo -Name $VaultRefreshTokenName -Vault 'VenafiPS' -ErrorAction SilentlyContinue

            if ( $secretInfo.Metadata.Count -gt 0 ) {
                $params = @{
                    AuthServer           = $secretInfo.Metadata.AuthServer
                    ClientId             = $secretInfo.Metadata.ClientId
                    SkipCertificateCheck = [bool] $secretInfo.Metadata.SkipCertificateCheck
                }
            }
            else {
                throw 'Server and ClientId metadata not found.  Execute New-VenafiSession -Server $server -Credential $cred -ClientId $clientId -Scope $scope -VaultRefreshToken $secretName and attempt the operation again.'
            }

            $params.RefreshToken = $tokenSecret

            $newToken = New-VdcToken @params
            $newSession.Token = $newToken
            $newSession.Server = $newToken.Server
            $newSession.Token.Scope = $secretInfo.Metadata.Scope | ConvertFrom-Json
            $newSession.SkipCertificateCheck = [bool] $secretInfo.Metadata.SkipCertificateCheck
        }

        'Vaas' {
            $newSession.Server = $script:CloudUrl
            $newSession.Key = if ( $VcKey -is [string] ) { $VcKey }
            elseif ($VcKey -is [securestring]) { ConvertFrom-SecureString -SecureString $VcKey -AsPlainText }
            elseif ($VcKey -is [pscredential]) { $VcKey.GetNetworkCredential().Password }
            else { throw 'Unsupported type for -VcKey.  Provide either a String, SecureString, or PSCredential.' }

            if ( $VaultVcKeyName ) {
                Set-Secret -Name $VaultVcKeyName -Secret $newSession.Key -Vault 'VenafiPS'
            }
        }

        'VaultVcKey' {
            $newSession.Server = $script:CloudUrl
            $keySecret = Get-Secret -Name $VaultVcKeyName -Vault 'VenafiPS' -ErrorAction SilentlyContinue
            if ( -not $keySecret ) {
                throw "'$VaultVcKeyName' secret not found in vault VenafiPS."
            }
            $newSession.Key = $keySecret
        }

        Default {
            throw ('Unknown parameter set {0}' -f $PSCmdlet.ParameterSetName)
        }
    }

    if ( $VaultAccessTokenName -or $VaultRefreshTokenName ) {
        $metadata = @{
            Server               = $newSession.Server
            AuthServer           = $newSession.Token.Server
            ClientId             = $newSession.Token.ClientId
            Expires              = $newSession.Expires
            Scope                = $newSession.Token.Scope | ConvertTo-Json -Compress
            SkipCertificateCheck = [int]$newSession.SkipCertificateCheck
        }

        $metadata | ConvertTo-Json | Write-Verbose

        if ( $VaultAccessTokenName ) {
            Set-Secret -Name $VaultAccessTokenName -Secret $newSession.Token.AccessToken -Vault 'VenafiPS' -Metadata $metadata
        }
        else {
            if ( $newSession.Token.RefreshToken ) {
                Set-Secret -Name $VaultRefreshTokenName -Secret $newSession.Token.RefreshToken -Vault 'VenafiPS' -Metadata $metadata
            }
            else {
                Write-Warning 'Refresh token not provided by server and will not be saved in the vault'
            }
        }
    }

    # will fail if user is on an older version.  this isn't required so bypass on failure
    # only applicable to tpp
    if ( $newSession.Platform -eq 'VDC' ) {
        $newSession | Add-Member @{ Version = (Get-VdcVersion -VenafiSession $newSession -ErrorAction SilentlyContinue) }
        $certFields = 'X509 Certificate', 'Device', 'Application Base' | Get-VdcCustomField -VenafiSession $newSession -ErrorAction SilentlyContinue
        # make sure we remove duplicates
        $newSession | Add-Member @{ CustomField = $certFields.Items | Sort-Object -Property Guid -Unique }
    }
    else {

        $newSession | Add-Member @{
            User = (Invoke-VenafiRestMethod -UriLeaf 'useraccounts' -VenafiSession $newSession | Select-Object -ExpandProperty user | Select-Object @{
                    'n' = 'userId'
                    'e' = {
                        $_.Id
                    }
                }, * -ExcludeProperty id)
        }
    }

    if ( $PassThru ) {
        $newSession
    }
    else {
        $Script:VenafiSession = $newSession
    }
}
