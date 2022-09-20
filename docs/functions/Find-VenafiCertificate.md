# Find-VenafiCertificate

## SYNOPSIS
Find certificates in TPP or VaaS based on various attributes

## SYNTAX

### NoParams (Default)
```
Find-VenafiCertificate [-VenafiSession <PSObject>] [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>]
 [<CommonParameters>]
```

### TPP
```
Find-VenafiCertificate [-Path <String>] [-Guid <Guid>] [-Recursive] [-Limit <Int32>] [-Offset <Int32>]
 [-Country <String>] [-CommonName <String>] [-Issuer <String>] [-KeyAlgorithm <String[]>] [-KeySize <Int32[]>]
 [-KeySizeGreaterThan <Int32>] [-KeySizeLessThan <Int32>] [-Locale <String[]>] [-Organization <String[]>]
 [-OrganizationUnit <String[]>] [-State <String[]>] [-SanDns <String>] [-SanEmail <String>] [-SanIP <String>]
 [-SanUpn <String>] [-SanUri <String>] [-SerialNumber <String>] [-SignatureAlgorithm <String>]
 [-Thumbprint <String>] [-IssueDate <DateTime>] [-ExpireDate <DateTime>] [-ExpireAfter <DateTime>]
 [-ExpireBefore <DateTime>] [-Enabled] [-InError <Boolean>] [-NetworkValidationEnabled <Boolean>]
 [-CreatedDate <DateTime>] [-CreatedAfter <DateTime>] [-CreatedBefore <DateTime>] [-CertificateType <String[]>]
 [-ManagementType <TppManagementType[]>] [-PendingWorkflow] [-Stage <TppCertificateStage[]>]
 [-StageGreaterThan <TppCertificateStage>] [-StageLessThan <TppCertificateStage>] [-ValidationEnabled]
 [-ValidationState <String[]>] [-CountOnly] [-VenafiSession <PSObject>] [-IncludeTotalCount] [-Skip <UInt64>]
 [-First <UInt64>] [<CommonParameters>]
```

### VaaS
```
Find-VenafiCertificate [-Filter <ArrayList>] [-Order <PSObject[]>] [-IncludeVaasOwner]
 [-VenafiSession <PSObject>] [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>] [<CommonParameters>]
```

## DESCRIPTION
Find certificates based on various attributes.
Supports standard PS paging parameters First, Skip, and IncludeTotalCount.
If -First or -IncludeTotalCount not provided, the default return is 1000 records.

## EXAMPLES

### EXAMPLE 1
```
Find-VenafiCertificate
```

Find first 1000 certificates

### EXAMPLE 2
```
Find-VenafiCertificate -ExpireBefore [datetime]'2018-01-01'
```

Find certificates expiring before a certain date

### EXAMPLE 3
```
Find-VenafiCertificate -ExpireBefore "2018-01-01" -First 5
```

Find 5 certificates expiring before a certain date

### EXAMPLE 4
```
Find-VenafiCertificate -ExpireBefore "2018-01-01" -First 5 -Skip 2
```

Find 5 certificates expiring before a certain date, starting at the 3rd certificate found.
Skip is only supported on TPP.

### EXAMPLE 5
```
Find-VenafiCertificate -Path '\VED\Policy\My Policy'
```

Find certificates in a specific path

### EXAMPLE 6
```
Find-VenafiCertificate -Issuer 'CN=Example Root CA, O=Venafi,Inc., L=Salt Lake City, S=Utah, C=US'
```

Find certificates by issuer

### EXAMPLE 7
```
Find-VenafiCertificate -Path '\VED\Policy\My Policy' -Recursive
```

Find certificates in a specific path and all subfolders

### EXAMPLE 8
```
Find-VenafiCertificate | Get-VenafiCertificate
```

Get detailed certificate info

### EXAMPLE 9
```
Find-VenafiCertificate -ExpireBefore "2019-09-01" -IncludeTotalCount | Invoke-VenafiCertificateAction -Renew
```

Renew all certificates expiring before a certain date

### EXAMPLE 10
```
Find-VenafiCertificate -IncludeTotalCount
```

Find all certificates, paging 1000 at a time

### EXAMPLE 11
```
Find-VenafiCertificate -First 500 -IncludeTotalCount
```

Find all certificates, paging 500 at a time

### EXAMPLE 12
```
Find-VenafiCertificate -Filter @('fingerprint', 'EQ', '075C43428E70BCF941039F54B8ED78DE4FACA87F')
```

Find VaaS certificates matching a single value

### EXAMPLE 13
```
Find-VenafiCertificate -Filter ('and', @('validityEnd','GTE',(get-date)), @('validityEnd','LTE',(get-date).AddDays(30)))
```

Find VaaS certificates matching multiple values. 
In this case, find all certificates expiring in the next 30 days.

