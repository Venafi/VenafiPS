# Revoke-TppToken

## SYNOPSIS
Revoke a token

## SYNTAX

### Session (Default)
```
Revoke-TppToken [-TppSession <TppSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### AccessToken
```
Revoke-TppToken -AuthServer <String> -AccessToken <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### TppToken
```
Revoke-TppToken -TppToken <PSObject> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Revoke a token and invalidate the refresh token if provided/available.
This could be an access token retrieved from this module or from other means.

## EXAMPLES

### EXAMPLE 1
```
Revoke-TppToken
```

Revoke token stored in session variable from New-TppSession

### EXAMPLE 2
```
Revoke-TppToken -AuthServer venafi.company.com -AccessToken x7xc8h4387dkgheysk
```

Revoke a token obtained from TPP, not necessarily via VenafiTppPS

## PARAMETERS

### -AuthServer
Server name or URL for the vedauth service

```yaml
Type: String
Parameter Sets: AccessToken
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccessToken
Access token to be revoked

```yaml
Type: String
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

### -TppSession
Session object created from New-TppSession method. 
The value defaults to the script session object $TppSession.

```yaml
Type: TppSession
Parameter Sets: Session
Aliases:

Required: False
Position: Named
Default value: $Script:TppSession
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

### Version
## NOTES

## RELATED LINKS

[http://venafitppps.readthedocs.io/en/latest/functions/Revoke-TppToken/](http://venafitppps.readthedocs.io/en/latest/functions/Revoke-TppToken/)

[https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Revoke-TppToken.ps1](https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Revoke-TppToken.ps1)

[https://docs.venafi.com/Docs/20.1SDK/TopNav/Content/SDK/AuthSDK/r-SDKa-GET-Revoke-Token.php?tocpath=Auth%20SDK%20reference%20for%20token%20management%7C_____13](https://docs.venafi.com/Docs/20.1SDK/TopNav/Content/SDK/AuthSDK/r-SDKa-GET-Revoke-Token.php?tocpath=Auth%20SDK%20reference%20for%20token%20management%7C_____13)

