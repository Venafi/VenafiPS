# Remove-TppObject

## SYNOPSIS
Remove TPP objects

## SYNTAX

```
Remove-TppObject [-Path] <String> [-Recursive] [[-VenafiSession] <PSObject>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Remove a TPP object and optionally perform a recursive removal.
This process can be very destructive as it will remove anything you send it!!!

## EXAMPLES

### EXAMPLE 1
```
Remove-TppObject -Path '\VED\Policy\My empty folder'
Remove an object
```

### EXAMPLE 2
```
Remove-TppObject -Path '\VED\Policy\folder' -Recursive
Remove an object and all objects contained
```

### EXAMPLE 3
```
Find-TppObject -Class 'capi' | Remove-TppObject
Find 1 or more objects and remove them
```

### EXAMPLE 4
```
Remove-TppObject -Path '\VED\Policy\folder' -Confirm:$false
Remove an object without prompting for confirmation.  Be careful!
```

## PARAMETERS

### -Path
Full path to an existing object

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Recursive
Remove recursively, eg.
everything within a policy folder

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
A TPP token can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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

[http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppObject/](http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppObject/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppObject.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppObject.ps1)

[https://docs.venafi.com/Docs/currentSDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-delete.php](https://docs.venafi.com/Docs/currentSDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-delete.php)

