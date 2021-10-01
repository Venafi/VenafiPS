# Export-VenafiCertificate

## SYNOPSIS
Get certificate data

## SYNTAX

### Vaas (Default)
```
Export-VenafiCertificate -CertificateId <String> -Format <String> [-VenafiSession <VenafiSession>]
 [<CommonParameters>]
```

### Tpp
```
Export-VenafiCertificate -CertificateId <String> -Format <String> [-OutPath <String>] [-IncludeChain]
 [-FriendlyName <String>] [-IncludePrivateKey] [-PrivateKeyPassword <SecureString>]
 [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### TppJks
```
Export-VenafiCertificate -CertificateId <String> -Format <String> [-IncludeChain] -FriendlyName <String>
 [-PrivateKeyPassword <SecureString>] -KeystorePassword <SecureString> [-VenafiSession <VenafiSession>]
 [<CommonParameters>]
```

## DESCRIPTION
Get certificate data from either Venafi as a Service or TPP.

## EXAMPLES

### EXAMPLE 1
```
$certId | Export-VenafiCertificate -Format PEM
```

Get certificate data from Venafi as a Service

### EXAMPLE 2
```
$cert | Export-VenafiCertificate -Format 'PKCS #7' -OutPath 'c:\temp'
```

Get certificate data and save to a file, TPP

### EXAMPLE 3
```
$cert | Export-VenafiCertificate -Format 'PKCS #7' -IncludeChain
```

Get one or more certificates with the certificate chain included, TPP

### EXAMPLE 4
```
$cert | Export-VenafiCertificate -Format 'PKCS #12' -PrivateKeyPassword $cred.password
```

Get one or more certificates with private key included, TPP

### EXAMPLE 5
```
$cert | Export-VenafiCertificate -FriendlyName 'MyFriendlyName' -KeystorePassword $cred.password
```

Get certificates in JKS format, TPP

## PARAMETERS

### -CertificateId
Certificate identifier. 
For Venafi as a Service, this is the unique guid. 
For TPP, use the full path.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Format
Certificate format. 
For Venafi as a Service, you can provide either PEM or DER. 
For TPP, Base64, Base64 (PKCS#8), DER, JKS, PKCS #7, or PKCS #12.

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

### -OutPath
Folder path to save the certificate to. 
The name of the file will be determined automatically. 
TPP Only...for now.

```yaml
Type: String
Parameter Sets: Tpp
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
TPP Only.

```yaml
Type: SwitchParameter
Parameter Sets: Tpp, TppJks
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
TPP Only.

```yaml
Type: String
Parameter Sets: Tpp
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: TppJks
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludePrivateKey
DEPRECATED.
Provide a value for -PrivateKeyPassword.

```yaml
Type: SwitchParameter
Parameter Sets: Tpp
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
TPP Only.
You must adhere to the following rules:
- Password is at least 12 characters.
- Comprised of at least three of the following:
    - Uppercase alphabetic letters
    - Lowercase alphabetic letters
    - Numeric characters
    - Special characters

```yaml
Type: SecureString
Parameter Sets: Tpp, TppJks
Aliases: SecurePassword

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeystorePassword
Password required to retrieve the certificate in JKS format. 
TPP Only.
You must adhere to the following rules:
- Password is at least 12 characters.
- Comprised of at least three of the following:
    - Uppercase alphabetic letters
    - Lowercase alphabetic letters
    - Numeric characters
    - Special characters

```yaml
Type: SecureString
Parameter Sets: TppJks
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
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### CertificateId/Path from TppObject
## OUTPUTS

### Vaas, System.String.  TPP, PSCustomObject.
## NOTES

## RELATED LINKS
