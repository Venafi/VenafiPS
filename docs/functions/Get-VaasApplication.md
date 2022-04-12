# Get-VaasApplication

## SYNOPSIS
Get application info

## SYNTAX

### All (Default)
```
Get-VaasApplication [-VenafiSession <PSObject>] [<CommonParameters>]
```

### Id
```
Get-VaasApplication -ApplicationId <Guid> [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Get info for either a specific application or all applications. 
Venafi as a Service only, not for TPP.

## EXAMPLES

### EXAMPLE 1
```
Get-VaasApplication
Get info for all applications
```

### EXAMPLE 2
```
Get-VaasApplication -ApplicationId 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Get info for a specific application
```

## PARAMETERS

### -ApplicationId
Id to get info for a specific application

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
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TppServer must also be set.

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

### ApplicationId
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS
