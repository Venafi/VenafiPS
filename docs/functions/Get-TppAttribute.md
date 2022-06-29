# Get-TppAttribute

## SYNOPSIS
Get object attributes as well as policies (policy attributes)

## SYNTAX

### ByPath (Default)
```
Get-TppAttribute -Path <String> [-Attribute <String[]>] [-AsValue] [-New] [-VenafiSession <PSObject>]
 [<CommonParameters>]
```

### AllPolicy
```
Get-TppAttribute -Path <String> [-All] [-Policy] -PolicyClass <String> [-New] [-VenafiSession <PSObject>]
 [<CommonParameters>]
```

### Policy
```
Get-TppAttribute -Path <String> -Attribute <String[]> [-Policy] -PolicyClass <String> [-AsValue] [-New]
 [-VenafiSession <PSObject>] [<CommonParameters>]
```

### AllEffective
```
Get-TppAttribute -Path <String> [-Effective] [-All] [-New] [-VenafiSession <PSObject>] [<CommonParameters>]
```

### Effective
```
Get-TppAttribute -Path <String> -Attribute <String[]> [-Effective] [-AsValue] [-New]
 [-VenafiSession <PSObject>] [<CommonParameters>]
```

### AllByPath
```
Get-TppAttribute -Path <String> [-All] [-New] [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves object attributes as well as policies (aka policy attributes).
You can either retrieve all attributes or individual ones.
By default, the attributes returned are not the effective policy, but that can be requested with the -Effective switch.
Policy folders can have attributes as well as policies which apply to the resultant objects.
For more info on policies and how they are different than attributes, see https://docs.venafi.com/Docs/current/TopNav/Content/Policies/c_policies_tpp.php.

## EXAMPLES

### EXAMPLE 1
```
Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -New
```

Name                          : test.gdb.com
Path                          : \VED\Policy\Certificates\test.gdb.com
TypeName                      : X509 Server Certificate
Guid                          : b7a7221b-e038-41d9-9d49-d7f45c1ca128
ServiceNow Assignment Group   : @{Value=Venafi Management; CustomFieldGuid={7f214dec-9878-495f-a96c-57291f0d42da}}
ServiceNow CI                 : @{Value=9cc047ed1bad81100774ebd1b24bcbd0;
                                CustomFieldGuid={a26df613-595b-46ef-b5df-79f6eace72d9}}
Certificate Vault Id          : @{Value=442493; CustomFieldGuid=}
Consumers                     : @{Value=System.Object\[\]; CustomFieldGuid=}
Created By                    : @{Value=WebAdmin; CustomFieldGuid=}
CSR Vault Id                  : @{Value=442492; CustomFieldGuid=}

Retrieve values directly set on an object, excluding values assigned by policy

### EXAMPLE 2
```
Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -Attribute 'Driver Name' -New
```

Name        : test.gdb.com
Path        : \VED\Policy\Certificates\test.gdb.com
TypeName    : X509 Server Certificate
Guid        : b7a7221b-e038-41d9-9d49-d7f45c1ca128
Driver Name : @{Value=appx509certificate; CustomFieldGuid=}

Retrieve the value for a specific attribute

### EXAMPLE 3
```
Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -Attribute 'ServiceNow Assignment Group' -New
```

Name                        : test.gdb.com
Path                        : \VED\Policy\Certificates\test.gdb.com
TypeName                    : X509 Server Certificate
Guid                        : b7a7221b-e038-41d9-9d49-d7f45c1ca199
ServiceNow Assignment Group : @{Value=Venafi Management; CustomFieldGuid={7f214dec-9878-495f-a96c-57291f0d42da}}

Retrieve the value for a custom field.
You can specify either the guid or custom field label name.

### EXAMPLE 4
```
Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -Attribute 'Organization','State' -Effective -New
```

Name         : test.gdb.com
Path         : \VED\Policy\Certificates\test.gdb.com
TypeName     : X509 Server Certificate
Guid         : b7a7221b-e038-41d9-9d49-d7f45c1ca128
Organization : @{Value=Venafi, Inc.; CustomFieldGuid=; Overridden=False; Locked=True;
            PolicyPath=\VED\Policy\Certificates}
State        : @{Value=UT; CustomFieldGuid=; Overridden=False; Locked=False; PolicyPath=\VED\Policy\Certificates}

Retrieve the effective (policy applied) value for a specific attribute(s).
This not only returns the value, but also the path where the policy is applied and if locked or overridden.

### EXAMPLE 5
```
Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -Effective -All -New
```

Name                                               : test.gdb.com
Path                                               : \VED\Policy\certificates\test.gdb.com
TypeName                                           : X509 Server Certificate
ServiceNow Assignment Group                        : @{Value=Venafi Management;
                                                    CustomFieldGuid={7f214dec-9878-495f-a96c-57291f0d42da};
                                                    Overridden=False; Locked=False; PolicyPath=}
ServiceNow CI                                      : @{Value=9cc047ed1bad81100774ebd1b24bcbd0;
                                                    CustomFieldGuid={a26df613-595b-46ef-b5df-79f6eace72d9};
                                                    Overridden=False; Locked=False; PolicyPath=}
ACME Account DN                                    :
Adaptable CA:Binary Data Vault ID                  :
Adaptable CA:Early Password Vault ID               :
Adaptable CA:Early Pkcs7 Vault ID                  :
Adaptable CA:Early Private Key Vault ID            :

Retrieve the effective (policy applied) value for all attributes.
This not only returns the value, but also the path where the policy is applied and if locked or overridden.

### EXAMPLE 6
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

Retrieve values for all attributes applicable to this object

### EXAMPLE 7
```
Get-TppAttribute -Path '\VED\Policy\certificates' -PolicyClass 'X509 Certificate' -Attribute 'State' -New
```

Name            : certificates
Path            : \VED\Policy\certificates
TypeName        : Policy
Guid            : a91fc152-a9fb-4b49-a7ca-7014b14d73eb
PolicyClassName : X509 Certificate
State           : @{Value=UT; Locked=False}

Retrieve specific policy attribute values for the specified policy folder and class

### EXAMPLE 8
```
Get-TppAttribute -Path '\VED\Policy\certificates' -PolicyClass 'X509 Certificate' -All -New
```

Name                                               : certificates
Path                                               : \VED\Policy\certificates
TypeName                                           : Policy
PolicyClassName                                    : X509 Certificate
ServiceNow Assignment Group                        :
Certificate Authority                              :
Certificate Download: PBES2 Algorithm              :
Certificate Process Validator                      :
Certificate Vault Id                               :
City                                               : @{Value=Salt Lake City; Locked=False}

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
Parameter Sets: Policy, Effective
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
The output will contain the path where the policy was applied from.

```yaml
Type: SwitchParameter
Parameter Sets: AllEffective, Effective
Aliases: EffectivePolicy

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
Get all object attribute values.
This will perform 3 steps, get the object type, enumerate the attributes for the object type, and get all the values.
Note, expect this to take longer than usual given the number of api calls.

```yaml
Type: SwitchParameter
Parameter Sets: AllPolicy, AllEffective, AllByPath
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
Parameter Sets: AllPolicy, Policy
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
Parameter Sets: AllPolicy, Policy
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
Parameter Sets: ByPath, Policy, Effective
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

