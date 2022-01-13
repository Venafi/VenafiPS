# ConvertTo-TppGuid

## SYNOPSIS
Convert DN path to GUID

## SYNTAX

```
ConvertTo-TppGuid [-Path] <String> [-IncludeType] [[-VenafiSession] <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Convert DN path to GUID

## EXAMPLES

### EXAMPLE 1
```
ConvertTo-TppGuid -Path '\ved\policy\convertme'
```

## PARAMETERS

### -Path
DN path representing an object

```yaml
Type: String
Parameter Sets: (All)
Aliases: DN

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -IncludeType
{{ Fill IncludeType Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
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
Position: 2
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Path
## OUTPUTS

### Guid
## NOTES

## RELATED LINKS
