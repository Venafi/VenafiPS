# Invoke-VenafiParallel

## SYNOPSIS
Helper function to execute a scriptblock in parallel

## SYNTAX

```
Invoke-VenafiParallel [-InputObject] <PSObject> [-ScriptBlock] <ScriptBlock> [[-ThrottleLimit] <Int32>]
 [[-ProgressTitle] <String>] [[-VenafiSession] <PSObject>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Execute a scriptblock in parallel.
For PS v5, the ThreadJob module is required.

## EXAMPLES

### EXAMPLE 1
```
Invoke-VenafiParallel -InputObject $myObjects -ScriptBlock { Do-Something $PSItem }
```

Execute in parallel. 
Reference each item in the scriptblock as $PSItem or $_.

### EXAMPLE 2
```
Invoke-VenafiParallel -InputObject $myObjects -ScriptBlock { Do-Something $PSItem } -ThrottleLimit 5
```

Only run 5 threads at a time instead of the default of 100.

### EXAMPLE 3
```
$ProgressPreference = 'SilentlyContinue'
Invoke-VenafiParallel -InputObject $myObjects -ScriptBlock { Do-Something $PSItem }
```

Execute in parallel with no progress bar.

## PARAMETERS

### -InputObject
List of items to iterate over

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScriptBlock
Scriptblock to execute against the list of items

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ThrottleLimit
Limit the number of threads when running in parallel; the default is 100.
Setting the value to 1 will disable multithreading.
On PS v5 the ThreadJob module is required. 
If not found, multithreading will be disabled.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressTitle
Message displayed on the progress bar

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Performing action
Accept pipeline input: False
Accept wildcard characters: False
```

### -VenafiSession
Authentication for the function.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
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

## NOTES
In your ScriptBlock:
- Use either $PSItem or $_ to reference the current input object
- Remember hashtables are reference types so be sure to clone if 'using' from parent

## RELATED LINKS
