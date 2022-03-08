# New-TppToken

## SYNOPSIS
Get a new access token or refresh an existing one

## SYNTAX

### Integrated (Default)
```
New-TppToken -AuthServer <String> -ClientId <String> -Scope <Hashtable> [-State <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### RefreshToken
```
New-TppToken -AuthServer <String> -ClientId <String> -RefreshToken <PSCredential> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Certificate
```
New-TppToken -AuthServer <String> -ClientId <String> -Scope <Hashtable> -Certificate <X509Certificate>
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### OAuth
```
New-TppToken -AuthServer <String> -ClientId <String> -Scope <Hashtable> -Credential <PSCredential>
 [-State <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### RefreshSession
```
New-TppToken -VenafiSession <VenafiSession> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Get an access token and refresh token (if enabled) to be used with New-VenafiSession or other scripts/utilities that take such a token.
You can also refresh an existing access token if you have the associated refresh token.
Authentication can be provided as integrated, credential, or certificate.

## EXAMPLES

### EXAMPLE 1
```
New-TppToken -AuthServer 'https://mytppserver.example.com' -Scope @{ Certificate = "manage,discover"; Configuration = "manage" } -ClientId 'MyAppId' -Credential $credential
Get a new token with OAuth
```

### EXAMPLE 2
```
New-TppToken -AuthServer 'mytppserver.example.com' -Scope @{ Certificate = "manage,discover"; Configuration = "manage" } -ClientId 'MyAppId'
Get a new token with Integrated authentication
```

### EXAMPLE 3
```
New-TppToken -AuthServer 'mytppserver.example.com' -Scope @{ Certificate = "manage,discover"; Configuration = "manage" } -ClientId 'MyAppId' -Certificate $cert
Get a new token with certificate authentication
```

### EXAMPLE 4
```
New-TppToken -AuthServer 'mytppserver.example.com' -ClientId 'MyApp' -RefreshToken $refreshCred
Refresh an existing access token by providing the refresh token directly
```

### EXAMPLE 5
```
New-TppToken -VenafiSession $mySession
Refresh an existing access token by providing a VenafiSession object
```

## PARAMETERS

### -AuthServer
Auth server or url, eg.
venafi.company.com

```yaml
Type: String
Parameter Sets: Integrated, RefreshToken, Certificate, OAuth
Aliases: Server

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
Parameter Sets: Integrated, RefreshToken, Certificate, OAuth
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scope
Hashtable with Scopes and privilege restrictions.
The key is the scope and the value is one or more privilege restrictions separated by commas.
A privilege restriction of none or read, use a value of $null.
Scopes include Agent, Certificate, Code Signing, Configuration, Restricted, Security, SSH, and statistics.
See https://docs.venafi.com/Docs/current/TopNav/Content/SDK/AuthSDK/r-SDKa-OAuthScopePrivilegeMapping.php

```yaml
Type: Hashtable
Parameter Sets: Integrated, Certificate, OAuth
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Username / password credential used to request API Token

```yaml
Type: PSCredential
Parameter Sets: OAuth
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
Parameter Sets: Integrated, OAuth
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Certificate
Certificate used to request API token. 
Certificate authentication must be configured for remote web sdk clients, https://docs.venafi.com/Docs/current/TopNav/Content/CA/t-CA-ConfiguringInTPPandIIS-tpp.php.

```yaml
Type: X509Certificate
Parameter Sets: Certificate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RefreshToken
Provide RefreshToken along with ClientId to obtain a new access and refresh token. 
Format should be a pscredential where the password is the refresh token.

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

### -VenafiSession
VenafiSession object created from New-VenafiSession method.

```yaml
Type: VenafiSession
Parameter Sets: RefreshSession
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### PSCustomObject with the following properties:
###     Server
###     AccessToken
###     RefreshToken
###     Scope
###     Identity
###     TokenType
###     ClientId
###     Expires
###     RefreshExpires (This property is null when TPP version is less than 21.1)
## NOTES

## RELATED LINKS
