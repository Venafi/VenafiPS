# New-VdcObject

## SYNOPSIS
Create a new object

## SYNTAX

```
New-VdcObject [-Path] <String> [-Class] <String> [[-Attribute] <Hashtable>] [-PushCertificate] [-Force]
 [-PassThru] [[-VenafiSession] <PSObject>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Generic use function to create a new object if a specific function hasn't been created yet for the class.

## EXAMPLES

### EXAMPLE 1
```
New-VdcObject -Path '\VED\Policy\Test Device' -Class 'Device' -Attribute @{'Description'='new device testing'}
```

Create a new object

### EXAMPLE 2
```
New-VdcObject -Path 'missing\folder\again' -Class 'Policy' -Force
```

Create a new object as well as any missing policy folders in the path

### EXAMPLE 3
```
New-VdcObject -Path '\VED\Policy\Test Device' -Class 'Device' -Attribute @{'Description'='new device testing'} -PassThru
```

Create a new object and return the resultant object

### EXAMPLE 4
```
New-VdcObject -Path '\VED\Policy\Test Device\App' -Class 'Basic' -Attribute @{'Driver Name'='appbasic';'Certificate'='\Ved\Policy\mycert.com'}
```

Create a new Basic application and associate it to a device and certificate

## PARAMETERS

### -Path
Full path, including name, for the object to be created.
If the root path is excluded, \ved\policy will be prepended.

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

### -Class
Class name of the new object.
See https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/SchemaReference/r-SDK-CNattributesWhere.php for more info.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Attribute
Hashtable with initial values for the new object.
These will be specific to the object class being created.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PushCertificate
If creating an application object, you can optionally push the certificate once the creation is complete.
Only available if a 'Certificate' key containing the certificate path is provided for Attribute.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: ProvisionCertificate

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Force the creation of missing parent policy folders when the class is either Policy or Device.

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

### -PassThru
Return a TppObject representing the newly created object.

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
A TLSPDC token can also be provided.
If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
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

### none
## OUTPUTS

### TppObject, if PassThru provided
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/New-VdcObject/](http://VenafiPS.readthedocs.io/en/latest/functions/New-VdcObject/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-VdcObject.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-VdcObject.ps1)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Add-VdcCertificateAssociation.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Add-VdcCertificateAssociation.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-create.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-create.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/SchemaReference/r-SDK-CNattributesWhere.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/SchemaReference/r-SDK-CNattributesWhere.php)

