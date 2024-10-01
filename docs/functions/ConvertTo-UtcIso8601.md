# ConvertTo-UtcIso8601

## SYNOPSIS
Convert datetime to UTC ISO 8601 format

## SYNTAX

```
ConvertTo-UtcIso8601 [-InputObject] <DateTime> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Convert datetime to UTC ISO 8601 format

## EXAMPLES

### EXAMPLE 1
```
(get-date) | ConvertTo-UtcIso8601
```

## PARAMETERS

### -InputObject
DateTime object

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### InputObject
## OUTPUTS

### System.String
## NOTES

## RELATED LINKS
