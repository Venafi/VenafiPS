# Get-VaasOrgUnit

## SYNOPSIS
Get OrgUnit info

## SYNTAX

### All (Default)
```
Get-VaasOrgUnit [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### Id
```
Get-VaasOrgUnit -OrgUnitId <Guid> [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Get info for either a specific org unit or all org units. 
Venafi as a Service only, not for TPP.

## EXAMPLES

### EXAMPLE 1
```
Get-VaasOrgUnit
Get info for all org units
```

### EXAMPLE 2
```
Get-VaasOrgUnit -OrgUnitId 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Get info for a specific org unit
```

## PARAMETERS

### -OrgUnitId
Id to get info for a specific OrgUnit

```yaml
Type: Guid
Parameter Sets: Id
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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
Position: Named
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### OrgUnitId
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS
