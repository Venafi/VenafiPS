# Set-TppAttribute

## SYNOPSIS
Sets a value on an objects attribute or policies (policy attributes)

## SYNTAX

### NotPolicy (Default)
```
Set-TppAttribute -Path <String> -Attribute <Hashtable> [-BypassValidation] [-VenafiSession <PSObject>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Policy
```
Set-TppAttribute -Path <String> -Attribute <Hashtable> -Class <String> [-Lock] [-BypassValidation]
 [-VenafiSession <PSObject>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Set the value on an objects attribute. 
The attribute can either be built-in or custom.
You can also set policies (policy attributes).

## EXAMPLES

### EXAMPLE 1
```
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com' -Attribute @{'Consumers'='\VED\Policy\myappobject.company.com'}
```

Set the value on an object

### EXAMPLE 2
```
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com' -Attribute @{'Management Type'=$null}
```

Clear the value on an object, reverting to policy if applicable

### EXAMPLE 3
```
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com' -Attribute @{'My custom field Label'='new custom value'}
```

Set the value on a custom field

### EXAMPLE 4
```
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com' -Attribute @{'My custom field Label'='new custom value'} -BypassValidation
```

Set the value on a custom field bypassing field validation

### EXAMPLE 5
```
Set-TppAttribute -Path '\VED\Policy\My Folder' -Class 'X509 Certificate' -Attribute @{'Notification Disabled'='0'}
```

Set a policy attribute

### EXAMPLE 6
```
Set-TppAttribute -Path '\VED\Policy\My Folder' -Class 'X509 Certificate' -Attribute @{'Notification Disabled'='0'} -Lock
```

Set a policy attribute and lock the value

## PARAMETERS

### -Path
Path to the object to modify

```yaml
Type: String
Parameter Sets: (All)
Aliases: DN

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Attribute
Hashtable with names and values to be set.
If setting a custom field, you can use either the name or guid as the key.
To clear a value overwriting policy, set the value to $null.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Class
Required when setting policy attributes. 
Provide the class name to set the value for.
If unsure of the class name, add the value through the TPP UI and go to Support-\>Policy Attributes to find it.

```yaml
Type: String
Parameter Sets: Policy
Aliases: ClassName, PolicyClass

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Lock
Lock the value on the policy. 
Only applicable to setting policies.

```yaml
Type: SwitchParameter
Parameter Sets: Policy
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -BypassValidation
Bypass data validation. 
Only applicable to custom fields.

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Path
## OUTPUTS

### None
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppAttribute/](http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppAttribute/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Set-TppAttribute.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Set-TppAttribute.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-Set.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-Set.php)

[https://docs.venafi.com/Docs/currentSDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-SetPolicy.php](https://docs.venafi.com/Docs/currentSDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-SetPolicy.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-write.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-write.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-writepolicy.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-writepolicy.php)

