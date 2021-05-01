# Get-TppCertificateDetail

## SYNOPSIS
Get detailed certificate information

## SYNTAX

### ByObject
```
Get-TppCertificateDetail -InputObject <TppObject> [-TppSession <TppSession>] [<CommonParameters>]
```

### ByPath
```
Get-TppCertificateDetail -Path <String> [-TppSession <TppSession>] [<CommonParameters>]
```

### ByGuid
```
Get-TppCertificateDetail -Guid <Guid> [-TppSession <TppSession>] [<CommonParameters>]
```

## DESCRIPTION
Get detailed certificate information

## EXAMPLES

### EXAMPLE 1
```
$cert | Get-TppCertificateDetail
```

Get detailed certificate info via pipeline

## PARAMETERS

### -InputObject
TppObject which represents a unique certificate

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
Path to a certificate

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
Guid representing a certificate

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### InputObject, Path, Guid
## OUTPUTS

### PSCustomObject with the following properties:
###     Name
###     TypeName
###     Path
###     Guid
###     ParentPath
###     Approver
###     CertificateAuthorityDN
###     CertificateDetails
###     Contact
###     CreatedOn
###     CustomFields
###     ManagementType
###     ProcessingDetails
###     RenewalDetails
###     ValidationDetails
## NOTES

## RELATED LINKS

[http://venafitppps.readthedocs.io/en/latest/functions/Get-TppCertificateDetail/](http://venafitppps.readthedocs.io/en/latest/functions/Get-TppCertificateDetail/)

[https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Get-TppCertificateDetail.ps1](https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Get-TppCertificateDetail.ps1)

[https://docs.venafi.com/Docs/20.3SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates-guid.php?tocpath=Web%20SDK%20reference%7CCertificates%20programming%20interface%7C_____10](https://docs.venafi.com/Docs/20.3SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates-guid.php?tocpath=Web%20SDK%20reference%7CCertificates%20programming%20interface%7C_____10)

[https://msdn.microsoft.com/en-us/library/system.web.httputility(v=vs.110).aspx](https://msdn.microsoft.com/en-us/library/system.web.httputility(v=vs.110).aspx)

