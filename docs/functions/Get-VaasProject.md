# Get-VaasProject

## SYNOPSIS
Get project info

## SYNTAX

### All (Default)
```
Get-VaasProject [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### Id
```
Get-VaasProject -ProjectId <Guid> [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Get info for either a specific project or all projects. 
Venafi as a Service only, not for TPP.

## EXAMPLES

### EXAMPLE 1
```
Get-VaasProject
```

Get info for all projects

### EXAMPLE 2
```
Get-VaasProject -Id 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
```

Get info for a specific project

## PARAMETERS

### -ProjectId
Id to get info for a specific project

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

### ProjectId
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS
