# Find-TppEngine

## SYNOPSIS
Find TPP engines using an optional pattern

## SYNTAX

```
Find-TppEngine [-Pattern] <String> [[-VenafiSession] <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Find TPP engines using an optional pattern.
This function is an engine wrapper for Find-TppObject.

## EXAMPLES

### EXAMPLE 1
```
Find-TppEngine -Pattern '*partialname*'
```

Get engines whose name matches the supplied pattern

## PARAMETERS

### -Pattern
Filter against engine names using asterisk (*) and/or question mark (?) wildcard characters.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token can also provided, but this requires an environment variable TPP_SERVER to be set.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Pattern
## OUTPUTS

### TppObject
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppEngine/](http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppEngine/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppEngine.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppEngine.ps1)

