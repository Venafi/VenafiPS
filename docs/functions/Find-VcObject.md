# Find-VcObject

## SYNOPSIS
Find different objects on TLSPC

## SYNTAX

### All (Default)
```
Find-VcObject -Type <String> [-Name <String>] [-Order <PSObject[]>] [-First <Int32>]
 [-VenafiSession <PSObject>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Filter
```
Find-VcObject -Type <String> -Filter <System.Collections.Generic.List`1[System.Object]> [-Order <PSObject[]>]
 [-First <Int32>] [-VenafiSession <PSObject>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### SavedSearch
```
Find-VcObject -Type <String> -SavedSearchName <String> [-First <Int32>] [-VenafiSession <PSObject>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Find objects of type ActivityLog, Machine, MachineIdentity, CertificateRequest, CertificateInstance on TLSPC.
Supports -First for page size; the max page size is 1000.
To find certificate objects, use Find-VcCertificate.

## EXAMPLES

### EXAMPLE 1
```
Find-VcObject -Type CertificateInstance
```

Get all records

### EXAMPLE 2
```
Find-VcObject -Type CertificateInstance -First 50
```

Get first 50 records

### EXAMPLE 3
```
Find-VcObject -Type ActivityLog -Filter @('activityType', 'eq', 'Notifications') -First 10
```

Retrieve 10 records matching the field name

### EXAMPLE 4
```
Find-VcObject -Type Certificate -Name searchme
```

Get all certificates where the name has 'searchme' in it

### EXAMPLE 5
```
Find-VcObject -type Certificate -filter @('selfSigned','eq','True')
```

Get all self signed certificates

### EXAMPLE 6
```
Find-VcObject -Type ActivityLog -Filter @('activityType', 'eq', 'Notifications') -First 10 -Order @{'activityDate'='desc'}
```

Retrieve the most recent 10 records matching the field name

### EXAMPLE 7
```
Find-VcObject -Filter @('and', @('activityDate', 'gt', (get-date).AddMonths(-1)), @('or', @('userId', 'eq', 'ab0feb46-8df7-47e7-8da9-f47ab314f26a'), @('userId', 'eq', '933c28de-6352-46f3-bc12-bd96077e8eae')))
```

Advanced filtering of results. 
This filter will find log entries by 1 of 2 people within the last month.

## PARAMETERS

### -Type
Type of object to retrieve, either Certificate, ActivityLog, Machine, MachineIdentity, CertificateRequest, or CertificateInstance.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Case sensitive name to search for.
The field to be searched is different for each object type.

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
Type: System.Collections.Generic.List`1[System.Object]
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
Parameter Sets: All, Filter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SavedSearchName
{{ Fill SavedSearchName Description }}

```yaml
Type: String
Parameter Sets: SavedSearch
Aliases:

Required: True
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

### PSCustomObject
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Find-VcObject/](http://VenafiPS.readthedocs.io/en/latest/functions/Find-VcObject/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-VcObject.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-VcObject.ps1)

