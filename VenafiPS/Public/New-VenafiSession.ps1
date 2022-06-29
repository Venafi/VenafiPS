function New-VenafiSession {
    <#
    .SYNOPSIS
    Create a new Venafi TPP or Venafi as a Service session

    .DESCRIPTION
    Authenticate a user and create a new session with which future calls can be made.
    Key based username/password and windows integrated are supported as well as token-based integrated, oauth, and certificate.
    By default, a session variable will be created and automatically used with other functions unless -PassThru is used.
    Tokens and VaaS keys can be saved in a vault for future calls.

    .PARAMETER Server
    Server or url to access vedsdk, venafi.company.com or https://venafi.company.com.
    If AuthServer is not provided, this will be used to access vedauth as well for token-based authentication.
    If just the server name is provided, https:// will be appended.

    .PARAMETER Credential
    Username and password used for key and token-based authentication.  Not required for integrated authentication.

    .PARAMETER ClientId
    Applcation Id configured in Venafi for token-based authentication

    .PARAMETER Scope
    Hashtable with Scopes and privilege restrictions.
    The key is the scope and the value is one or more privilege restrictions separated by commas, @{'certificate'='delete,manage'}.
    Scopes include Agent, Certificate, Code Signing, Configuration, Restricted, Security, SSH, and statistics.
    For no privilege restriction or read access, use a value of $null.
    For a scope to privilege mapping, see https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-OAuthScopePrivilegeMapping.php

    .PARAMETER State
    A session state, redirect URL, or random string to prevent Cross-Site Request Forgery (CSRF) attacks

    .PARAMETER AccessToken
    PSCredential object with the access token as the password.

    .PARAMETER VaultAccessTokenName
    Name of the SecretManagement vault entry for the access token; the name of the vault must be VenafiPS.
    This value can be provided standalone or with credentials.  First time use requires it to be provided with credentials to retrieve the access token to populate the vault.
    With subsequent uses, it can be provided standalone and the access token will be retrieved without the need for credentials.
    See -VaultMetadata to store server and clientid with the token.

    .PARAMETER RefreshToken
    PSCredential object with the refresh token as the password.  An access token will be retrieved and a new session created.

    .PARAMETER VaultRefreshTokenName
    Name of the SecretManagement vault entry for the refresh token; the name of the vault must be VenafiPS.
    This value can be provided standalone or with credentials.  Each time this is used, a new access and refresh token will be obtained.
    First time use requires it to be provided with credentials to retrieve the refresh token and populate the vault.
    With subsequent uses, it can be provided standalone and the refresh token will be retrieved without the need for credentials.
    See -VaultMetadata to store server and clientid with the token.

    .PARAMETER Certificate
    Certificate for token-based authentication

    .PARAMETER AuthServer
    If you host your authentication service, vedauth, is on a separate server than vedsdk, use this parameter to specify the url eg., venafi.company.com or https://venafi.company.com.
    If AuthServer is not provided, the value provided for Server will be used.
    If just the server name is provided, https:// will be appended.

    .PARAMETER VaasKey
    Api key from your Venafi as a Service instance.  The api key can be found under your user profile->preferences.
    Provide a credential object with the api key as the password.
    https://docs.venafi.cloud/DevOpsACCELERATE/API/t-cloud-api-key/

    .PARAMETER VaultVaasKeyName
    Name of the SecretManagement vault entry for the Venafi as a Service key.
    First time use requires it to be provided with -VaasKey to populate the vault.
    With subsequent uses, it can be provided standalone and the key will be retrieved with the need for -VaasKey.

    .PARAMETER VaultMetadata
    When a token vault entry, access or refresh, is created with -VaultAccessTokenName or -VaultRefreshTokenName, store the server and clientid with it so this doesn't need to be provided each time.
    Once used, the server and clientid will continue to be stored with updated vault entries regardless if -VaultMetadata was provided again.
    To clear the metadata, reauthenticate with this function with a credential and without providing -VaultMetadata.
    To use this parameter, the SecretManagement vault must support it.

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
    New-VenafiSession -Server venafitpp.mycompany.com -RefreshToken $refreshCred -ClientId MyApp -VaultRefreshTokenName TppRefresh -VaultMetadata
    Create session using a refresh token, store the newly created refresh token in the vault, and store the server and clientid with the secret

    .EXAMPLE
    New-VenafiSession -VaasKey $cred
    Create session against Venafi as a Service

    .EXAMPLE
    New-VenafiSession -VaultVaasKeyName vaas-key
    Create session against Venafi as a Service with a key stored in a vault

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
    https://github.com/PowerShell/SecretManagement

    .LINK
    https://github.com/PowerShell/SecretStore
    #>

    [CmdletBinding(DefaultParameterSetName = 'KeyIntegrated')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Not needed')]

    param(
        [Parameter(Mandatory, ParameterSetName = 'KeyCredential')]
        [Parameter(Mandatory, ParameterSetName = 'KeyIntegrated')]
        [Parameter(Mandatory, ParameterSetName = 'TokenOAuth')]
        [Parameter(Mandatory, ParameterSetName = 'TokenIntegrated')]
        [Parameter(Mandatory, ParameterSetName = 'TokenCertificate')]
        [Parameter(Mandatory, ParameterSetName = 'AccessToken')]
        [Parameter(Mandatory, ParameterSetName = 'RefreshToken')]
        [Parameter(ParameterSetName = 'VaultAccessToken')]
        [Parameter(ParameterSetName = 'VaultRefreshToken')]
        [ValidateScript( {
                if ( $_ -match '^(https?:\/\/)?(((?!-))(xn--|_{1,1})?[a-z0-9-]{0,61}[a-z0-9]{1,1}\.)*(xn--)?([a-z0-9][a-z0-9\-]{0,60}|[a-z0-9-]{1,30}\.[a-z]{2,})$' ) {
                    $true
                } else {
                    throw "'$_' is not a valid server url, it should look like https://venafi.company.com or venafi.company.com"
                }
            }
        )]
        [Alias('ServerUrl', 'Url')]
        [string] $Server,

        [Parameter(Mandatory, ParameterSetName = 'KeyCredential')]
        [Parameter(Mandatory, ParameterSetName = 'TokenOAuth')]
        [System.Management.Automation.PSCredential] $Credential,

        [Parameter(Mandatory, ParameterSetName = 'TokenIntegrated')]
        [Parameter(Mandatory, ParameterSetName = 'TokenOAuth')]
        [Parameter(Mandatory, ParameterSetName = 'TokenCertificate')]
        [Parameter(ParameterSetName = 'RefreshToken', Mandatory)]
        [Parameter(ParameterSetName = 'VaultRefreshToken')]
        [string] $ClientId,

        [Parameter(Mandatory, ParameterSetName = 'TokenIntegrated')]
        [Parameter(Mandatory, ParameterSetName = 'TokenOAuth')]
        [Parameter(Mandatory, ParameterSetName = 'TokenCertificate')]
        [Parameter(ParameterSetName = 'VaultAccessToken')]
        [Parameter(ParameterSetName = 'VaultRefreshToken')]
        [hashtable] $Scope,

        [Parameter(ParameterSetName = 'TokenIntegrated')]
        [Parameter(ParameterSetName = 'TokenOAuth')]
        [string] $State,

        [Parameter(Mandatory, ParameterSetName = 'AccessToken')]
        [PSCredential] $AccessToken,

        [Parameter(Mandatory, ParameterSetName = 'RefreshToken')]
        [PSCredential] $RefreshToken,

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

        [Parameter(ParameterSetName = 'TokenIntegrated')]
        [Parameter(ParameterSetName = 'TokenOAuth')]
        [Parameter(ParameterSetName = 'TokenCertificate')]
        [Parameter(ParameterSetName = 'AccessToken')]
        [Parameter(ParameterSetName = 'RefreshToken')]
        [Parameter(ParameterSetName = 'VaultAccessToken')]
        [Parameter(ParameterSetName = 'VaultRefreshToken')]
        [switch] $VaultMetadata,

        [Parameter(ParameterSetName = 'TokenOAuth')]
        [Parameter(ParameterSetName = 'TokenIntegrated')]
        [Parameter(ParameterSetName = 'TokenCertificate')]
        [Parameter(ParameterSetName = 'RefreshToken')]
        [ValidateScript( {
                if ( $_ -match '^(https?:\/\/)?(((?!-))(xn--|_{1,1})?[a-z0-9-]{0,61}[a-z0-9]{1,1}\.)*(xn--)?([a-z0-9][a-z0-9\-]{0,60}|[a-z0-9-]{1,30}\.[a-z]{2,})$' ) {
                    $true
                } else {
                    throw 'Please enter a valid server, https://venafi.company.com or venafi.company.com'
                }
            }
        )]
        [string] $AuthServer,

        [Parameter(Mandatory, ParameterSetName = 'Vaas')]
        [ValidateScript( {
                try {
                    [guid] $_.GetNetworkCredential().password
                    $true
                } catch {
                    throw 'The value for -VaasKey is invalid and should be of the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
                }
            }
        )]
        [PSCredential] $VaasKey,

        [Parameter(ParameterSetName = 'Vaas')]
        [Parameter(Mandatory, ParameterSetName = 'VaultVaasKey')]
        [string] $VaultVaasKeyName,

        [Parameter()]
        [switch] $PassThru
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

    # use this to know if we need to re-store vault entry metadata when it already exists and -VaultMetadata not provided
    $metadataStored = $false

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

            Write-Warning 'Key-based authentication will be deprecated in release 21.4 in favor of token-based.  Get started with token authentication today, https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/t-SDKa-Setup-OAuth.php.'

            if ( $PsCmdlet.ParameterSetName -eq 'KeyCredential' ) {
                $newSession.Connect($Credential)
            } else {
                # integrated
                $newSession.Connect($null)
            }

        }

        { $_ -in 'TokenOAuth', 'TokenIntegrated', 'TokenCertificate' } {
            $params = @{
                AuthServer = $authServerUrl
                ClientId   = $ClientId
                Scope      = $Scope
            }

            if ($Credential) {
                $params.Credential = $Credential
            }

            if ($Certificate) {
                $params.Certificate = $Certificate
            }

            if ($State) {
                $params.State = $State
            }

            $token = New-TppToken @params -Verbose:$isVerbose
            $newSession.Token = $token
        }

        'AccessToken' {
            $newSession.Token = [PSCustomObject]@{
                Server      = $authServerUrl
                AccessToken = $AccessToken
                # we don't have the expiry so create one
                # rely on the api call itself to fail if access token is invalid
                Expires     = (Get-Date).AddMonths(12)
            }
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
                }

                $metadataStored = $true
            } else {
                # need to check params as not mandatory
                if ( -not $Server -or -not $ClientId ) {
                    throw '-Server and -ClientId are required parameters as they weren''t stored with -VaultMetadata'
                }

                $newSession.Token = [PSCustomObject]@{
                    Server      = $authServerUrl
                    AccessToken = $tokenSecret
                    Expires     = (Get-Date).AddMonths(12)
                }
                # we don't have the expiry so create one
                # rely on the api call itself to fail if access token is invalid
                # $newSession.Expires = (Get-Date).AddMonths(12)
            }
        }

        'RefreshToken' {
            $params = @{
                AuthServer   = $authServerUrl
                ClientId     = $ClientId
                RefreshToken = $RefreshToken
            }

            $newToken = New-TppToken @params
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
                    AuthServer = $secretInfo.Metadata.AuthServer
                    ClientId   = $secretInfo.Metadata.ClientId
                }

                $metadataStored = $true

            } else {
                # need to check params as not mandatory
                if ( -not $Server -or -not $ClientId ) {
                    throw '-Server and -ClientId are required parameters as they weren''t stored with -VaultMetadata'
                }

                $params = @{
                    AuthServer = $authServerUrl
                    ClientId   = $ClientId
                }
            }

            $params.RefreshToken = $tokenSecret

            $newToken = New-TppToken @params
            $newSession.Token = $newToken
            $newSession.Server = $newToken.Server
            Write-Verbose ('server: {0}' -f $newToken.Server)
        }

        'Vaas' {
            $newSession.Server = $script:CloudUrl
            $newSession.Key = $VaasKey
        }

        'VaultVaasKey' {
            $newSession.Server = $script:CloudUrl
            $keySecret = Get-Secret -Name $VaultVaasKeyName -Vault 'VenafiPS' -ErrorAction SilentlyContinue
            if ( -not $keySecret ) {
                throw "'$VaultVaasKeyName' secret not found in vault VenafiPS."
            }
            $newSession.Key = $keySecret
        }

        Default {
            throw ('Unknown parameter set {0}' -f $PSCmdlet.ParameterSetName)
        }
    }

    if ( $VaultAccessTokenName ) {
        # set new access token in vault
        Set-Secret -Name $VaultAccessTokenName -Secret $newSession.Token.AccessToken -Vault 'VenafiPS'
    }

    if ( $VaultRefreshTokenName ) {
        # set new refresh token in vault
        if ( $newSession.Token.RefreshToken ) {
            Set-Secret -Name $VaultRefreshTokenName -Secret $newSession.Token.RefreshToken -Vault 'VenafiPS'
        } else {
            Write-Warning 'Refresh token not provided by server and will not be saved in the vault'
        }
    }

    if ( $VaultVaasKeyName ) {
        # set new vaas key in vault
        Set-Secret -Name $VaultVaasKeyName -Secret $newSession.Key -Vault 'VenafiPS'
    }

    if ( $VaultMetadata.IsPresent -or $metadataStored ) {
        if ( -not $VaultAccessTokenName -and -not $VaultRefreshTokenName) {
            throw 'Vaulting metadata requires either -VaultAccessTokenName or -VaultRefreshTokenName is provided'
        }
        $metadata = @{
            Server     = $newSession.Server
            AuthServer = $newSession.Token.Server
            ClientId   = $newSession.Token.ClientId
            Expires    = $newSession.Expires
        }

        $metadata | ConvertTo-Json | Write-Verbose

        if ( $VaultAccessTokenName ) {
            Set-SecretInfo -Name $VaultAccessTokenName -Vault 'VenafiPS' -Metadata $metadata
        }

        if ( $VaultRefreshTokenName ) {
            Set-SecretInfo -Name $VaultRefreshTokenName -Vault 'VenafiPS' -Metadata $metadata
        }
    }

    # will fail if user is on an older version.  this isn't required so bypass on failure
    # only applicable to tpp
    if ( $PSCmdlet.ParameterSetName -notin 'Vaas', 'VaultVaasKey' ) {
        $newSession.Version = (Get-TppVersion -VenafiSession $newSession -ErrorAction SilentlyContinue)
        $certFields = 'X509 Certificate', 'Device', 'Application Base' | Get-TppCustomField -VenafiSession $newSession -ErrorAction SilentlyContinue
        # make sure we remove duplicates
        $newSession.CustomField = $certFields.Items | Sort-Object -Property Guid -Unique
    }

    if ( $PassThru ) {
        $newSession
    } else {
        $Script:VenafiSession = $newSession
    }
}
