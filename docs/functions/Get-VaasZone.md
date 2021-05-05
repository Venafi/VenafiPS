# Get-VaasZone

## SYNOPSIS
Get certificate information

## SYNTAX

### All (Default)
```
Get-VaasZone [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### Id
```
Get-VaasZone -ZoneId <Guid> [-DevOps] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Get certificate information, either all available to the api key provided or by id or zone.

## EXAMPLES

### EXAMPLE 1
```
Get-VaasCertificate
```

Get certificate info for all certs

### EXAMPLE 2
```
Get-VaasCertificate -Id 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
```

Get certificate info for a specific cert

### EXAMPLE 3
```
Get-VaasCertificate -ZoneId 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
```

Get certificate info for all certs within a specific zone

## PARAMETERS

### -ZoneId
Get certificate information for all within a specific zone

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

### -DevOps
{{ Fill DevOps Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Id
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
Position: Named
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Id
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-VaasCertificate/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-VaasCertificate/)

[https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Get-VaasCertificate.ps1](https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Get-VaasCertificate.ps1)

