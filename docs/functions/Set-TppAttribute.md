# Set-TppAttribute

## SYNOPSIS
Adds a value to an attribute

## SYNTAX

```
Set-TppAttribute [-Path] <String[]> [-AttributeName] <String> [-Value] <String[]> [-NoClobber]
 [[-VenafiSession] <VenafiSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Write a value to the object's configuration.
This function will append by default.
Attributes can have multiple values which may not be the intended use.
To ensure you only have one value for an attribute, use the Overwrite switch.

## EXAMPLES

### EXAMPLE 1
```
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com -AttributeName 'My custom field Label' -Value 'new custom value'
```

Set value on custom field.
This will add to any existing value.

### EXAMPLE 2
```
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com -AttributeName 'Consumers' -Value '\VED\Policy\myappobject.company.com' -Overwrite
```

Set value on a certificate by overwriting any existing values

## PARAMETERS

### -Path
{{ Fill Path Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: DN

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AttributeName
Name of the attribute to modify.
If modifying a custom field, use the Label.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value
Value or list of values to write to the attribute.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoClobber
Append existing values as opposed to replacing which is the default

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
Position: 4
Default value: $Script:VenafiSession
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

### PSCustomObject with the following properties:
###     DN = path to object
###     Success = boolean indicating success or failure
###     Error = Error message in case of failure
## NOTES

## RELATED LINKS

[http://venafitppps.readthedocs.io/en/latest/functions/Set-TppAttribute/](http://venafitppps.readthedocs.io/en/latest/functions/Set-TppAttribute/)

[https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Set-TppAttribute.ps1](https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Set-TppAttribute.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-addvalue.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____4](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-addvalue.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____4)

