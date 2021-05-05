# Find-TppCertificate

## SYNOPSIS
Find certificates based on various attributes

## SYNTAX

### NoPath (Default)
```
Find-TppCertificate [-Limit <Int32>] [-Offset <Int32>] [-Country <String>] [-CommonName <String>]
 [-Issuer <String>] [-KeyAlgorithm <String[]>] [-KeySize <Int32[]>] [-KeySizeGreaterThan <Int32>]
 [-KeySizeLessThan <Int32>] [-Locale <String[]>] [-Organization <String[]>] [-OrganizationUnit <String[]>]
 [-State <String[]>] [-SanDns <String>] [-SanEmail <String>] [-SanIP <String>] [-SanUpn <String>]
 [-SanUri <String>] [-SerialNumber <String>] [-SignatureAlgorithm <String>] [-Thumbprint <String>]
 [-IssueDate <DateTime>] [-ExpireDate <DateTime>] [-ExpireAfter <DateTime>] [-ExpireBefore <DateTime>]
 [-Enabled] [-InError <Boolean>] [-NetworkValidationEnabled <Boolean>] [-CreatedDate <DateTime>]
 [-CreatedAfter <DateTime>] [-CreatedBefore <DateTime>] [-ManagementType <TppManagementType[]>]
 [-PendingWorkflow] [-Stage <TppCertificateStage[]>] [-StageGreaterThan <TppCertificateStage>]
 [-StageLessThan <TppCertificateStage>] [-ValidationEnabled] [-ValidationState <String[]>]
 [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### ByObject
```
Find-TppCertificate -InputObject <TppObject> [-Recursive] [-Limit <Int32>] [-Offset <Int32>]
 [-Country <String>] [-CommonName <String>] [-Issuer <String>] [-KeyAlgorithm <String[]>] [-KeySize <Int32[]>]
 [-KeySizeGreaterThan <Int32>] [-KeySizeLessThan <Int32>] [-Locale <String[]>] [-Organization <String[]>]
 [-OrganizationUnit <String[]>] [-State <String[]>] [-SanDns <String>] [-SanEmail <String>] [-SanIP <String>]
 [-SanUpn <String>] [-SanUri <String>] [-SerialNumber <String>] [-SignatureAlgorithm <String>]
 [-Thumbprint <String>] [-IssueDate <DateTime>] [-ExpireDate <DateTime>] [-ExpireAfter <DateTime>]
 [-ExpireBefore <DateTime>] [-Enabled] [-InError <Boolean>] [-NetworkValidationEnabled <Boolean>]
 [-CreatedDate <DateTime>] [-CreatedAfter <DateTime>] [-CreatedBefore <DateTime>]
 [-ManagementType <TppManagementType[]>] [-PendingWorkflow] [-Stage <TppCertificateStage[]>]
 [-StageGreaterThan <TppCertificateStage>] [-StageLessThan <TppCertificateStage>] [-ValidationEnabled]
 [-ValidationState <String[]>] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### ByPath
