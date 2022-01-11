# Set-TppCredential

## SYNOPSIS
Update credential values

## SYNTAX

```
Set-TppCredential [-Path] <String> [-Value] <Hashtable> [[-VenafiSession] <VenafiSession>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Update values for credential objects in TPP.
The values allowed to be updated are specific to the object type.
See https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Credentials-FriendlyName.php for details.

## EXAMPLES

### EXAMPLE 1
```
Set-TppCredential -Path '\VED\Policy\Password Credential' -Value @{'Password'='my-new-password'}
```

Set a value

## PARAMETERS

### -Path
The full path to the credential object

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Value
Hashtable containing the keys/values to be updated

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VenafiSession
Session object created from New-VenafiSession method. 
The value defaults to the script session object $VenafiSession.

```yaml
Type: VenafiSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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

### Path
## OUTPUTS

### None
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppCredential/](http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppCredential/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Set-TppCredential.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Set-TppCredential.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Credentials-update.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Credentials-update.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Credentials-FriendlyName.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Credentials-FriendlyName.php)

