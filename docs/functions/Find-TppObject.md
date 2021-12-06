# Find-TppObject

## SYNOPSIS
Find objects by path, class, or pattern

## SYNTAX

### FindByPath (Default)
```
Find-TppObject [-Path <String>] [-Recursive] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### FindByPattern
```
Find-TppObject [-Path <String>] -Pattern <String> [-Recursive] [-VenafiSession <VenafiSession>]
 [<CommonParameters>]
```

### FindByClass
```
Find-TppObject [-Path <String>] [-Pattern <String>] -Class <String[]> [-Recursive]
 [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### FindByAttribute
```
Find-TppObject -Pattern <String> -Attribute <String[]> [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Find objects by path, class, or pattern.

## EXAMPLES

### EXAMPLE 1
```
Find-TppObject
```

Get all objects recursively starting from \ved\policy

### EXAMPLE 2
```
Find-TppObject -Path '\VED\Policy\certificates'
```

Get all objects in the root of a specific folder

### EXAMPLE 3
```
Find-TppObject -Path '\VED\Policy\My Folder' -Recursive
```

Get all objects in a folder and subfolders

### EXAMPLE 4
```
Find-TppObject -Path '\VED\Policy' -Pattern '*test*'
```

Get items in a specific folder filtering the path

### EXAMPLE 5
```
Find-TppObject -Class 'capi' -Path '\ved\policy\installations' -Recursive
```

Get objects of a specific type

### EXAMPLE 6
```
Find-TppObject -Class 'capi' -Pattern '*test*' -Path '\ved\policy\installations' -Recursive
```

Get all objects of a specific type where the path is of a specific pattern

### EXAMPLE 7
```
Find-TppObject -Class 'capi', 'iis6' -Pattern '*test*' -Path '\ved\policy\installations' -Recursive
```

Get objects for multiple types

### EXAMPLE 8
```
Find-TppObject -Pattern '*f5*'
```

Find objects with the specific name. 
All objects under \ved\policy (the default) will be searched.

### EXAMPLE 9
```
Find-TppObject -Pattern 'awesome*' -Attribute 'Description'
```

Find objects where the specific attribute matches the pattern

## PARAMETERS

### -Path
The path to start our search. 
The default is \ved\policy.

```yaml
Type: String
Parameter Sets: FindByPath, FindByPattern, FindByClass
Aliases: DN

Required: False
Position: Named
Default value: \ved\policy
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Pattern
Filter against object paths.
If the Attribute parameter is provided, this will filter against an object's attribute values instead of the path.

Follow the below rules:
- To list DNs that include an asterisk (*) or question mark (?), prepend two backslashes (\\\\).
For example, \\\\*.MyCompany.net treats the asterisk as a literal character and returns only certificates with DNs that match *.MyCompany.net.
- To list DNs with a wildcard character, append a question mark (?).
For example, "test_?.mycompany.net" counts test_1.MyCompany.net and test_2.MyCompany.net but not test12.MyCompany.net.
- To list DNs with similar names, prepend an asterisk.
For example, *est.MyCompany.net, counts Test.MyCompany.net and West.MyCompany.net.
You can also use both literals and wildcards in a pattern.

```yaml
Type: String
Parameter Sets: FindByPattern, FindByAttribute
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: FindByClass
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Class
1 or more classes/types to search for

```yaml
Type: String[]
Parameter Sets: FindByClass
Aliases: TypeName

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Attribute
A list of attribute names to limit the search against. 
Only valid when searching by pattern.

```yaml
Type: String[]
Parameter Sets: FindByAttribute
Aliases: AttributeName

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recursive
Searches the subordinates of the object specified in Path.

```yaml
Type: SwitchParameter
Parameter Sets: FindByPath, FindByPattern, FindByClass
Aliases: r

Required: False
Position: Named
Default value: False
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
Position: Named
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Path
## OUTPUTS

### TppObject
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppObject/](http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppObject/)

[https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Public/Find-TppObject.ps1](https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Public/Find-TppObject.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-find.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-find.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-findobjectsofclass.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-findobjectsofclass.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-enumerate.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-enumerate.php)

