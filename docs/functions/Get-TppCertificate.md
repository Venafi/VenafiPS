# Get-TppCertificate

## SYNOPSIS
Get a certificate

## SYNTAX

### NonJKS (Default)
```
Get-TppCertificate -Path <String> -Format <String> [-OutPath <String>] [-IncludeChain] [-FriendlyName <String>]
 [-IncludePrivateKey] [-PrivateKeyPassword <SecureString>] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### JKS
```
Get-TppCertificate -Path <String> [-Format <String>] [-OutPath <String>] [-IncludeChain] -FriendlyName <String>
 [-IncludePrivateKey] [-PrivateKeyPassword <SecureString>] -KeystorePassword <SecureString>
 [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Get a certificate with or without private key.
You have the option of simply getting the data or saving it to a file.

## EXAMPLES

### EXAMPLE 1
```
$certs | Get-TppCertificate -Format 'PKCS #7' -OutPath 'c:\temp'
```

Get certificate data and save to a file

### EXAMPLE 2
```
$certs | Get-TppCertificate -Format 'PKCS #7' -IncludeChain
```

Get one or more certificates with the certificate chain included

### EXAMPLE 3
```
$certs | Get-TppCertificate -Format 'PKCS #12' -PrivateKeyPassword $cred.password
```

Get one or more certificates with private key included

### EXAMPLE 4
```
$certs | Get-TppCertificate -FriendlyName 'MyFriendlyName' -KeystorePassword $cred.password
```

Get certificates in JKS format

## PARAMETERS

### -Path
Path to the certificate object to retrieve

```yaml
Type: String
Parameter Sets: (All)
Aliases: DN

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Format
The format of the returned certificate.
Valid formats include Base64, Base64 (PKCS #8), DER, JKS, PKCS #7, PKCS #12.

```yaml
Type: String
Parameter Sets: NonJKS
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: JKS
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutPath
Folder path to save the certificate to.
The name of the file will be determined automatically.

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

### -IncludeChain
Include the certificate chain with the exported certificate.
Not supported with DER format.

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

### -FriendlyName
Label or alias to use.
Permitted with Base64 and PKCS #12 formats.
Required when Format is JKS.

```yaml
Type: String
Parameter Sets: NonJKS
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: JKS
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludePrivateKey
{{ Fill IncludePrivateKey Description }}

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

### -PrivateKeyPassword
Password required to include the private key.
Not supported with DER or PKCS #7 formats.
You must adhere to the following rules:
- Password is at least 12 characters.
- Comprised of at least three of the following:
    - Uppercase alphabetic letters
    - Lowercase alphabetic letters
    - Numeric characters
    - Special characters

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases: SecurePassword

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeystorePassword
Password required to retrieve the certificate in JKS format.
You must adhere to the following rules:
- Password is at least 12 characters.
- Comprised of at least three of the following:
    - Uppercase alphabetic letters
    - Lowercase alphabetic letters
    - Numeric characters
    - Special characters

```yaml
Type: SecureString
Parameter Sets: JKS
Aliases:

Required: True
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
Default value: $Script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Path
## OUTPUTS

### If OutPath not provided, a PSCustomObject will be returned with properties CertificateData, Filename, and Format.  Otherwise, no output.
## NOTES

## RELATED LINKS
