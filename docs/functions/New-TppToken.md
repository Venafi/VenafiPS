# New-TppToken

## SYNOPSIS
Get an API Access and Refresh Token from TPP

## SYNTAX

### Integrated (Default)
```
New-TppToken -AuthServer <String> -ClientId <String> -Scope <Hashtable> [-State <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### OAuth
```
New-TppToken -AuthServer <String> -ClientId <String> -Scope <Hashtable> -Credential <PSCredential>
 [-State <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Certificate
```
New-TppToken -AuthServer <String> -ClientId <String> -Scope <Hashtable> -Certificate <X509Certificate>
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Get an api access and refresh token to be used with New-VenafiSession or other scripts/utilities that take such a token.
Accepts username/password credential, scope, and ClientId to get a token grant from specified TPP server.

## EXAMPLES

### EXAMPLE 1
```
New-TppToken -AuthServer 'https://mytppserver.example.com' -Scope @{ Certificate = "manage,discover"; Configuration = "manage" } -ClientId 'MyAppId' -Credential $credential
```

Get a new token with OAuth

### EXAMPLE 2
```
New-TppToken -AuthServer 'mytppserver.example.com' -Scope @{ Certificate = "manage,discover"; Configuration = "manage" } -ClientId 'MyAppId'
```

Get a new token with Integrated authentication

### EXAMPLE 3
```
New-TppToken -AuthServer 'mytppserver.example.com' -Scope @{ Certificate = "manage,discover"; Configuration = "manage" } -ClientId 'MyAppId' -Certificate $cert
```

Get a new token with certificate authentication

## PARAMETERS

### -AuthServer
Auth server or url, venafi.company.com or https://venafi.company.com.
If just the server name is provided, https:// will be appended.

```yaml
Type: String
Parameter Sets: (All)
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
Parameter Sets: (All)
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
See https://docs.venafi.com/Docs/20.1/TopNav/Content/SDK/AuthSDK/r-SDKa-OAuthScopePrivilegeMapping.php?tocpath=Topics%20by%20Guide%7CDeveloper%27s%20Guide%7CAuth%20SDK%20reference%20for%20token%20management%7C_____6 for more info.

```yaml
Type: Hashtable
Parameter Sets: (All)
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
{{ Fill State Description }}

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
Certificate used to request API token

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
###     AuthUrl
###     AccessToken
###     RefreshToken
###     Scope
###     Identity
###     TokenType
###     ClientId
###     Expires
## NOTES

## RELATED LINKS
