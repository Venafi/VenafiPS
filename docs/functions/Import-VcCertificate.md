# Import-VcCertificate

## SYNOPSIS
Import one or more certificates

## SYNTAX

### ByFile (Default)
```
Import-VcCertificate -Path <String> -PrivateKeyPassword <PSObject> [-ThrottleLimit <Int32>]
 [-VenafiSession <PSObject>] [<CommonParameters>]
```

### Pkcs8
```
Import-VcCertificate -Data <String> [-Pkcs8] -PrivateKeyPassword <PSObject> [-ThrottleLimit <Int32>]
 [-VenafiSession <PSObject>] [<CommonParameters>]
```

### Pkcs12
```
Import-VcCertificate -Data <String> [-Pkcs12] -PrivateKeyPassword <PSObject> [-ThrottleLimit <Int32>]
 [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Import one or more certificates and their private keys. 
Currently PKCS #8 and PKCS #12 (.pfx or .p12) are supported.

## EXAMPLES

### EXAMPLE 1
```
Import-VcCertificate -CertificatePath c:\www.VenafiPS.com.pfx
```

Import a certificate/key

### EXAMPLE 2
```
$p12 = Export-VdcCertificate -Path '\ved\policy\my.cert.com' -Pkcs12 -PrivateKeyPassword 'myPassw0rd!'
$p12 | Import-VcCertificate -Pkcs12 -PrivateKeyPassword 'myPassw0rd!' -VenafiSession $vaas_key
```

Export from TLSPDC and import into TLSPC.
As $VenafiSession can only point to one platform at a time, in this case TLSPDC, the session needs to be overridden for the import.

### EXAMPLE 3
```
$p12 = Find-VdcCertificate -Path '\ved\policy\certs' -Recursive | Export-VdcCertificate -Pkcs12 -PrivateKeyPassword 'myPassw0rd!'
$p12 | Import-VcCertificate -Pkcs12 -PrivateKeyPassword 'myPassw0rd!' -VenafiSession $vaas_key
```

Bulk export from TLSPDC and import into TLSPC.
As $VenafiSession can only point to one platform at a time, in this case TLSPDC, the session needs to be overridden for the import.

## PARAMETERS

### -Path
Path to a certificate file. 
Provide either this or -Data.

```yaml
Type: String
Parameter Sets: ByFile
Aliases: FullName, CertificatePath

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Data
Contents of a certificate/key to import. 
Provide either this or -Path.

```yaml
Type: String
Parameter Sets: Pkcs8, Pkcs12
Aliases: CertificateData

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Pkcs12
Provided -Data is in PKCS #12 format

```yaml
Type: SwitchParameter
Parameter Sets: Pkcs12
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Pkcs8
Provided -Data is in PKCS #8 format

```yaml
Type: SwitchParameter
Parameter Sets: Pkcs8
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrivateKeyPassword
Password the private key was encrypted with

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ThrottleLimit
Limit the number of threads when running in parallel; the default is 10. 
Applicable to PS v7+ only.
100 keystores will be imported at a time so it's less important to have a very high throttle limit.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### -VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TLSPC key can also provided.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Path, Data
## OUTPUTS

## NOTES

## RELATED LINKS

[https://developer.venafi.com/tlsprotectcloud/reference/certificates_import](https://developer.venafi.com/tlsprotectcloud/reference/certificates_import)

