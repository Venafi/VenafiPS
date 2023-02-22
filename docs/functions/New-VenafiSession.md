# New-VenafiSession

## SYNOPSIS
Create a new Venafi TPP or Venafi as a Service session

## SYNTAX

### KeyIntegrated (Default)
```
New-VenafiSession -Server <String> [-PassThru] [-SkipCertificateCheck] [<CommonParameters>]
```

### VaultRefreshToken
```
New-VenafiSession [-Server <String>] [-ClientId <String>] [-Scope <Hashtable>] -VaultRefreshTokenName <String>
 [-VaultMetadata] [-PassThru] [-SkipCertificateCheck] [<CommonParameters>]
```

### VaultAccessToken
```
New-VenafiSession [-Server <String>] [-Scope <Hashtable>] -VaultAccessTokenName <String> [-VaultMetadata]
 [-PassThru] [-SkipCertificateCheck] [<CommonParameters>]
```

### RefreshToken
```
New-VenafiSession -Server <String> -ClientId <String> -RefreshToken <PSCredential>
 [-VaultRefreshTokenName <String>] [-VaultMetadata] [-AuthServer <String>] [-PassThru] [-SkipCertificateCheck]
 [<CommonParameters>]
```

### AccessToken
```
New-VenafiSession -Server <String> -AccessToken <PSCredential> [-VaultAccessTokenName <String>]
 [-VaultMetadata] [-PassThru] [-SkipCertificateCheck] [<CommonParameters>]
```

### TokenCertificate
```
New-VenafiSession -Server <String> -ClientId <String> -Scope <Hashtable> -Certificate <X509Certificate>
 [-VaultAccessTokenName <String>] [-VaultRefreshTokenName <String>] [-VaultMetadata] [-AuthServer <String>]
 [-PassThru] [-SkipCertificateCheck] [<CommonParameters>]
```

### TokenIntegrated
```
New-VenafiSession -Server <String> -ClientId <String> -Scope <Hashtable> [-State <String>]
 [-VaultAccessTokenName <String>] [-VaultRefreshTokenName <String>] [-VaultMetadata] [-AuthServer <String>]
 [-PassThru] [-SkipCertificateCheck] [<CommonParameters>]
```

### TokenOAuth
```
New-VenafiSession -Server <String> -Credential <PSCredential> -ClientId <String> -Scope <Hashtable>
 [-State <String>] [-VaultAccessTokenName <String>] [-VaultRefreshTokenName <String>] [-VaultMetadata]
 [-AuthServer <String>] [-PassThru] [-SkipCertificateCheck] [<CommonParameters>]
```

### KeyCredential
```
New-VenafiSession -Server <String> -Credential <PSCredential> [-PassThru] [-SkipCertificateCheck]
 [<CommonParameters>]
```

### Vaas
```
New-VenafiSession -VaasKey <PSCredential> [-VaultVaasKeyName <String>] [-PassThru] [-SkipCertificateCheck]
 [<CommonParameters>]
```

### VaultVaasKey
```
New-VenafiSession -VaultVaasKeyName <String> [-PassThru] [-SkipCertificateCheck] [<CommonParameters>]
```

## DESCRIPTION
Authenticate a user and create a new session with which future calls can be made.
Key based username/password and windows integrated are supported as well as token-based integrated, oauth, and certificate.
By default, a session variable will be created and automatically used with other functions unless -PassThru is used.
Tokens and VaaS keys can be saved in a vault for future calls.

## EXAMPLES

### EXAMPLE 1
```
New-VenafiSession -Server venafitpp.mycompany.com
Create key-based session using Windows Integrated authentication
```

### EXAMPLE 2
```
New-VenafiSession -Server venafitpp.mycompany.com -Credential $cred
Create key-based session using Windows Integrated authentication
```

### EXAMPLE 3
```
New-VenafiSession -Server venafitpp.mycompany.com -ClientId MyApp -Scope @{'certificate'='manage'}
Create token-based session using Windows Integrated authentication with a certain scope and privilege restriction
```

### EXAMPLE 4
```
New-VenafiSession -Server venafitpp.mycompany.com -Credential $cred -ClientId MyApp -Scope @{'certificate'='manage'}
Create token-based session
```

### EXAMPLE 5
```
New-VenafiSession -Server venafitpp.mycompany.com -Certificate $myCert -ClientId MyApp -Scope @{'certificate'='manage'}
Create token-based session using a client certificate
```

### EXAMPLE 6
```
New-VenafiSession -Server venafitpp.mycompany.com -AuthServer tppauth.mycompany.com -ClientId MyApp -Credential $cred
Create token-based session using oauth authentication where the vedauth and vedsdk are hosted on different servers
```

### EXAMPLE 7
```
$sess = New-VenafiSession -Server venafitpp.mycompany.com -Credential $cred -PassThru
Create session and return the session object instead of setting to script scope variable
```

### EXAMPLE 8
```
New-VenafiSession -Server venafitpp.mycompany.com -AccessToken $accessCred
Create session using an access token obtained outside this module
```

### EXAMPLE 9
```
New-VenafiSession -Server venafitpp.mycompany.com -RefreshToken $refreshCred -ClientId MyApp
Create session using a refresh token
```

### EXAMPLE 10
```
New-VenafiSession -Server venafitpp.mycompany.com -RefreshToken $refreshCred -ClientId MyApp -VaultRefreshTokenName TppRefresh
Create session using a refresh token and store the newly created refresh token in the vault
```

### EXAMPLE 11
```
New-VenafiSession -VaasKey $cred
Create session against Venafi as a Service
```

### EXAMPLE 12
```
New-VenafiSession -VaultVaasKeyName vaas-key
Create session against Venafi as a Service with a key stored in a vault
```

## PARAMETERS

