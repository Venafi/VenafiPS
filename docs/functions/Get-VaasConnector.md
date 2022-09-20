# Get-VaasConnector

## SYNOPSIS
Get VaaS connectors

## SYNTAX

### ID (Default)
```
Get-VaasConnector -ID <Guid> [-VenafiSession <PSObject>] [<CommonParameters>]
```

### All
```
Get-VaasConnector [-All] [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Get 1 or all VaaS connectors

## EXAMPLES

### EXAMPLE 1
```
Get-VaasConnector -ID $my_guid
```

Get info for a specific connector

### EXAMPLE 2
```
Get-VaasConnector -All
```

Get info for all connectors

## PARAMETERS

### -ID
Guid for the specific connector to retrieve

```yaml
Type: Guid
Parameter Sets: ID
Aliases: connectorId

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -All
Get all connectors

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

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-VaasConnector/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-VaasConnector/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VaasConnector.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VaasConnector.ps1)

[https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=connectors-service#/Connectors/connectors_getAll](https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=connectors-service#/Connectors/connectors_getAll)

[https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=connectors-service#/Connectors/connectors_getById](https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=connectors-service#/Connectors/connectors_getById)

