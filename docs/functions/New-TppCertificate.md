# New-TppCertificate

## SYNOPSIS
Enrolls or provisions a new certificate

## SYNTAX

### ByName (Default)
```
New-TppCertificate -Path <String> -Name <String> [-CommonName <String>] [-CertificateType <String>]
 [-CertificateAuthorityPath <String>] [-ManagementType <TppManagementType>] [-SubjectAltName <Hashtable[]>]
 [-PassThru] [-TppSession <TppSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### BySubject
```
New-TppCertificate -Path <String> -CommonName <String> [-CertificateType <String>]
 [-CertificateAuthorityPath <String>] [-ManagementType <TppManagementType>] [-SubjectAltName <Hashtable[]>]
 [-PassThru] [-TppSession <TppSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Enrolls or provisions a new certificate

## EXAMPLES

### EXAMPLE 1
```
New-TppCertificate -Path '\ved\policy\folder' -Name 'mycert.com' -CertificateAuthorityDN '\ved\policy\CA Templates\my template'
```

Create certificate by name

### EXAMPLE 2
```
New-TppCertificate -Path '\ved\policy\folder' -CommonName 'mycert.com' -CertificateAuthorityDN '\ved\policy\CA Templates\my template' -PassThru
```

Create certificate using common name. 
Return the created object.

### EXAMPLE 3
```
New-TppCertificate -Path '\ved\policy\folder' -Name 'mycert.com' -CertificateAuthorityDN '\ved\policy\CA Templates\my template' -SubjectAltName @{'Email'='me@x.com'},@{'IPAddress'='1.2.3.4'}
```

Create certificate including subject alternate names

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
Parameter Sets: ByName
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
Parameter Sets: ByName
Aliases: Subject

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: BySubject
Aliases: Subject

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertificateType
Type of certificate to be created.
No value provided will default to X509 Server Certificate.
Valid values include 'Code Signing', 'Device', 'Server' (same as default), and 'User'.

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

### -PassThru
Return a TppObject representing the newly created certificate.

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
## NOTES

## RELATED LINKS

[http://venafitppps.readthedocs.io/en/latest/functions/New-TppCertificate/](http://venafitppps.readthedocs.io/en/latest/functions/New-TppCertificate/)

[https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/New-TppCertificate.ps1](https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/New-TppCertificate.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-request.php?tocpath=Web%20SDK%7CCertificates%20programming%20interface%7CPOST%20Certificates%252FRequest%7C_____0](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-request.php?tocpath=Web%20SDK%7CCertificates%20programming%20interface%7CPOST%20Certificates%252FRequest%7C_____0)

