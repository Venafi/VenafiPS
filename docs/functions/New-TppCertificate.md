# New-TppCertificate

## SYNOPSIS
Enrolls or provisions a new certificate

## SYNTAX

### ByName (Default)
```
New-TppCertificate -Path <String> -Name <String> [-CommonName <String>] [-Csr <String>]
 [-CertificateType <String>] [-CertificateAuthorityPath <String>] [-CertificateAuthorityAttribute <Hashtable>]
 [-ManagementType <TppManagementType>] [-SubjectAltName <Hashtable[]>] [-CustomField <Hashtable>] [-NoWorkToDo]
 [-Device <Hashtable[]>] [-PassThru] [-VenafiSession <VenafiSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByNameWithDevice
```
New-TppCertificate -Path <String> -Name <String> [-CommonName <String>] [-Csr <String>]
 [-CertificateType <String>] [-CertificateAuthorityPath <String>] [-CertificateAuthorityAttribute <Hashtable>]
 [-ManagementType <TppManagementType>] [-SubjectAltName <Hashtable[]>] [-CustomField <Hashtable>] [-NoWorkToDo]
 -Device <Hashtable[]> [-Application <Hashtable[]>] [-PassThru] [-VenafiSession <VenafiSession>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### BySubjectWithDevice
```
New-TppCertificate -Path <String> -CommonName <String> [-Csr <String>] [-CertificateType <String>]
 [-CertificateAuthorityPath <String>] [-CertificateAuthorityAttribute <Hashtable>]
 [-ManagementType <TppManagementType>] [-SubjectAltName <Hashtable[]>] [-CustomField <Hashtable>] [-NoWorkToDo]
 -Device <Hashtable[]> [-Application <Hashtable[]>] [-PassThru] [-VenafiSession <VenafiSession>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### BySubject
```
New-TppCertificate -Path <String> -CommonName <String> [-Csr <String>] [-CertificateType <String>]
 [-CertificateAuthorityPath <String>] [-CertificateAuthorityAttribute <Hashtable>]
 [-ManagementType <TppManagementType>] [-SubjectAltName <Hashtable[]>] [-CustomField <Hashtable>] [-NoWorkToDo]
 [-Device <Hashtable[]>] [-PassThru] [-VenafiSession <VenafiSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Enrolls or provisions a new certificate

## EXAMPLES

### EXAMPLE 1
```
New-TppCertificate -Path '\ved\policy\folder' -Name 'mycert.com' -CertificateAuthorityDN '\ved\policy\CA Templates\my template'
Create certificate by name
```

### EXAMPLE 2
```
New-TppCertificate -Path '\ved\policy\folder' -CertificateAuthorityDN '\ved\policy\CA Templates\my template' -Csr '-----BEGIN CERTIFICATE REQUEST-----\nMIIDJDCCAgwCAQAw...-----END CERTIFICATE REQUEST-----'
Create certificate using a CSR
```

### EXAMPLE 3
```
New-TppCertificate -Path '\ved\policy\folder' -Name 'mycert.com' -CertificateAuthorityDN '\ved\policy\CA Templates\my template' -CustomField @{''=''}
Create certificate and update custom fields
```

### EXAMPLE 4
```
New-TppCertificate -Path '\ved\policy\folder' -CommonName 'mycert.com' -CertificateAuthorityDN '\ved\policy\CA Templates\my template' -PassThru
Create certificate using common name.  Return the created object.
```

### EXAMPLE 5
```
New-TppCertificate -Path '\ved\policy\folder' -Name 'mycert.com' -CertificateAuthorityDN '\ved\policy\CA Templates\my template' -SubjectAltName @{'Email'='me@x.com'},@{'IPAddress'='1.2.3.4'}
Create certificate including subject alternate names
```

### EXAMPLE 6
```
New-TppCertificate -Path '\ved\policy\folder' -Name 'mycert.com' -Device @{'PolicyDN'=$DevicePath; 'ObjectName'='MyDevice'; 'Host'='1.2.3.4'} -Application @{'DeviceName'='MyDevice'; 'ObjectName'='BasicApp'; 'DriverName'='appbasic'}
Create a new certificate with associated device and app objects
```

## PARAMETERS

### -Path
The folder DN path for the new certificate.
If the value is missing, use the system default

```yaml
Type: String
Parameter Sets: (All)
Aliases: PolicyDN

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Name of the certifcate. 
If not provided, the name will be the same as the subject.

```yaml
Type: String
Parameter Sets: ByName, ByNameWithDevice
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -CommonName
Subject Common Name. 
If Name isn't provided, CommonName will be used.

```yaml
Type: String
Parameter Sets: ByName, ByNameWithDevice
Aliases: Subject

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: BySubjectWithDevice, BySubject
Aliases: Subject

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Csr
The PKCS#10 Certificate Signing Request (CSR).
If this value is provided, any Subject DN fields and the KeyBitSize in the request are ignored.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertificateType
Type of certificate to be created.
No value provided will default to X.509 Server Certificate.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertificateAuthorityPath
{{ Fill CertificateAuthorityPath Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: CADN, CertificateAuthorityDN

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertificateAuthorityAttribute
Name/value pairs providing any CA attributes to store with the Certificate object.
During enrollment, these values will be submitted to the CA.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ManagementType
The level of management that Trust Protection Platform applies to the certificate:
- Enrollment: Default.
Issue a new certificate, renewed certificate, or key generation request to a CA for enrollment.
Do not automatically provision the certificate.
- Provisioning:  Issue a new certificate, renewed certificate, or key generation request to a CA for enrollment.
Automatically install or provision the certificate.
- Monitoring:  Allow Trust Protection Platform to monitor the certificate for expiration and renewal.
- Unassigned: Certificates are neither enrolled or monitored by Trust Protection Platform.

```yaml
Type: TppManagementType
Parameter Sets: (All)
Aliases:
Accepted values: Unassigned, Monitoring, Enrollment, Provisioning

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubjectAltName
A list of Subject Alternate Names.
The value must be 1 or more hashtables with the SAN type and value.
Acceptable SAN types are OtherName, Email, DNS, URI, and IPAddress.
You can provide more than 1 of the same SAN type with multiple hashtables.

```yaml
Type: Hashtable[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CustomField
Hashtable of custom field(s) to be updated when creating the certificate.
This is required when the custom fields are mandatory.
The key is the name, not guid, of the custom field.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoWorkToDo
Turn off lifecycle processing for this certificate update

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

### -Device
An array of hashtables for devices to be created.
Available parameters can be found at https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-request.php.
If provisioning applications as well, those should be provided with the Application parameter.

```yaml
Type: Hashtable[]
Parameter Sets: ByName, BySubject
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: Hashtable[]
Parameter Sets: ByNameWithDevice, BySubjectWithDevice
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Application
An array of hashtables for applications to be created.
Available parameters can be found at https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-request-ApplicationsParameter.php.
In addition to the application parameters, a key/value must be provided for the associated device.
The key needs to be 'DeviceName' and the value is the ObjectName from the device.
See the example.

```yaml
Type: Hashtable[]
Parameter Sets: ByNameWithDevice, BySubjectWithDevice
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Return a TppObject representing the newly created certificate.
If devices and/or applications were created, a 'Device' property will be available as well.

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

### None
## OUTPUTS

### TppObject, if PassThru is provided
### If devices and/or applications were created, a 'Device' property will be available as well.
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/New-TppCertificate/](http://VenafiPS.readthedocs.io/en/latest/functions/New-TppCertificate/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-TppCertificate.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-TppCertificate.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-request.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-request.php)

