# Read-TppLog

## SYNOPSIS
Read entries from the TPP log

## SYNTAX

### Default (Default)
```
Read-TppLog [-Severity <TppEventSeverity>] [-StartTime <DateTime>] [-EndTime <DateTime>] [-Text1 <String>]
 [-Text2 <String>] [-Value1 <Int32>] [-Value2 <Int32>] [-Limit <Int32>] [-TppSession <TppSession>]
 [<CommonParameters>]
```

### ByObject
```
Read-TppLog -InputObject <TppObject> [-Severity <TppEventSeverity>] [-StartTime <DateTime>]
 [-EndTime <DateTime>] [-Text1 <String>] [-Text2 <String>] [-Value1 <Int32>] [-Value2 <Int32>] [-Limit <Int32>]
 [-TppSession <TppSession>] [<CommonParameters>]
```

### ByPath
```
Read-TppLog -Path <String> [-Severity <TppEventSeverity>] [-StartTime <DateTime>] [-EndTime <DateTime>]
 [-Text1 <String>] [-Text2 <String>] [-Value1 <Int32>] [-Value2 <Int32>] [-Limit <Int32>]
 [-TppSession <TppSession>] [<CommonParameters>]
```

## DESCRIPTION
Read entries from the TPP log

## EXAMPLES

### EXAMPLE 1
```
Read-TppLog -Limit 10
```

Get the most recent 10 log items

### EXAMPLE 2
```
$capiObject | Read-TppLog
```

Find all events for a specific object

## PARAMETERS

### -InputObject
TppObject which represents a unique object to search for related records

```yaml
Type: TppObject
Parameter Sets: ByObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
Path to search for related records

```yaml
Type: String
Parameter Sets: ByPath
Aliases: DN

Required: True
Position: Named
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
Position: Named
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
Position: Named
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
Position: Named
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
Position: Named
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
Position: Named
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
Position: Named
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
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
Specify the number of items to retrieve, starting with most recent. 
The default is 100 and there is no maximum.

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

### -TppSession
Session object created from New-TppSession method. 
The value defaults to the script session object $TppSession.

```yaml
Type: TppSession
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $Script:TppSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### InputObject
## OUTPUTS

### PSCustomObject with properties:
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

[http://venafitppps.readthedocs.io/en/latest/functions/Read-TppLog/](http://venafitppps.readthedocs.io/en/latest/functions/Read-TppLog/)

[https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Read-TppLog.ps1](https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Read-TppLog.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-Log.php?tocpath=Web%20SDK%7CLog%20programming%20interface%7C_____2](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-Log.php?tocpath=Web%20SDK%7CLog%20programming%20interface%7C_____2)

