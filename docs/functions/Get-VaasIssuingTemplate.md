# Get-VaasIssuingTemplate

## SYNOPSIS
Get issuing templates

## SYNTAX

### ID (Default)
```
Get-VaasIssuingTemplate -ID <Guid> [-VenafiSession <PSObject>] [<CommonParameters>]
```

### All
```
Get-VaasIssuingTemplate [-All] [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Get info for either a specific template or all templates.
Venafi as a Service only, not for TPP.

## EXAMPLES

### EXAMPLE 1
```
Get-VaasIssuingTemplate -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
```

Get info for a specific template

### EXAMPLE 2
```
Get-VaasIssuingTemplate -All
```

Get info for all templates

## PARAMETERS

### -ID
Id to get info for a specific template

```yaml
Type: Guid
Parameter Sets: ID
Aliases: certificateIssuingTemplateId

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -All
Get all templates

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: True
Position: Named
Default value: False
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
Position: Named
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### ID
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-VaasIssuingTemplate/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-VaasIssuingTemplate/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VaasIssuingTemplate.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VaasIssuingTemplate.ps1)

