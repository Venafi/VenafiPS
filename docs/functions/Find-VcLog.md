# Find-VcLog

## SYNOPSIS
Find log entries on TLSPC

## SYNTAX

### All (Default)
```
Find-VcLog [-Name <String>] [-Type <String>] [-Message <String>] [-Order <PSObject[]>] [-First <Int32>]
 [-VenafiSession <PSObject>] [<CommonParameters>]
```

### Filter
```
Find-VcLog -Filter <ArrayList> [-Order <PSObject[]>] [-First <Int32>] [-VenafiSession <PSObject>]
 [<CommonParameters>]
```

## DESCRIPTION
Find log entries

## EXAMPLES

### EXAMPLE 1
```
Find-VcLog -First 10
```

Get the most recent 10 log items

### EXAMPLE 2
```
Find-VcLog -Type 'Authentication'
```

Filter log results by specific value

### EXAMPLE 3
```
Find-VcLog -Filter @('and', @('activityDate', 'gt', (get-date).AddMonths(-1)), @('or', @('message', 'find', 'greg@venafi.com'), @('message', 'find', 'bob@venafi.com')), @('activityType','eq','Authentication'))
```

Advanced filtering of results.
This filter will find authentication log entries by 1 of 2 people within the last month.

### EXAMPLE 4
```
Find-VcLog -Type 'Authentication' -Order 'activityDate'
```

Filter log results and order them.
By default, order will be ascending.

### EXAMPLE 5
```
Find-VcLog -Type 'Authentication' -Order @{'activityDate'='desc'}
```

Filter log results and order them descending

### EXAMPLE 6
```
Find-VcLog -Type 'Authentication' -Order @{'activityDate'='desc'}, 'criticality'
```

Filter log results and order them by multiple fields

## PARAMETERS

### -Name
Activity name to find via regex match

```yaml
Type: String
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Activity type

```yaml
Type: String
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Message
Look anywhere in the message for the string provided

```yaml
Type: String
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
Array or multidimensional array of fields and values to filter on.
Each array should be of the format @('operator', @(field, comparison operator, value), @(field2, comparison operator2, value2)).
Nested filters are supported.
For a complete list of comparison operators, see https://docs.venafi.cloud/api/about-api-search-operators/.

```yaml
Type: ArrayList
Parameter Sets: Filter
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Order
Array of fields to order on.
For each item in the array, you can provide a field name by itself; this will default to ascending.
You can also provide a hashtable with the field name as the key and either asc or desc as the value.

```yaml
Type: PSObject[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -First
Only retrieve this many records

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

### -VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TLSPC key can also provided.

```yaml
Type: PSObject
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

## OUTPUTS

### PSCustomObject
###     activityLogId
###     activityDate
###     activityType
###     activityName
###     criticality
###     message
###     payload
###     companyId
## NOTES

## RELATED LINKS

[https://api.venafi.cloud/webjars/swagger-ui/index.html?configUrl=/v3/api-docs/swagger-config#/Activity%20Logs/activitylogs_getByExpression](https://api.venafi.cloud/webjars/swagger-ui/index.html?configUrl=/v3/api-docs/swagger-config#/Activity%20Logs/activitylogs_getByExpression)

