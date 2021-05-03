# ConvertTo-TppPath

## SYNOPSIS
Convert GUID to Path

## SYNTAX

```
ConvertTo-TppPath [-Guid] <Guid> [-IncludeType] [[-VenafiSession] <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Convert GUID to Path

## EXAMPLES

### EXAMPLE 1
```
ConvertTo-TppPath -Guid [guid]'xyxyxyxy-xyxy-xyxy-xyxy-xyxyxyxyxyxy'
```

## PARAMETERS

### -Guid
Guid type, \[guid\] 'xyxyxyxy-xyxy-xyxy-xyxy-xyxyxyxyxyxy'

```yaml
Type: Guid
Parameter Sets: (All)
Aliases:

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
Default value: $Script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Guid
## OUTPUTS

### String representing the Path
## NOTES

## RELATED LINKS
