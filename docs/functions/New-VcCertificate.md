# New-VcCertificate

## SYNOPSIS
Create certificate request

## SYNTAX

### ASK (Default)
```
New-VcCertificate -Application <String> [-IssuingTemplate <String>] -CommonName <String>
 [-Organization <String>] [-OrganizationalUnit <String[]>] [-City <String>] [-State <String>]
 [-Country <String>] [-SanDns <String[]>] [-SanIP <String[]>] [-SanUri <String[]>] [-SanEmail <String[]>]
 [-ValidUntil <DateTime>] [-Tag <String[]>] [-PassThru] [-VenafiSession <PSObject>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### CSR
```
New-VcCertificate -Application <String> [-IssuingTemplate <String>] -Csr <String> [-SanDns <String[]>]
 [-SanIP <String[]>] [-SanUri <String[]>] [-SanEmail <String[]>] [-ValidUntil <DateTime>] [-Tag <String[]>]
 [-PassThru] [-VenafiSession <PSObject>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Create certificate request from automated secure keypair details or CSR

## EXAMPLES

### EXAMPLE 1
```
New-VcCertificate -Application 'MyApp' -IssuingTemplate 'MSCA - 1 year' -CommonName 'app.mycert.com'
```

Create certificate

### EXAMPLE 2
```
New-VcCertificate -Application 'MyApp' -IssuingTemplate 'MSCA - 1 year' -CommonName 'app.mycert.com' -Tag 'tag1','tag2:value'
```

Create certificate and associate 1 or more tags

### EXAMPLE 3
```
New-VcCertificate -Application 'MyApp' -CommonName 'app.mycert.com'
```

Create certificate with the template associated with the application.
This only works when only 1 template is associated with an application.

### EXAMPLE 4
```
New-VcCertificate -Application 'MyApp' -IssuingTemplate 'MSCA - 1 year' -CommonName 'app.mycert.com' -SanIP '1.2.3.4'
```

Create certificate with optional SAN data

### EXAMPLE 5
```
New-VcCertificate -Application 'MyApp' -IssuingTemplate 'MSCA - 1 year' -CommonName 'app.mycert.com' -ValidUntil (Get-Date).AddMonths(6)
```

Create certificate with specific validity

### EXAMPLE 6
```
New-VcCertificate -Application 'MyApp' -IssuingTemplate 'MSCA - 1 year' -CommonName 'app.mycert.com' -PassThru
```

Create certificate and return the created object

### EXAMPLE 7
```
New-VcCertificate -Application 'MyApp' -IssuingTemplate 'MSCA - 1 year' -Csr "-----BEGIN CERTIFICATE REQUEST-----\nMIICYzCCAUsCAQAwHj....BoiNIqtVQxFsfT+\n-----END CERTIFICATE REQUEST-----\n"
```

Create certificate by providing a CSR

## PARAMETERS

### -Application
Application name or id to associate this certificate with.

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

### -IssuingTemplate
Issuing template id, name, or alias.
The template must be associated with the provided Application.
If the application has only one template, this parameter is optional.

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

### -CommonName
Common name (CN). 
Required if not providing a CSR.

```yaml
Type: String
Parameter Sets: ASK
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Organization
The Organization field for the certificate Subject DN

```yaml
Type: String
Parameter Sets: ASK
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OrganizationalUnit
One or more departments or divisions within the organization that is responsible for maintaining the certificate

```yaml
Type: String[]
Parameter Sets: ASK
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -City
The City/Locality field for the certificate Subject DN

```yaml
Type: String
Parameter Sets: ASK
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -State
The State field for the certificate Subject DN

```yaml
Type: String
Parameter Sets: ASK
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Country
The Country field for the certificate Subject DN

```yaml
Type: String
Parameter Sets: ASK
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Csr
CSR in PKCS#10 format which conforms to the rules of the issuing template

```yaml
Type: String
Parameter Sets: CSR
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SanDns
One or more subject alternative name dns entries

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SanIP
One or more subject alternative name ip address entries

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SanUri
One or more subject alternative name uri entries

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SanEmail
One or more subject alternative name email entries

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ValidUntil
Date at which the certificate becomes invalid.
The day and hour will be set and not to the minute level.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tag
One or more tags to assign to the certificate at creation.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Return the certificate request.
If the certificate was successfully issued, it will be returned as the property 'certificate'.

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
A TLSPC key can also provided directly.

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

### CommonName
## OUTPUTS

### pscustomobject, if PassThru is provided
## NOTES

## RELATED LINKS

[https://developer.venafi.com/tlsprotectcloud/reference/certificaterequests_create](https://developer.venafi.com/tlsprotectcloud/reference/certificaterequests_create)