```
Find-TppCertificate -Path <String> [-Recursive] [-Limit <Int32>] [-Offset <Int32>] [-Country <String>]
 [-CommonName <String>] [-Issuer <String>] [-KeyAlgorithm <String[]>] [-KeySize <Int32[]>]
 [-KeySizeGreaterThan <Int32>] [-KeySizeLessThan <Int32>] [-Locale <String[]>] [-Organization <String[]>]
 [-OrganizationUnit <String[]>] [-State <String[]>] [-SanDns <String>] [-SanEmail <String>] [-SanIP <String>]
 [-SanUpn <String>] [-SanUri <String>] [-SerialNumber <String>] [-SignatureAlgorithm <String>]
 [-Thumbprint <String>] [-IssueDate <DateTime>] [-ExpireDate <DateTime>] [-ExpireAfter <DateTime>]
 [-ExpireBefore <DateTime>] [-Enabled] [-InError <Boolean>] [-NetworkValidationEnabled <Boolean>]
 [-CreatedDate <DateTime>] [-CreatedAfter <DateTime>] [-CreatedBefore <DateTime>]
 [-ManagementType <TppManagementType[]>] [-PendingWorkflow] [-Stage <TppCertificateStage[]>]
 [-StageGreaterThan <TppCertificateStage>] [-StageLessThan <TppCertificateStage>] [-ValidationEnabled]
 [-ValidationState <String[]>] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### ByGuid
```
Find-TppCertificate -Guid <Guid> [-Recursive] [-Limit <Int32>] [-Offset <Int32>] [-Country <String>]
 [-CommonName <String>] [-Issuer <String>] [-KeyAlgorithm <String[]>] [-KeySize <Int32[]>]
 [-KeySizeGreaterThan <Int32>] [-KeySizeLessThan <Int32>] [-Locale <String[]>] [-Organization <String[]>]
 [-OrganizationUnit <String[]>] [-State <String[]>] [-SanDns <String>] [-SanEmail <String>] [-SanIP <String>]
 [-SanUpn <String>] [-SanUri <String>] [-SerialNumber <String>] [-SignatureAlgorithm <String>]
 [-Thumbprint <String>] [-IssueDate <DateTime>] [-ExpireDate <DateTime>] [-ExpireAfter <DateTime>]
 [-ExpireBefore <DateTime>] [-Enabled] [-InError <Boolean>] [-NetworkValidationEnabled <Boolean>]
 [-CreatedDate <DateTime>] [-CreatedAfter <DateTime>] [-CreatedBefore <DateTime>]
 [-ManagementType <TppManagementType[]>] [-PendingWorkflow] [-Stage <TppCertificateStage[]>]
 [-StageGreaterThan <TppCertificateStage>] [-StageLessThan <TppCertificateStage>] [-ValidationEnabled]
 [-ValidationState <String[]>] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Find certificates based on various attributes

## EXAMPLES

### EXAMPLE 1
```
Find-TppCertificate -ExpireBefore "2018-01-01"
```

Find all certificates expiring before a certain date

### EXAMPLE 2
```
Find-TppCertificate -ExpireBefore "2018-01-01" -Limit 5
```

Find 5 certificates expiring before a certain date

### EXAMPLE 3
```
Find-TppCertificate -ExpireBefore "2018-01-01" -Limit 5 -Offset 2
```

Find 5 certificates expiring before a certain date, starting at the 3rd certificate found.

### EXAMPLE 4
```
Find-TppCertificate -Path '\VED\Policy\My Policy'
```

Find all certificates in a specific path

### EXAMPLE 5
```
Find-TppCertificate -Issuer 'CN=Example Root CA, O=Venafi,Inc., L=Salt Lake City, S=Utah, C=US'
```

Find all certificates by issuer

### EXAMPLE 6
```
Find-TppCertificate -Path '\VED\Policy\My Policy' -Recursive
```

Find all certificates in a specific path and all subfolders

### EXAMPLE 7
```
Find-TppCertificate -ExpireBefore "2018-01-01" -Limit 5 | Get-TppCertificateDetail
```

Get detailed certificate info on the first 5 certificates expiring before a certain date

### EXAMPLE 8
```
Find-TppCertificate -ExpireBefore "2019-09-01" | Invoke-TppCertificateRenewal
```

Renew all certificates expiring before a certain date

## PARAMETERS

### -InputObject
TppObject of type 'Policy' which represents a starting path

```yaml
Type: TppObject
Parameter Sets: ByObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
Starting path to search from

```yaml
Type: String
Parameter Sets: ByPath
Aliases: DN

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Guid
Guid which represents a starting path

```yaml
Type: Guid
Parameter Sets: ByGuid
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Recursive
Search recursively starting from the search path.

```yaml
Type: SwitchParameter
Parameter Sets: ByObject, ByPath, ByGuid
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
Limit how many items are returned. 
Default is 0 for no limit.
It is definitely recommended to filter on another property when searching with no limit.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Offset
The number of results to skip.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Country
Find certificates by Country attribute of Subject DN.

```yaml
Type: String
Parameter Sets: (All)
Aliases: C

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CommonName
Find certificates by Common name attribute of Subject DN.

```yaml
Type: String
Parameter Sets: (All)
Aliases: CN

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Issuer
Find certificates by issuer.
Use the CN, O, L, S, and C values from the certificate request.

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

### -KeyAlgorithm
Find certificates by algorithm for the public key.

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

### -KeySize
Find certificates by public key size.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeySizeGreaterThan
Find certificates with a key size greater than the specified value.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeySizeLessThan
Find certificates with a key size less than the specified value.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Locale
Find certificates by Locality/City attribute of Subject Distinguished Name (DN).

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: L

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Organization
Find certificates by Organization attribute of Subject DN.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: O

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OrganizationUnit
Find certificates by Organization Unit (OU).

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: OU

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -State
Find certificates by State/Province attribute of Subject DN.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: S

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SanDns
Find certificates by Subject Alternate Name (SAN) Distinguished Name Server (DNS).

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

