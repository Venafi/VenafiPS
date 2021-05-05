# Get-VenafiCertificate

## SYNOPSIS
Get certificate information

## SYNTAX

### All (Default)
```
Get-VenafiCertificate [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### Id
```
Get-VenafiCertificate [-CertificateId <Guid>] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Get certificate information, either all available to the api key provided or by id or zone.

## EXAMPLES

### EXAMPLE 1
```
Get-VenafiCertificate
```

Get certificate info for all certs

### EXAMPLE 2
```
Get-VenafiCertificate -CertificateId 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
```

Get certificate info for a specific cert on Venafi as a Serivce

### EXAMPLE 3
```
Get-VenafiCertificate -CertificateId '\ved\policy\mycert.com'
```

Get certificate info for a specific cert on TPP

## PARAMETERS

### -CertificateId
Certificate identifier. 
For Venafi as a Service, this is the unique guid. 
For TPP, use the full path.

```yaml
Type: Guid
Parameter Sets: Id
Aliases:

Required: False
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

### Id
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS
