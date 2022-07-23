# Get-VaasApplication

## SYNOPSIS
Get application info

## SYNTAX

### ID (Default)
```
Get-VaasApplication -ID <String> [-VenafiSession <PSObject>] [<CommonParameters>]
```

### All
```
Get-VaasApplication [-All] [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Get info for either a specific application or all applications. 
Venafi as a Service only, not for TPP.

## EXAMPLES

### EXAMPLE 1
```
Get-VaasApplication -ID 'MyApp'
```

Get info for a specific application by name

### EXAMPLE 2
```
Get-VaasApplication -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
```

Get info for a specific application

### EXAMPLE 3
```
Get-VaasApplication -All
```

Get info for all applications

## PARAMETERS

### -ID
Name or Guid to get info for a specific application

```yaml
Type: String
Parameter Sets: ID
Aliases: applicationId

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -All
Get all applications

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

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-VaasApplication/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-VaasApplication/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VaasApplication.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VaasApplication.ps1)

[https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Applications/applications_getAll](https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Applications/applications_getAll)

[https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Applications/applications_getById](https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Applications/applications_getById)

