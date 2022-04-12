# Import-TppCertificate

## SYNOPSIS
Import a certificate

## SYNTAX

### ByFile (Default)
```
Import-TppCertificate -PolicyPath <String> -CertificatePath <String> [-Name <String>]
 [-EnrollmentAttribute <Hashtable>] [-Password <SecureString>] [-Reconcile] [-PassThru]
 [-VenafiSession <PSObject>] [<CommonParameters>]
```

### ByFileWithPrivateKey
```
Import-TppCertificate -PolicyPath <String> -CertificatePath <String> [-Name <String>]
 [-EnrollmentAttribute <Hashtable>] -PrivateKey <String> -Password <SecureString> [-Reconcile] [-PassThru]
 [-VenafiSession <PSObject>] [<CommonParameters>]
```

### ByDataWithPrivateKey
```
Import-TppCertificate -PolicyPath <String> -CertificateData <String> [-Name <String>]
 [-EnrollmentAttribute <Hashtable>] -PrivateKey <String> -Password <SecureString> [-Reconcile] [-PassThru]
 [-VenafiSession <PSObject>] [<CommonParameters>]
```

### ByData
```
Import-TppCertificate -PolicyPath <String> -CertificateData <String> [-Name <String>]
 [-EnrollmentAttribute <Hashtable>] [-Password <SecureString>] [-Reconcile] [-PassThru]
 [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Import a certificate with or without private key.

## EXAMPLES

### EXAMPLE 1
```
Import-TppCertificate -PolicyPath \ved\policy\mycerts -CertificatePath c:\www.VenafiPS.com.cer
Import a certificate
```

## PARAMETERS

### -PolicyPath
Policy path to import the certificate to

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

### -CertificatePath
Path to a certificate file. 
Provide either this or CertificateData.

```yaml
Type: String
Parameter Sets: ByFile, ByFileWithPrivateKey
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertificateData
Contents of a certificate to import. 
Provide either this or CertificatePath.

```yaml
Type: String
Parameter Sets: ByDataWithPrivateKey, ByData
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Optional name for the certificate object.
If not provided, the certificate Common Name (CN) is used.
The derived certificate object name references an existing object (of any class).
If another certificate has the same CN, a dash (-) integer appends to the CertificateDN.
For example, test.venafi.example - 3.
If not provided and the CN is also missing, the name becomes the first Domain Name System (DNS) Subject Alternative Name (SAN).
Finally, if none of the above are found, the serial number is used.

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

### -EnrollmentAttribute
A hashtable providing any CA attributes to store with the Certificate object, and then submit to the CA during enrollment

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

### -PrivateKey
Private key data; requires a value for Password.
For a PEM certificate, the private key is in either the RSA or PKCS#8 format.
Do not provide for a PKCS#12 certificate as the private key is already included.

```yaml
Type: String
Parameter Sets: ByFileWithPrivateKey, ByDataWithPrivateKey
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Password
Password required if the certificate has a private key.

```yaml
Type: SecureString
Parameter Sets: ByFile, ByData
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: SecureString
Parameter Sets: ByFileWithPrivateKey, ByDataWithPrivateKey
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Reconcile
Controls certificate and corresponding private key replacement.
By default, this function will import and replace the certificate regardless of whether a past, future, or same version of the certificate exists in Trust Protection Platform.
By using this parameter, this function will import, but use newest.
Only import the certificate when no Certificate object exists with a past, present, or current version of the imported certificate.
If a match is found between the Certificate object and imported certificate, activate the certificate with the most current 'Valid From' date.
Archive the unused certificate, even if it is the imported certificate, to the History tab.
See https://github.com/Venafi/VenafiPS/issues/88#issuecomment-600134145 for a flowchart of the reconciliation algorithm.

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
Return a TppObject representing the newly imported object.

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
If providing a TPP token, an environment variable named TppServer must also be set.

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

### None
## OUTPUTS

### TppObject, if PassThru provided
## NOTES

## RELATED LINKS

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Import.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Import.php)