### -Server
Server or url to access vedsdk, venafi.company.com or https://venafi.company.com.
If AuthServer is not provided, this will be used to access vedauth as well for token-based authentication.
If just the server name is provided, https:// will be appended.

```yaml
Type: String
Parameter Sets: KeyIntegrated, RefreshToken, AccessToken, TokenCertificate, TokenIntegrated, TokenOAuth, KeyCredential
Aliases: ServerUrl, Url

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: VaultRefreshToken, VaultAccessToken
Aliases: ServerUrl, Url

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Username and password used for key and token-based authentication. 
Not required for integrated authentication.

```yaml
Type: PSCredential
Parameter Sets: TokenOAuth, KeyCredential
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientId
Applcation Id configured in Venafi for token-based authentication

```yaml
Type: String
Parameter Sets: VaultRefreshToken
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: RefreshToken, TokenCertificate, TokenIntegrated, TokenOAuth
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scope
Hashtable with Scopes and privilege restrictions.
The key is the scope and the value is one or more privilege restrictions separated by commas, @{'certificate'='delete,manage'}.
Scopes include Agent, Certificate, Code Signing, Configuration, Restricted, Security, SSH, and statistics.
For no privilege restriction or read access, use a value of $null.
For a scope to privilege mapping, see https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-OAuthScopePrivilegeMapping.php
Using a scope of {'all'='core'} will set all scopes except for admin.
Using a scope of {'all'='admin'} will set all scopes including admin.
Usage of the 'all' scope is not suggested for production.

```yaml
Type: Hashtable
Parameter Sets: VaultRefreshToken, VaultAccessToken
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: Hashtable
Parameter Sets: TokenCertificate, TokenIntegrated, TokenOAuth
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -State
A session state, redirect URL, or random string to prevent Cross-Site Request Forgery (CSRF) attacks

```yaml
Type: String
Parameter Sets: TokenIntegrated, TokenOAuth
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccessToken
PSCredential object with the access token as the password.

```yaml
Type: PSCredential
Parameter Sets: AccessToken
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RefreshToken
PSCredential object with the refresh token as the password. 
An access token will be retrieved and a new session created.

```yaml
Type: PSCredential
Parameter Sets: RefreshToken
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Certificate
Certificate for token-based authentication

```yaml
Type: X509Certificate
Parameter Sets: TokenCertificate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VaultAccessTokenName
Name of the SecretManagement vault entry for the access token; the name of the vault must be VenafiPS.
This value can be provided standalone or with credentials. 
First time use requires it to be provided with credentials to retrieve the access token to populate the vault.
With subsequent uses, it can be provided standalone and the access token will be retrieved without the need for credentials.

```yaml
Type: String
Parameter Sets: VaultAccessToken
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: AccessToken, TokenCertificate, TokenIntegrated, TokenOAuth
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VaultRefreshTokenName
Name of the SecretManagement vault entry for the refresh token; the name of the vault must be VenafiPS.
This value can be provided standalone or with credentials. 
Each time this is used, a new access and refresh token will be obtained.
First time use requires it to be provided with credentials to retrieve the refresh token and populate the vault.
With subsequent uses, it can be provided standalone and the refresh token will be retrieved without the need for credentials.

```yaml
Type: String
Parameter Sets: VaultRefreshToken
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: RefreshToken, TokenCertificate, TokenIntegrated, TokenOAuth
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VaultMetadata
{{ Fill VaultMetadata Description }}

```yaml
Type: SwitchParameter
Parameter Sets: VaultRefreshToken, VaultAccessToken, RefreshToken, AccessToken, TokenCertificate, TokenIntegrated, TokenOAuth
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AuthServer
If you host your authentication service, vedauth, is on a separate server than vedsdk, use this parameter to specify the url eg., venafi.company.com or https://venafi.company.com.
If AuthServer is not provided, the value provided for Server will be used.
If just the server name is provided, https:// will be appended.

```yaml
Type: String
Parameter Sets: RefreshToken, TokenCertificate, TokenIntegrated, TokenOAuth
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VaasKey
Api key from your Venafi as a Service instance. 
The api key can be found under your user profile-\>preferences.
Provide a credential object with the api key as the password.
https://docs.venafi.cloud/DevOpsACCELERATE/API/t-cloud-api-key/

```yaml
Type: PSCredential
Parameter Sets: Vaas
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VaultVaasKeyName
Name of the SecretManagement vault entry for the Venafi as a Service key.
First time use requires it to be provided with -VaasKey to populate the vault.
With subsequent uses, it can be provided standalone and the key will be retrieved with the need for -VaasKey.

```yaml
Type: String
Parameter Sets: Vaas
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: VaultVaasKey
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Optionally, send the session object to the pipeline instead of script scope.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipCertificateCheck
Bypass certificate validation when connecting to the server.
This can be helpful for pre-prod environments where ssl isn't setup on the website or you are connecting via IP.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VenafiSession, if -PassThru is provided
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/New-VenafiSession/](http://VenafiPS.readthedocs.io/en/latest/functions/New-VenafiSession/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-VenafiSession.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-VenafiSession.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/API_Reference/r-SDK-POST-Authorize.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/API_Reference/r-SDK-POST-Authorize.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/API_Reference/r-SDK-GET-Authorize-Integrated.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/API_Reference/r-SDK-GET-Authorize-Integrated.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-Authorize-Integrated.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-Authorize-Integrated.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-AuthorizeOAuth.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-AuthorizeOAuth.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-AuthorizeCertificate.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-AuthorizeCertificate.php)

[https://github.com/PowerShell/SecretManagement](https://github.com/PowerShell/SecretManagement)

[https://github.com/PowerShell/SecretStore](https://github.com/PowerShell/SecretStore)

