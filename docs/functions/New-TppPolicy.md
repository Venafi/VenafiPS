# New-TppPolicy

## SYNOPSIS
Add a new policy folder

## SYNTAX

```
New-TppPolicy [-Path] <String> [[-Description] <String>] [-PassThru] [[-VenafiSession] <VenafiSession>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Add a new policy folder

## EXAMPLES

### EXAMPLE 1
```
$newPolicy = New-TppPolicy -Path '\VED\Policy\Existing Policy Folder\New Policy Folder' -PassThru
```

Create policy returning the policy object created

### EXAMPLE 2
```
New-TppPolicy -Path '\VED\Policy\Existing Policy Folder\New Policy Folder' -Description 'this is awesome'
```

Create policy with description

## PARAMETERS

### -Path
DN path to the new policy

```yaml
Type: String
Parameter Sets: (All)
Aliases: PolicyDN

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Description
Policy description

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Return a TppObject representing the newly created policy.

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

### TppObject, if PassThru provided
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/New-TppPolicy/](http://VenafiPS.readthedocs.io/en/latest/functions/New-TppPolicy/)

[https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/New-TppPolicy.ps1](https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/New-TppPolicy.ps1)

[http://VenafiPS.readthedocs.io/en/latest/functions/New-TppObject/](http://VenafiPS.readthedocs.io/en/latest/functions/New-TppObject/)

[https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/New-TppObject.ps1](https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/New-TppObject.ps1)