### EXAMPLE 14
```
Find-VenafiCertificate -IncludeVaasOwner
```

When finding VaaS certificates, include user/team owner information.
This will make additional api calls and will increase the response time.

## PARAMETERS

### -Path
Starting path to search from. 
If not provided, the default is \ved\policy. 
TPP only.

```yaml
Type: String
Parameter Sets: TPP
Aliases: DN

Required: False
Position: Named
Default value: \ved\policy
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Guid
Guid which represents a starting path. 
TPP only.

```yaml
Type: Guid
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recursive
Search recursively starting from the search path. 
TPP only.

```yaml
Type: SwitchParameter
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
{{ Fill Limit Description }}

```yaml
Type: Int32
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: 1000
Accept pipeline input: False
Accept wildcard characters: False
```

### -Offset
{{ Fill Offset Description }}

```yaml
Type: Int32
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Country
Find certificates by Country attribute of Subject DN. 
TPP only.

```yaml
Type: String
Parameter Sets: TPP
Aliases: C

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CommonName
Find certificates by Common name attribute of Subject DN. 
TPP only.

```yaml
Type: String
Parameter Sets: TPP
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
TPP only.

```yaml
Type: String
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeyAlgorithm
Find certificates by algorithm for the public key. 
TPP only.

```yaml
Type: String[]
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeySize
Find certificates by public key size. 
TPP only.

```yaml
Type: Int32[]
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeySizeGreaterThan
Find certificates with a key size greater than the specified value. 
TPP only.

```yaml
Type: Int32
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeySizeLessThan
Find certificates with a key size less than the specified value. 
TPP only.

```yaml
Type: Int32
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Locale
Find certificates by Locality/City attribute of Subject Distinguished Name (DN). 
TPP only.

```yaml
Type: String[]
Parameter Sets: TPP
Aliases: L

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Organization
Find certificates by Organization attribute of Subject DN. 
TPP only.

```yaml
Type: String[]
Parameter Sets: TPP
Aliases: O

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OrganizationUnit
Find certificates by Organization Unit (OU). 
TPP only.

```yaml
Type: String[]
Parameter Sets: TPP
Aliases: OU

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -State
Find certificates by State/Province attribute of Subject DN. 
TPP only.

```yaml
Type: String[]
Parameter Sets: TPP
Aliases: S

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SanDns
Find certificates by Subject Alternate Name (SAN) Distinguished Name Server (DNS). 
TPP only.

```yaml
Type: String
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SanEmail
Find certificates by SAN Email RFC822. 
TPP only.

```yaml
Type: String
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SanIP
Find certificates by SAN IP Address. 
TPP only.

```yaml
Type: String
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SanUpn
Find certificates by SAN User Principal Name (UPN) or OtherName. 
TPP only.

```yaml
Type: String
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SanUri
Find certificates by SAN Uniform Resource Identifier (URI). 
TPP only.

```yaml
Type: String
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SerialNumber
Find certificates by Serial number. 
TPP only.

```yaml
Type: String
Parameter Sets: TPP
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
TPP only.

```yaml
Type: String
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Thumbprint
Find certificates by one or more SHA-1 thumbprints. 
TPP only.

```yaml
Type: String
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IssueDate
Find certificates by the date of issue. 
TPP only.

```yaml
Type: DateTime
Parameter Sets: TPP
Aliases: ValidFrom

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpireDate
Find certificates by expiration date. 
TPP only.

```yaml
Type: DateTime
Parameter Sets: TPP
Aliases: ValidTo

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpireAfter
Find certificates that expire after a certain date. 
TPP only.

```yaml
Type: DateTime
Parameter Sets: TPP
Aliases: ValidToGreater

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpireBefore
Find certificates that expire before a certain date. 
TPP only.

```yaml
Type: DateTime
Parameter Sets: TPP
Aliases: ValidToLess

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Enabled
Include only certificates that are enabled or disabled. 
TPP only.

```yaml
Type: SwitchParameter
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -InError
Only include certificates in an error state. 
TPP only.

```yaml
Type: Boolean
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NetworkValidationEnabled
Only include certificates with network validation enabled or disabled. 
TPP only.

```yaml
Type: Boolean
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreatedDate
Find certificates that were created at an exact date and time. 
TPP only.

```yaml
Type: DateTime
Parameter Sets: TPP
Aliases: CreatedOn

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreatedAfter
Find certificate created after this date and time. 
TPP only.

```yaml
Type: DateTime
Parameter Sets: TPP
Aliases: CreatedOnGreater

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreatedBefore
Find certificate created before this date and time. 
TPP only.

