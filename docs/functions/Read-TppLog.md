# Read-TppLog

## SYNOPSIS
Read entries from the TPP log

## SYNTAX

```
Read-TppLog [[-Path] <String>] [[-EventId] <String>] [[-Severity] <TppEventSeverity>] [[-StartTime] <DateTime>]
 [[-EndTime] <DateTime>] [[-Text1] <String>] [[-Text2] <String>] [[-Value1] <Int32>] [[-Value2] <Int32>]
 [[-First] <Int32>] [[-VenafiSession] <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Read entries from the TPP log

## EXAMPLES

### EXAMPLE 1
```
Read-TppLog -First 10
```

Get the most recent 10 log items

### EXAMPLE 2
```
$capiObject | Read-TppLog
```

Find all events for a specific object

### EXAMPLE 3
```
Read-TppLog -EventId '00130003'
```

Find all events with event ID '00130003', Certificate Monitor - Certificate Expiration Notice

## PARAMETERS

### -Path
Path to search for related records

```yaml
Type: String
Parameter Sets: (All)
Aliases: DN

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -EventId
Event ID as found in Logging-\>Event Definitions

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Severity
Filter records by severity

```yaml
Type: TppEventSeverity
Parameter Sets: (All)
Aliases:
Accepted values: Emergency, Alert, Critical, Error, Warning, Notice, Info, Debug

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartTime
Start time of events

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndTime
End time of events

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Text1
Filter matching results of Text1

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Text2
Filter matching results of Text2

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value1
Filter matching results of Value1

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value2
Filter matching results of Value2

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -First
Specify the number of items to retrieve, starting with most recent. 
The default is 100 and there is no maximum.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Limit

Required: False
Position: 10
Default value: 0
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
Position: 11
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Path
## OUTPUTS

### PSCustomObject with properties:
###     EventId
###     ClientTimestamp
###     Component
###     ComponentId
###     ComponentSubsystem
###     Data
###     Grouping
###     Id
###     Name
###     ServerTimestamp
###     Severity
###     SourceIP
###     Text1
###     Text2
###     Value1
###     Value2
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Read-TppLog/](http://VenafiPS.readthedocs.io/en/latest/functions/Read-TppLog/)

[https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Read-TppLog.ps1](https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Read-TppLog.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-Log.php?tocpath=Web%20SDK%7CLog%20programming%20interface%7C_____2](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-Log.php?tocpath=Web%20SDK%7CLog%20programming%20interface%7C_____2)

