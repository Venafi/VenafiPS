# Find-VaasMachine

## SYNOPSIS
Find machine info

## SYNTAX

```
Find-VaasMachine [[-MachineType] <String>] [[-Status] <String>] [[-VenafiSession] <PSObject>]
 [<CommonParameters>]
```

## DESCRIPTION
Find machine info based on type and/or status.
Multiple filters will be additive.

## EXAMPLES

### EXAMPLE 1
```
Find-VaasMachine -MachineType 'Citrix ADC'
```

Get machines of a specific type

### EXAMPLE 2
```
Find-VaasMachine -Status 'VERIFIED'
```

Get machines with a specific status

## PARAMETERS

### -MachineType
Machine type to retrieve. 
Use tab-ahead for complete list.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Status
Status of machine, either 'DRAFT', 'VERIFIED', or 'UNVERIFIED'

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

### -VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A VaaS key can also provided.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS
