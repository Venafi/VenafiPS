# Convert-TppObject

## SYNOPSIS
Change the class/object type of an existing object

## SYNTAX

```
Convert-TppObject [-Path] <String> [-Class] <String> [-PassThru] [[-VenafiSession] <PSObject>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Change the class/object type of an existing object.
Please note, changing the class does NOT change any attributes and must be done separately.
Using -PassThru will allow you to pass the input to other functions including Set-TppAttribute; see the examples.

## EXAMPLES

### EXAMPLE 1
```
Convert-TppObject -Path '\ved\policy\' -Class 'X509 Device Certificate'
Convert an object to a different type
```

### EXAMPLE 2
```
Convert-TppObject -Path '\ved\policy\device\app' -Class 'CAPI' -PassThru | Set-TppAttribute -Attribute @{'Driver Name'='appcapi'}
Convert an object to a different type, return the updated object and update attributes
```

### EXAMPLE 3
```
Find-TppObject -Class Basic | Convert-TppObject -Class 'capi' -PassThru | Set-TppAttribute -Attribute @{'Driver Name'='appcapi'}
Convert multiple objects to a different type, return the updated objects and update attributes
```

## PARAMETERS

### -Path
Path to the object

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

### -Class
New class/type

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

### -PassThru
Return a TppObject representing the newly converted object

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
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TppServer must also be set.

```yaml
Type: PSObject
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

### TppObject, if -PassThru provided
## NOTES

## RELATED LINKS

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Convert-TppObject.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Convert-TppObject.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-mutateobject.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-mutateobject.php)