### -SanEmail
Find certificates by SAN Email RFC822.

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

### -SanIP
Find certificates by SAN IP Address.

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

### -SanUpn
Find certificates by SAN User Principal Name (UPN) or OtherName.

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

### -SanUri
Find certificates by SAN Uniform Resource Identifier (URI).

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

### -SerialNumber
Find certificates by Serial number.

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

### -SignatureAlgorithm
Find certificates by the algorithm used to sign the certificate (e.g.
SHA1RSA).

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

### -Thumbprint
Find certificates by one or more SHA-1 thumbprints.

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

### -IssueDate
Find certificates by the date of issue.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: ValidFrom

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpireDate
Find certificates by expiration date.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: ValidTo

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpireAfter
Find certificates that expire after a certain date.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: ValidToGreater

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpireBefore
Find certificates that expire before a certain date.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: ValidToLess

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Enabled
Include only certificates that are enabled or disabled

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

### -InError
Only include certificates in an error state

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NetworkValidationEnabled
Only include certificates with network validation enabled or disabled

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreatedDate
Find certificates that were created at an exact date and time

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: CreatedOn

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreatedAfter
Find certificate created after this date and time

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: CreatedOnGreater

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreatedBefore
Find certificate created before this date and time

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: CreatedOnLess

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ManagementType
Find certificates with a Management type of Unassigned, Monitoring, Enrollment, or Provisioning

```yaml
Type: TppManagementType[]
Parameter Sets: (All)
Aliases:
Accepted values: Unassigned, Monitoring, Enrollment, Provisioning

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PendingWorkflow
Only include certificates that have a pending workflow resolution (have an outstanding workflow ticket)

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

### -Stage
Find certificates by one or more stages in the certificate lifecycle

```yaml
Type: TppCertificateStage[]
Parameter Sets: (All)
Aliases:
Accepted values: CheckStore, CreateConfigureStore, CreateKey, CreateCSR, PostCSR, ApproveRequest, RetrieveCertificate, InstallCertificate, CheckConfiguration, ConfigureApplication, RestartApplication, EndProcessing, Revocation, UpdateTrustStore, EndTrustStoreProcessing

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StageGreaterThan
Find certificates with a stage greater than the specified stage (does not include specified stage)

```yaml
Type: TppCertificateStage
Parameter Sets: (All)
Aliases: StageGreater
Accepted values: CheckStore, CreateConfigureStore, CreateKey, CreateCSR, PostCSR, ApproveRequest, RetrieveCertificate, InstallCertificate, CheckConfiguration, ConfigureApplication, RestartApplication, EndProcessing, Revocation, UpdateTrustStore, EndTrustStoreProcessing

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StageLessThan
Find certificates with a stage less than the specified stage (does not include specified stage)

```yaml
Type: TppCertificateStage
Parameter Sets: (All)
Aliases: StageLess
Accepted values: CheckStore, CreateConfigureStore, CreateKey, CreateCSR, PostCSR, ApproveRequest, RetrieveCertificate, InstallCertificate, CheckConfiguration, ConfigureApplication, RestartApplication, EndProcessing, Revocation, UpdateTrustStore, EndTrustStoreProcessing

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ValidationEnabled
Only include certificates with validation enabled or disabled

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

### -ValidationState
Find certificates with a validation state of Blank, Success, or Failure

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

### InputObject, Path, Guid
## OUTPUTS

### TppObject
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppCertificate/](http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppCertificate/)

[https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Find-TppCertificate.ps1](https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Find-TppCertificate.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates.php?tocpath=Web%20SDK%7CCertificates%20programming%20interface%7C_____4](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates.php?tocpath=Web%20SDK%7CCertificates%20programming%20interface%7C_____4)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates-guid.php?tocpath=Web%20SDK%7CCertificates%20programming%20interface%7C_____10](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates-guid.php?tocpath=Web%20SDK%7CCertificates%20programming%20interface%7C_____10)

[https://msdn.microsoft.com/en-us/library/system.web.httputility(v=vs.110).aspx](https://msdn.microsoft.com/en-us/library/system.web.httputility(v=vs.110).aspx)

