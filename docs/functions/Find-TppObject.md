# Find-TppObject

## SYNOPSIS
Find objects by path, class, or pattern

## SYNTAX

### FindByClassAndPath
```
Find-TppObject -Path <String> [-Pattern <String>] [-Recursive] -Class <String[]> [-TppSession <TppSession>]
 [<CommonParameters>]
```

### FindByPath
```
Find-TppObject -Path <String> [-Pattern <String>] [-Recursive] [-TppSession <TppSession>] [<CommonParameters>]
```

### FindByAttribute
```
Find-TppObject -Pattern <String> -Attribute <String[]> [-TppSession <TppSession>] [<CommonParameters>]
```

### FindByClass
```
Find-TppObject [-Pattern <String>] -Class <String[]> [-TppSession <TppSession>] [<CommonParameters>]
```

### FindByPattern
```
Find-TppObject -Pattern <String> [-TppSession <TppSession>] [<CommonParameters>]
```

## DESCRIPTION
Find objects by path, class, or pattern.

## EXAMPLES

### EXAMPLE 1
```
Find-TppObject -Path '\VED\Policy'
```

Get all objects in the root of a specific folder

### EXAMPLE 2
```
Find-TppObject -Path '\VED\Policy\My Folder' -Recursive
```

Get all objects in a folder and subfolders

### EXAMPLE 3
```
Find-TppObject -Path '\VED\Policy' -Pattern 'test'
```

Get items in a specific folder filtering the path

### EXAMPLE 4
```
Find-TppObject -Class 'iis6'
```

Get all objects of the type iis6

### EXAMPLE 5
```
Find-TppObject -Class 'iis6' -Pattern 'test*'
```

Get all objects of the type iis6 filtering the path

### EXAMPLE 6
```
Find-TppObject -Class 'iis6', 'capi'
```

Get all objects of the type iis6 or capi

### EXAMPLE 7
```
Find-TppObject -Pattern 'test*'
```

Find objects with the specific name. 
All objects will be searched.

### EXAMPLE 8
```
Find-TppObject -Pattern 'test*' -Attribute 'Consumers'
```

Find all objects where the specific attribute matches the pattern

## PARAMETERS

### -Path
The path to start our search.

```yaml
Type: String
Parameter Sets: FindByClassAndPath, FindByPath
Aliases: DN

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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
Parameter Sets: FindByClassAndPath, FindByPath, FindByClass
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: FindByAttribute, FindByPattern
Aliases:

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
Parameter Sets: FindByClassAndPath, FindByPath
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Class
1 or more classes to search for

```yaml
Type: String[]
Parameter Sets: FindByClassAndPath, FindByClass
Aliases:

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

### Path
## OUTPUTS

### TppObject
## NOTES

## RELATED LINKS

[http://venafitppps.readthedocs.io/en/latest/functions/Find-TppObject/](http://venafitppps.readthedocs.io/en/latest/functions/Find-TppObject/)

[https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Find-TppObject.ps1](https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Find-TppObject.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-find.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____17](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-find.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____17)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-findobjectsofclass.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____19](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-findobjectsofclass.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____19)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-enumerate.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____13](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-enumerate.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____13)

