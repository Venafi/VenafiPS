# Import-VaasCertificate

## SYNOPSIS
Import one or more certificates

## SYNTAX

### ByFile (Default)
```
Import-VaasCertificate -CertificatePath <String[]> [-Application <String[]>] [-PassThru]
 [-VenafiSession <PSObject>] [<CommonParameters>]
```

### ByData
```
Import-VaasCertificate -CertificateData <String[]> [-Application <String[]>] [-PassThru]
 [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Import one or more certificates.
The blocklist will be overridden.

## EXAMPLES

### EXAMPLE 1
```
Import-VaasCertificate -CertificatePath c:\www.VenafiPS.com.cer
```

Import a certificate

### EXAMPLE 2
```
Import-VaasCertificate -CertificatePath c:\www.VenafiPS.com.cer -Application MyApp
```

Import a certificate and assign an application

### EXAMPLE 3
```
Import-VaasCertificate -CertificatePath (gci c:\certs).FullName
```

Import multiple certificates

### EXAMPLE 4
```
Export-VenafiCertificate -CertificateId '\ved\policy\my.cert.com' -Format Base64 | Import-VaasCertificate -VenafiSession $vaas_key
```

Export from TPP and import into VaaS.
As $VenafiSession can only point to one platform at a time, in this case TPP, the session needs to be overridden for the import.

### EXAMPLE 5
```
Find-TppCertificate -Path '\ved\policy\certs' -Recursive | Export-VenafiCertificate -Format Base64 | Import-VaasCertificate -VenafiSession $vaas_key
```

Bulk export from TPP and import into VaaS.
As $VenafiSession can only point to one platform at a time, in this case TPP, the session needs to be overridden for the import.

## PARAMETERS

### -CertificatePath
Path to a certificate file. 
Provide either this or CertificateData.

```yaml
Type: String[]
Parameter Sets: ByFile
Aliases: FullName

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CertificateData
Contents of a certificate to import. 
Provide either this or CertificatePath.

```yaml
Type: String[]
Parameter Sets: ByData
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Application
Application name (wildcards supported) or id to associate this certificate.

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
Return imported certificate details

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
A VaaS key can also provided.

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

### CertificatePath, CertificateData
## OUTPUTS

### PSCustomObject, if PassThru provided
## NOTES

## RELATED LINKS

[https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Certificates/certificateimports_create](https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Certificates/certificateimports_create)

