# Select-VenBatch

## SYNOPSIS
Batches pipeline input.

## SYNTAX

```
Select-VenBatch [-InputObject <Object>] -BatchSize <Int32> [-BatchType] <String> [-TotalCount <Int32>]
 [-Activity <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Batches up pipeline input into consistently sized List\[T\]s of objects.
Used to ensure that processing occurs in specific sized batches.
Useful for not recieving API timouts due to sending more objects than can be processed in the connection timeout period.

## EXAMPLES

### EXAMPLE 1
```
1..6000 | Select-VenBatch -batchsize 1000 -BatchType string
```

## PARAMETERS

### -InputObject
The pipeline input objects binds to this parameter one by one.
Do not use it directly.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -BatchSize
The size of the batches to separate the pipeline input into.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -BatchType
Type of object to group things into.
Defaults to a Powershell custom object

Valid Values: "pscustomobject", "string", "int", "guid"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: Pscustomobject
Accept pipeline input: False
Accept wildcard characters: False
```

### -TotalCount
The total number of items in the pipeline.
Used to calculate progress.
If you do not provide this value or ProgressPreference is set to 'SilentlyContinue', no progress will be displayed.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Activity
{{ Fill Activity Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Processing batches
Accept pipeline input: False
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

## OUTPUTS

### System.Collections.Generic.List[T]
## NOTES

## RELATED LINKS
