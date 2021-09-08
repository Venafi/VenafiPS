# Revoke-TppToken

## SYNOPSIS
Revoke a token

## SYNTAX

### Session (Default)
```
Revoke-TppToken [-Force] [-VenafiSession <VenafiSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### AccessToken
```
Revoke-TppToken -AuthServer <String> -AccessToken <PSCredential> [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### TppToken
```
Revoke-TppToken -TppToken <PSObject> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Revoke a token and invalidate the refresh token if provided/available.
This could be an access token retrieved from this module or from other means.

## EXAMPLES

### EXAMPLE 1
```
Revoke-TppToken
```

Revoke token stored in session variable $VenafiSession from New-VenafiSession

### EXAMPLE 2
```
Revoke-TppToken -Force
```

Revoke token bypassing confirmation prompt

### EXAMPLE 3
```
Revoke-TppToken -AuthServer venafi.company.com -AccessToken $cred
```

Revoke a token obtained from TPP, not necessarily via VenafiPS

## PARAMETERS

### -AuthServer
Server name or URL for the vedauth service

```yaml
Type: String
Parameter Sets: AccessToken
Aliases: Server

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccessToken
Access token to be revoked. 
Provide a credential object with the access token as the password.

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

### -TppToken
Token object obtained from New-TppToken

```yaml
Type: PSObject
Parameter Sets: TppToken
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Force
Bypass the confirmation prompt

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

### -VenafiSession
Session object created from New-VenafiSession method. 
The value defaults to the script session object $VenafiSession.

```yaml
Type: VenafiSession
Parameter Sets: Session
Aliases:

Required: False
Position: Named
Default value: $script:VenafiSession
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

### TppToken
## OUTPUTS

### none
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Revoke-TppToken/](http://VenafiPS.readthedocs.io/en/latest/functions/Revoke-TppToken/)

[https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Public/Revoke-TppToken.ps1](https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Public/Revoke-TppToken.ps1)

[https://docs.venafi.com/Docs/20.1SDK/TopNav/Content/SDK/AuthSDK/r-SDKa-GET-Revoke-Token.php?tocpath=Auth%20SDK%20reference%20for%20token%20management%7C_____13](https://docs.venafi.com/Docs/20.1SDK/TopNav/Content/SDK/AuthSDK/r-SDKa-GET-Revoke-Token.php?tocpath=Auth%20SDK%20reference%20for%20token%20management%7C_____13)

