# Find-TppCodeSignEnvironment

## SYNOPSIS
Search for code sign environments

## SYNTAX

### All (Default)
```
Find-TppCodeSignEnvironment [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### Name
```
Find-TppCodeSignEnvironment -Name <String> [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Search for specific code sign environments that match a name you provide or get all. 
This will search across projects.

## EXAMPLES

### EXAMPLE 1
```
Find-TppCodeSignEnvironment
```

Get all code sign environments

### EXAMPLE 2
```
Find-TppCodeSignEnvironment -Name Development
```

Find all environments that match the name Development

## PARAMETERS

### -Name
Name of the environment to search for

```yaml
Type: String
Parameter Sets: Name
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
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

### None
## OUTPUTS

### TppObject
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppCodeSignEnvironment/](http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppCodeSignEnvironment/)

[https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Find-TppCodeSignEnvironment.ps1](https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Find-TppCodeSignEnvironment.ps1)

