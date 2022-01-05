# New-VenafiSession

## SYNOPSIS
Create a new Venafi TPP or Venafi as a Service session

## SYNTAX

### KeyIntegrated (Default)
```
New-VenafiSession -Server <String> [-PassThru] [<CommonParameters>]
```

### VaultRefreshToken
```
New-VenafiSession [-Server <String>] [-ClientId <String>] [-Scope <Hashtable>] -VaultRefreshTokenName <String>
 [-VaultMetadata] [-PassThru] [<CommonParameters>]
```

### VaultAccessToken
```
New-VenafiSession [-Server <String>] [-Scope <Hashtable>] -VaultAccessTokenName <String> [-VaultMetadata]
 [-PassThru] [<CommonParameters>]
```

### RefreshToken
```
New-VenafiSession -Server <String> -ClientId <String> -RefreshToken <PSCredential>
 [-VaultRefreshTokenName <String>] [-VaultMetadata] [-AuthServer <String>] [-PassThru] [<CommonParameters>]
```

### AccessToken
```
New-VenafiSession -Server <String> -AccessToken <PSCredential> [-VaultAccessTokenName <String>]
 [-VaultMetadata] [-PassThru] [<CommonParameters>]
```

### TokenCertificate
```
New-VenafiSession -Server <String> -ClientId <String> -Scope <Hashtable> -Certificate <X509Certificate>
 [-VaultAccessTokenName <String>] [-VaultRefreshTokenName <String>] [-VaultMetadata] [-AuthServer <String>]
 [-PassThru] [<CommonParameters>]
```

### TokenIntegrated
```
New-VenafiSession -Server <String> -ClientId <String> -Scope <Hashtable> [-State <String>]
 [-VaultAccessTokenName <String>] [-VaultRefreshTokenName <String>] [-VaultMetadata] [-AuthServer <String>]
 [-PassThru] [<CommonParameters>]
```

### TokenOAuth
```
New-VenafiSession -Server <String> -Credential <PSCredential> -ClientId <String> -Scope <Hashtable>
 [-State <String>] [-VaultAccessTokenName <String>] [-VaultRefreshTokenName <String>] [-VaultMetadata]
 [-AuthServer <String>] [-PassThru] [<CommonParameters>]
```

### KeyCredential
```
New-VenafiSession -Server <String> -Credential <PSCredential> [-PassThru] [<CommonParameters>]
```

### Vaas
```
New-VenafiSession -VaasKey <PSCredential> [-VaultVaasKeyName <String>] [-PassThru] [<CommonParameters>]
```

### VaultVaasKey
```
New-VenafiSession -VaultVaasKeyName <String> [-PassThru] [<CommonParameters>]
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
```

Create key-based session using Windows Integrated authentication

### EXAMPLE 2
```
New-VenafiSession -Server venafitpp.mycompany.com -Credential $cred
```

Create key-based session using Windows Integrated authentication

### EXAMPLE 3
```
New-VenafiSession -Server venafitpp.mycompany.com -ClientId MyApp -Scope @{'certificate'='manage'}
```

Create token-based session using Windows Integrated authentication with a certain scope and privilege restriction

### EXAMPLE 4
```
New-VenafiSession -Server venafitpp.mycompany.com -Certificate $myCert -ClientId MyApp -Scope @{'certificate'='manage'}
```

Create token-based session using a client certificate

### EXAMPLE 5
```
New-VenafiSession -Server venafitpp.mycompany.com -AuthServer tppauth.mycompany.com -ClientId MyApp -Credential $cred
```

Create token-based session using oauth authentication where the vedauth and vedsdk are hosted on different servers

### EXAMPLE 6
```
$sess = New-VenafiSession -Server venafitpp.mycompany.com -Credential $cred -PassThru
```

Create session and return the session object instead of setting to script scope variable

### EXAMPLE 7
```
New-VenafiSession -Server venafitpp.mycompany.com -AccessToken $accessCred
```

Create session using an access token obtained outside this module

