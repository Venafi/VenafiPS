# Get-TppAttribute

## SYNOPSIS
Get object attributes as well as policies (policy attributes)

## SYNTAX

### ByPath (Default)
```
Get-TppAttribute -Path <String> [-Attribute <String[]>] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### PolicyPath
```
Get-TppAttribute -Path <String> -Attribute <String[]> [-Policy] -ClassName <String>
 [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### AllEffectivePath
```
Get-TppAttribute -Path <String> [-All] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### EffectiveByPath
```
Get-TppAttribute -Path <String> -Attribute <String[]> [-Effective] [-VenafiSession <VenafiSession>]
 [<CommonParameters>]
```

### ByGuid
```
Get-TppAttribute -Guid <Guid> [-Attribute <String[]>] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### EffectiveByGuid
```
Get-TppAttribute -Guid <Guid> -Attribute <String[]> [-Effective] [-VenafiSession <VenafiSession>]
 [<CommonParameters>]
```

## DESCRIPTION
Retrieves object attributes as well as policies (aka policy attributes).
You can either retrieve all attributes or individual ones.
By default, the attributes returned are not the effective policy, but that can be requested with the
Effective switch.
Policy folders can have attributes as well as policies which apply to the resultant objects.
For more info on policies and how they are different than attributes, see https://docs.venafi.com/Docs/current/TopNav/Content/Policies/c_policies_tpp.php.

## EXAMPLES

### EXAMPLE 1
```
Get-TppAttribute -Path '\VED\Policy\My Folder\myapp.company.com'
```

Retrieve all values for an object, excluding values assigned by policy

### EXAMPLE 2
```
Get-TppAttribute -Path '\VED\Policy\My Folder\myapp.company.com' -AttributeName 'driver name'
```

Retrieve the value for a specific attribute

### EXAMPLE 3
```
Get-TppAttribute -Path '\VED\Policy\My Folder\myapp.company.com' -AttributeName 'Contact' -Effective
```

Retrieve the effective value for a specific attribute

### EXAMPLE 4
```
Get-TppAttribute -Path '\VED\Policy\My Folder\myapp.company.com' -All
```

Retrieve all effective values for an object

### EXAMPLE 5
```
Get-TppAttribute -Path '\VED\Policy\My Folder' -Policy -Class 'X509 Certificate' -AttributeName 'Contact'
```

Retrieve the policy attribute value for the specified policy folder

## PARAMETERS

### -Path
Path to the object to retrieve configuration attributes. 
Just providing DN will return all attributes.

```yaml
Type: String
Parameter Sets: ByPath, PolicyPath, AllEffectivePath, EffectiveByPath
Aliases: DN

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Guid
To be deprecated; use -Path instead.
Object Guid. 
Just providing Guid will return all attributes.

```yaml
Type: Guid
Parameter Sets: ByGuid, EffectiveByGuid
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Attribute
{{ Fill Attribute Description }}

```yaml
Type: String[]
Parameter Sets: ByPath, ByGuid
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String[]
Parameter Sets: PolicyPath, EffectiveByPath, EffectiveByGuid
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Effective
Get the objects attribute value, once policies have been applied.
This is not applicable to policies, only objects.

```yaml
Type: SwitchParameter
Parameter Sets: EffectiveByPath, EffectiveByGuid
Aliases: EffectivePolicy

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
Get all effective object attribute values.
This will perform 3 steps, get the object type, enumerate the attributes for the object type, and get all the effective values.
The output will contain the path where the policy was applied from.
Note, expect this to take longer than usual given the number of api calls.

```yaml
Type: SwitchParameter
Parameter Sets: AllEffectivePath
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Policy
Get policies (aka policy attributes) instead of object attributes

```yaml
Type: SwitchParameter
Parameter Sets: PolicyPath
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClassName
Required when getting policy attributes. 
Provide the class name to retrieve the value for.
If unsure of the class name, add the value through the TPP UI and go to Support-\>Policy Attributes to find it.

```yaml
Type: String
Parameter Sets: PolicyPath
Aliases:

Required: True
Position: Named
Default value: None
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

### PSCustomObject with properties:
### - Name
### - Value
### - PolicyPath (only applicable with -All)
### - IsCustomField (not applicable to policies)
### - CustomName (not applicable to policies)
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppAttribute/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppAttribute/)

[https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Public/Get-TppAttribute.ps1](https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Public/Get-TppAttribute.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-read.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-read.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-readall.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-readall.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-readeffectivepolicy.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-readeffectivepolicy.php)

