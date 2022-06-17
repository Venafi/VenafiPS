# Get-TppAttribute

## SYNOPSIS
Get object attributes as well as policies (policy attributes)

## SYNTAX

### ByPath (Default)
```
Get-TppAttribute -Path <String> [-Attribute <String[]>] [-AsValue] [-New] [-VenafiSession <PSObject>]
 [<CommonParameters>]
```

### AllPolicyPath
```
Get-TppAttribute -Path <String> [-All] [-Policy] -PolicyClass <String> [-New] [-VenafiSession <PSObject>]
 [<CommonParameters>]
```

### PolicyPath
```
Get-TppAttribute -Path <String> -Attribute <String[]> [-Policy] -PolicyClass <String> [-AsValue] [-New]
 [-VenafiSession <PSObject>] [<CommonParameters>]
```

### AllEffectivePath
```
Get-TppAttribute -Path <String> [-All] [-New] [-VenafiSession <PSObject>] [<CommonParameters>]
```

### EffectiveByPath
```
Get-TppAttribute -Path <String> -Attribute <String[]> [-Effective] [-AsValue] [-New]
 [-VenafiSession <PSObject>] [<CommonParameters>]
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
Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -New
```

Name                                   : test.gdb.com
Path                                   : \ved\policy\certificates\test.gdb.com
TypeName                               : X509 Server Certificate
Guid                                   : b7a7221b-e038-41d9-9d49-d7f45c1ca128
Certificate Vault Id                   : @{Value=442493; CustomFieldName=; PolicyPath=}
Consumers                              : @{Value=System.Object\[\]; CustomFieldName=; PolicyPath=}
Created By                             : @{Value=WebAdmin; CustomFieldName=; PolicyPath=}

Retrieve all values for an object, excluding values assigned by policy

### EXAMPLE 2
```
Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -Attribute 'Driver Name' -New
```

Name        : test.gdb.com
Path        : \ved\policy\certificates\test.gdb.com
TypeName    : X509 Server Certificate
Guid        : b7a7221b-e038-41d9-9d49-d7f45c1ca128
Driver Name : @{Value=appx509certificate; CustomFieldName=; PolicyPath=}

Retrieve the value for a specific attribute

### EXAMPLE 3
```
Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -AttributeName 'State' -Effective -New
```

Name     : test.gdb.com
Path     : \ved\policy\certificates\test.gdb.com
TypeName : X509 Server Certificate
Guid     : b7a7221b-e038-41d9-9d49-d7f45c1ca128
State    : @{Value=UT; CustomFieldName=; PolicyPath=\VED\Policy\Certificates}

Retrieve the effective (policy applied) value for a specific attribute.
This not only returns the value, but also the path where the policy is applied.

### EXAMPLE 4
```
Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -All -New
```

Name                 : test.gdb.com
Path                 : \ved\policy\certificates\test.gdb.com
TypeName             : X509 Server Certificate
Guid                 : b7a7221b-e038-41d9-9d49-d7f45c1ca128
Certificate Vault Id : @{Value=442493; CustomFieldName=; PolicyPath=}
City                 : @{Value=Salt Lake City; CustomFieldName=; PolicyPath=\VED\Policy\Certificates}
Consumers            : @{Value=System.Object\[\]; CustomFieldName=; PolicyPath=}
Created By           : @{Value=WebAdmin; CustomFieldName=; PolicyPath=}
State                : @{Value=UT; CustomFieldName=; PolicyPath=\VED\Policy\Certificates}

Retrieve all effective values for an object

### EXAMPLE 5
```
Get-TppAttribute -Path '\VED\Policy\certificates' -PolicyClass 'X509 Certificate' -AttributeName 'State' -New
```

Name            : certificates
Path            : \ved\policy\certificates
TypeName        : Policy
Guid            : a91fc152-a9fb-4b49-a7ca-7014b14d73eb
PolicyClassName : x509 certificate
State           : UT

Retrieve specific policy attribute values for the specified policy folder and class

### EXAMPLE 6
```
Get-TppAttribute -Path '\VED\Policy\certificates' -PolicyClass 'X509 Certificate' -All -New
```

Name            : certificates
Path            : \ved\policy\certificates
TypeName        : Policy
Guid            : a91fc152-a9fb-4b49-a7ca-7014b14d73eb
PolicyClassName : x509 certificate
City            : Salt Lake City
Country         : US
Management Type : Enrollment
Organization    : Venafi, Inc.
State           : UT

Retrieve all policy attribute values for the specified policy folder and class

## PARAMETERS

### -Path
Path to the object to retrieve configuration attributes. 
Just providing DN will return all attributes.

```yaml
Type: String
Parameter Sets: (All)
Aliases: DN

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Attribute
Only retrieve the value/values for this attribute

```yaml
Type: String[]
Parameter Sets: ByPath
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String[]
Parameter Sets: PolicyPath, EffectiveByPath
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
Parameter Sets: EffectiveByPath
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
Parameter Sets: AllPolicyPath, AllEffectivePath
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Policy
Deprecated. 
To retrieve policy attributes, just provide -PolicyClass.

```yaml
Type: SwitchParameter
Parameter Sets: AllPolicyPath, PolicyPath
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PolicyClass
Get policies (aka policy attributes) instead of object attributes.
Provide the class name to retrieve the value for.
If unsure of the class name, add the value through the TPP UI and go to Support-\>Policy Attributes to find it.

```yaml
Type: String
Parameter Sets: AllPolicyPath, PolicyPath
Aliases: ClassName

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsValue
Deprecated. 
No longer required with -New format.

```yaml
Type: SwitchParameter
Parameter Sets: ByPath, PolicyPath, EffectiveByPath
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -New
New output format which returns 1 object with multiple properties instead of an object per property

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Path
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppAttribute/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppAttribute/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppAttribute.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppAttribute.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-read.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-read.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-readall.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-readall.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-readeffectivepolicy.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-readeffectivepolicy.php)