```yaml
Type: DateTime
Parameter Sets: TPP
Aliases: CreatedOnLess

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertificateType
Find certificate by category of usage.
Use CodeSigning, Device, Server, and/or User. 
TPP only.

```yaml
Type: String[]
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ManagementType
Find certificates with a Management type of Unassigned, Monitoring, Enrollment, or Provisioning. 
TPP only.

```yaml
Type: TppManagementType[]
Parameter Sets: TPP
Aliases:
Accepted values: Unassigned, Monitoring, Enrollment, Provisioning

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PendingWorkflow
Only include certificates that have a pending workflow resolution (have an outstanding workflow ticket). 
TPP only.

```yaml
Type: SwitchParameter
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Stage
Find certificates by one or more stages in the certificate lifecycle. 
TPP only.

```yaml
Type: TppCertificateStage[]
Parameter Sets: TPP
Aliases:
Accepted values: CheckStore, CreateConfigureStore, CreateKey, CreateCSR, PostCSR, ApproveRequest, RetrieveCertificate, InstallCertificate, CheckConfiguration, ConfigureApplication, RestartApplication, EndProcessing, Revocation, UpdateTrustStore, EndTrustStoreProcessing

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StageGreaterThan
Find certificates with a stage greater than the specified stage (does not include specified stage). 
TPP only.

```yaml
Type: TppCertificateStage
Parameter Sets: TPP
Aliases: StageGreater
Accepted values: CheckStore, CreateConfigureStore, CreateKey, CreateCSR, PostCSR, ApproveRequest, RetrieveCertificate, InstallCertificate, CheckConfiguration, ConfigureApplication, RestartApplication, EndProcessing, Revocation, UpdateTrustStore, EndTrustStoreProcessing

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StageLessThan
Find certificates with a stage less than the specified stage (does not include specified stage). 
TPP only.

```yaml
Type: TppCertificateStage
Parameter Sets: TPP
Aliases: StageLess
Accepted values: CheckStore, CreateConfigureStore, CreateKey, CreateCSR, PostCSR, ApproveRequest, RetrieveCertificate, InstallCertificate, CheckConfiguration, ConfigureApplication, RestartApplication, EndProcessing, Revocation, UpdateTrustStore, EndTrustStoreProcessing

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ValidationEnabled
Only include certificates with validation enabled or disabled. 
TPP only.

```yaml
Type: SwitchParameter
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ValidationState
Find certificates with a validation state of Blank, Success, or Failure. 
TPP only.

```yaml
Type: String[]
Parameter Sets: TPP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
VaaS. 
Array or multidimensional array of fields and values to filter on.
Each array should be of the format @(field, comparison operator, value).
To combine filters use the format @('operator', @(field, comparison operator, value), @(field2, comparison operator2, value2)).
Nested filters are supported.
Field names and values are case sensitive.
For a complete list of comparison operators, see https://docs.venafi.cloud/api/about-api-search-operators/.

```yaml
Type: ArrayList
Parameter Sets: VaaS
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Order
VaaS. 
Array of fields to order on.
For each item in the array, you can provide a field name by itself; this will default to ascending.
You can also provide a hashtable with the field name as the key and either asc or desc as the value.

```yaml
Type: PSObject[]
Parameter Sets: VaaS
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeVaasOwner
Retrieve detailed user/team owner info, only for VaaS.
This will cause additional api calls to be made and take longer.

```yaml
Type: SwitchParameter
Parameter Sets: VaaS
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CountOnly
Return the count of certificates found from the query as opposed to the certificates themselves

```yaml
Type: SwitchParameter
Parameter Sets: TPP
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

### -IncludeTotalCount
Reports the total number of objects in the data set (an integer) followed by the selected objects.
If the cmdlet cannot determine the total count, it displays "Unknown total count." The integer has an Accuracy property that indicates the reliability of the total count value.
The value of Accuracy ranges from 0.0 to 1.0 where 0.0 means that the cmdlet could not count the objects, 1.0 means that the count is exact, and a value between 0.0 and 1.0 indicates an increasingly reliable estimate.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Skip
Ignores the specified number of objects and then gets the remaining objects.
Enter the number of objects to skip.

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -First
Gets only the specified number of objects.
Enter the number of objects to get.

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases:

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

### TPP: TppObject, Int when CountOnly provided
### VaaS: PSCustomObject
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Find-VenafiCertificate/](http://VenafiPS.readthedocs.io/en/latest/functions/Find-VenafiCertificate/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-VenafiCertificate.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-VenafiCertificate.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates-guid.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates-guid.php)

[https://msdn.microsoft.com/en-us/library/system.web.httputility(v=vs.110).aspx](https://msdn.microsoft.com/en-us/library/system.web.httputility(v=vs.110).aspx)

[https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Certificates/certificates_search_getByExpressionAsCsv](https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Certificates/certificates_search_getByExpressionAsCsv)

