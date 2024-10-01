# ConvertTo-VcTeam

## SYNOPSIS
Convert vaas team to standard format

## SYNTAX

```
ConvertTo-VcTeam [-InputObject] <PSObject[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Convert vaas team to standard format

## EXAMPLES

### EXAMPLE 1
```
$teamObj | ConvertTo-VcTeam
```

## PARAMETERS

### -InputObject
Team object

```yaml
Type: PSObject[]
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

### PSCustomObject
## NOTES

## RELATED LINKS