### EXAMPLE 8
```
New-VenafiSession -Server venafitpp.mycompany.com -RefreshToken $refreshCred -ClientId MyApp
```

Create session using a refresh token

### EXAMPLE 9
```
New-VenafiSession -Server venafitpp.mycompany.com -RefreshToken $refreshCred -ClientId MyApp -VaultRefreshTokenName TppRefresh
```

Create session using a refresh token and store the newly created refresh token in the vault

### EXAMPLE 10
```
New-VenafiSession -Server venafitpp.mycompany.com -RefreshToken $refreshCred -ClientId MyApp -VaultRefreshTokenName TppRefresh -VaultMetadata
```

Create session using a refresh token, store the newly created refresh token in the vault, and store the server and clientid with the secret

### EXAMPLE 11
```
New-VenafiSession -VaasKey $cred
```

Create session against Venafi as a Service

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
See -VaultMetadata to store server and clientid with the token.

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
See -VaultMetadata to store server and clientid with the token.

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
When a token vault entry, access or refresh, is created with -VaultAccessTokenName or -VaultRefreshTokenName, store the server and clientid with it so this doesn't need to be provided each time.
Once used, the server and clientid will continue to be stored with updated vault entries regardless if -VaultMetadata was provided again.
To clear the metadata, reauthenticate with this function with a credential and without providing -VaultMetadata.
To use this parameter, the SecretManagement vault must support it.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VenafiSession, if -PassThru is provided
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/New-VenafiSession/](http://VenafiPS.readthedocs.io/en/latest/functions/New-VenafiSession/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-VenafiSession.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-VenafiSession.ps1)

[https://docs.venafi.com/Docs/19.4/TopNav/Content/SDK/WebSDK/API_Reference/r-SDK-POST-Authorize.php?tocpath=Topics%20by%20Guide%7CDeveloper%27s%20Guide%7CWeb%20SDK%20reference%7CAuthentication%20programming%20interfaces%7C_____1](https://docs.venafi.com/Docs/19.4/TopNav/Content/SDK/WebSDK/API_Reference/r-SDK-POST-Authorize.php?tocpath=Topics%20by%20Guide%7CDeveloper%27s%20Guide%7CWeb%20SDK%20reference%7CAuthentication%20programming%20interfaces%7C_____1)

[https://docs.venafi.com/Docs/19.4/TopNav/Content/SDK/WebSDK/API_Reference/r-SDK-GET-Authorize-Integrated.php?tocpath=Topics%20by%20Guide%7CDeveloper%27s%20Guide%7CWeb%20SDK%20reference%7CAuthentication%20programming%20interfaces%7C_____3](https://docs.venafi.com/Docs/19.4/TopNav/Content/SDK/WebSDK/API_Reference/r-SDK-GET-Authorize-Integrated.php?tocpath=Topics%20by%20Guide%7CDeveloper%27s%20Guide%7CWeb%20SDK%20reference%7CAuthentication%20programming%20interfaces%7C_____3)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-Authorize-Integrated.php?tocpath=Platform%20SDK%7CAuth%20REST%20for%20token%20management%7C_____10](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-Authorize-Integrated.php?tocpath=Platform%20SDK%7CAuth%20REST%20for%20token%20management%7C_____10)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-AuthorizeOAuth.php?tocpath=Platform%20SDK%7CAuth%20REST%20for%20token%20management%7C_____11](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-AuthorizeOAuth.php?tocpath=Platform%20SDK%7CAuth%20REST%20for%20token%20management%7C_____11)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-AuthorizeCertificate.php?tocpath=Platform%20SDK%7CAuth%20REST%20for%20token%20management%7C_____9](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-AuthorizeCertificate.php?tocpath=Platform%20SDK%7CAuth%20REST%20for%20token%20management%7C_____9)

[https://github.com/PowerShell/SecretManagement](https://github.com/PowerShell/SecretManagement)

[https://github.com/PowerShell/SecretStore](https://github.com/PowerShell/SecretStore)

