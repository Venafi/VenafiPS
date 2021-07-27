# Set-TppAttribute

## SYNOPSIS
Sets a value on an attribute

## SYNTAX

```
Set-TppAttribute [-Path] <String[]> [-Attribute] <Hashtable> [-BypassValidation]
 [[-VenafiSession] <VenafiSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Set a value on an attribute. 
The attribute can either be built-in or custom.

## EXAMPLES

### EXAMPLE 1
```
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com -Attribute @{'My custom field Label'='new custom value'}
```

Set value on custom field

### EXAMPLE 2
```
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com -Attribute @{'DateField'='hi'} -BypassValidation
```

Set value on custom field bypassing field validation

### EXAMPLE 3
```
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com -Attribute @{'Consumers'='\VED\Policy\myappobject.company.com'}
```

Set value on a certificate by overwriting any existing values

## PARAMETERS

### -Path
Path to the object to modify

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: DN

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Attribute
Hashtable with names and values to be set. 
If setting a custom field, you can use either the name or guid as the key.

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

### -BypassValidation
Bypass data validation. 
Only appicable to custom fields.

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

[http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppAttribute/](http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppAttribute/)

[https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Set-TppAttribute.ps1](https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Set-TppAttribute.ps1)

[https://docs.venafi.com/Docs/21.2/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-Set.php?tocpath=Platform%20SDK%7CWeb%20SDK%20REST%7CCertificate%20end%20points%20for%20TLS%7CMetadata%20custom%20fields%20API%7C_____17](https://docs.venafi.com/Docs/21.2/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-Set.php?tocpath=Platform%20SDK%7CWeb%20SDK%20REST%7CCertificate%20end%20points%20for%20TLS%7CMetadata%20custom%20fields%20API%7C_____17)

[https://docs.venafi.com/Docs/21.2/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-write.php?tocpath=Platform%20SDK%7CWeb%20SDK%20REST%7CConfiguration%20end%20points%7CConfig%20API%7C_____36](https://docs.venafi.com/Docs/21.2/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-write.php?tocpath=Platform%20SDK%7CWeb%20SDK%20REST%7CConfiguration%20end%20points%7CConfig%20API%7C_____36)

