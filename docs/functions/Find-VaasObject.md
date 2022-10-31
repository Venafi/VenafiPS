# Find-VaasObject

## SYNOPSIS
Find different objects on VaaS

## SYNTAX

```
Find-VaasObject [-Type] <String> [[-Filter] <ArrayList>] [[-Order] <PSObject[]>] [[-VenafiSession] <PSObject>]
 [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>] [<CommonParameters>]
```

## DESCRIPTION
Find objects of type ActivityLog, Machine, MachineIdentity, CertificateRequest, CertificateInstance on VaaS.
Supports -First for page size and -IncludeTotalCount to retrieve all by paging.
The max page size is 1000.
To find certificate objects, use Find-VenafiCertificate.

## EXAMPLES

### EXAMPLE 1
```
Find-VaasObject -Type CertificateInstance
```

Get first 1000 records

### EXAMPLE 2
```
Find-VaasObject -Type CertificateInstance -First 50
```

Get first 50 records

### EXAMPLE 3
```
Find-VaasObject -Type CertificateInstance -First 500 -IncludeTotalCount
```

Get all records paging 500 at a time

### EXAMPLE 4
```
Find-VaasObject -Type ActivityLog -Filter @('activityType', 'eq', 'Notifications') -First 10
```

Retrieve 10 records matching the field name

### EXAMPLE 5
```
Find-VaasObject -Type ActivityLog -Filter @('activityType', 'eq', 'Notifications') -First 10 -Order @{'activityDate'='desc'}
```

Retrieve the most recent 10 records matching the field name

### EXAMPLE 6
```
Find-VaasObject -Filter @('and', @('activityDate', 'gt', (get-date).AddMonths(-1)), @('or', @('userId', 'eq', 'ab0feb46-8df7-47e7-8da9-f47ab314f26a'), @('userId', 'eq', '933c28de-6352-46f3-bc12-bd96077e8eae')))
```

Advanced filtering of results. 
This filter will find log entries by 1 of 2 people within the last month.

## PARAMETERS

### -Type
Type of object to retrieve. 
Can be ActivityLog, Machine, MachineIdentity, CertificateRequest, or CertificateInstance.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A VaaS key can also provided.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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

## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Find-VaasObject/](http://VenafiPS.readthedocs.io/en/latest/functions/Find-VaasObject/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-VaasObject.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-VaasObject.ps1)

