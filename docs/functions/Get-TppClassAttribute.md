# Get-TppClassAttribute

## SYNOPSIS
List all attributes for a specified class

## SYNTAX

```
Get-TppClassAttribute [-ClassName] <String> [[-VenafiSession] <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
List all attributes for a specified class, helpful for validation or to pass to Get-TppAttribute

## EXAMPLES

### EXAMPLE 1
```
Get-TppClassAttribute -ClassName 'X509 Server Certificate'
Get all attributes for the specified class
```

## PARAMETERS

### -ClassName
{{ Fill ClassName Description }}

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
{{ Fill VenafiSession Description }}

```yaml
Type: VenafiSession
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

### ClassName
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS
