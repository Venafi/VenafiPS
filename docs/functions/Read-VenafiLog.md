# Read-VenafiLog

## SYNOPSIS
Read entries from the VaaS or TPP log

## SYNTAX

### TPP (Default)
```
Read-VenafiLog [-Path <String>] [-EventId <String>] [-Severity <TppEventSeverity>] [-StartTime <DateTime>]
 [-EndTime <DateTime>] [-Text1 <String>] [-Text2 <String>] [-Value1 <Int32>] [-Value2 <Int32>]
 [-VenafiSession <PSObject>] [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>] [<CommonParameters>]
```

### VaaS
```
Read-VenafiLog [-Filter <ArrayList>] [-Order <PSObject[]>] [-VenafiSession <PSObject>] [-IncludeTotalCount]
 [-Skip <UInt64>] [-First <UInt64>] [<CommonParameters>]
```

## DESCRIPTION
Read entries from the VaaS or TPP log.
Supports -First for paging.
Limit of 1000 records.

## EXAMPLES

### EXAMPLE 1
```
Read-VenafiLog -First 10
```

Get the most recent 10 log items

### EXAMPLE 2
```
$capiObject | Read-VenafiLog
```

Find all events for a specific TPP object

### EXAMPLE 3
```
Read-VenafiLog -EventId '00130003'
```

Find all TPP events with event ID '00130003', Certificate Monitor - Certificate Expiration Notice

### EXAMPLE 4
```
Read-VenafiLog -Filter @('and', @('authenticationType', 'eq', 'NONE'))
```

Filter VaaS log results

### EXAMPLE 5
```
Read-VenafiLog -Filter @('and', @('authenticationType', 'eq', 'NONE')) -First 5
```

Get first 5 VaaS entries of filtered log results

### EXAMPLE 6
```
Read-VenafiLog -Filter @('and', @('activityDate', 'gt', (get-date).AddMonths(-1)), @('or', @('userId', 'eq', 'ab0feb46-8df7-47e7-8da9-f47ab314f26a'), @('userId', 'eq', '933c28de-6352-46f3-bc12-bd96077e8eae')))
```

Advanced filtering of VaaS results. 
This filter will find log entries by 1 of 2 people within the last month.

### EXAMPLE 7
```
Read-VenafiLog -Filter @('and', @('authenticationType', 'eq', 'NONE')) -Order 'activityDate'
```

Filter VaaS log results and order them

### EXAMPLE 8
```
Read-VenafiLog -Filter @('and', @('authenticationType', 'eq', 'NONE')) -Order @{'activityDate'='desc'}
```

Filter VaaS log results and order them descending

### EXAMPLE 9
```
Read-VenafiLog -Filter @('and', @('authenticationType', 'eq', 'NONE')) -Order @{'activityDate'='desc'}, 'statusCode'
```

Filter VaaS log results and order them by multiple fields

## PARAMETERS

### -Path
TPP. 
Path to search for related records

```yaml
Type: String
Parameter Sets: TPP
Aliases: DN

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -EventId
TPP. 
Event ID as found in Logging-\>Event Definitions

```yaml
Type: String
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Severity
TPP. 
Filter records by severity

```yaml
Type: TppEventSeverity
Parameter Sets: TPP
Aliases:
Accepted values: Emergency, Alert, Critical, Error, Warning, Notice, Info, Debug

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartTime
TPP. 
Start time of events

```yaml
Type: DateTime
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndTime
TPP. 
End time of events

```yaml
Type: DateTime
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Text1
TPP. 
Filter matching results of Text1

```yaml
Type: String
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Text2
TPP. 
Filter matching results of Text2

```yaml
Type: String
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value1
TPP. 
Filter matching results of Value1

```yaml
Type: Int32
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value2
TPP. 
Filter matching results of Value2

```yaml
Type: Int32
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
VaaS. 
Array or multidimensional array of fields and values to filter on.
Each array should be of the format @('operator', @(field, comparison operator, value), @(field2, comparison operator2, value2)).
Nested filters are supported.
For a complete list of comparison operators, see https://docs.venafi.cloud/api/about-api-search-operators/.

```yaml
Type: ArrayList
Parameter Sets: VaaS
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Order
VaaS. 
Array of fields to order on.
For each item in the array, you can provide a field name by itself; this will default to ascending.
You can also provide a hashtable with the field name as the key and either asc or desc as the value.

```yaml
Type: PSObject[]
Parameter Sets: VaaS
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeTotalCount
Reports the total number of objects in the data set (an integer) followed by the selected objects.
If the cmdlet cannot determine the total count, it displays "Unknown total count." The integer has an Accuracy property that indicates the reliability of the total count value.
The value of Accuracy ranges from 0.0 to 1.0 where 0.0 means that the cmdlet could not count the objects, 1.0 means that the count is exact, and a value between 0.0 and 1.0 indicates an increasingly reliable estimate.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Skip
Ignores the specified number of objects and then gets the remaining objects.
Enter the number of objects to skip.

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -First
Gets only the specified number of objects.
Enter the number of objects to get.

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Path (for TPP)
## OUTPUTS

### PSCustomObject
### For TPP:
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
### For VaaS:
###     id
###     companyId
###     userId
###     activityDate
###     authenticationType
###     resourceUrl
###     resourceId
###     messageKey
###     messageKeyKey
###     messageArgs
###     message
## NOTES

## RELATED LINKS

[https://api.venafi.cloud/webjars/swagger-ui/index.html?configUrl=/v3/api-docs/swagger-config#/Activity%20Logs/activitylogs_getByExpression](https://api.venafi.cloud/webjars/swagger-ui/index.html?configUrl=/v3/api-docs/swagger-config#/Activity%20Logs/activitylogs_getByExpression)

[http://VenafiPS.readthedocs.io/en/latest/functions/Read-TppLog/](http://VenafiPS.readthedocs.io/en/latest/functions/Read-TppLog/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Read-TppLog.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Read-TppLog.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Log.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Log.php)

