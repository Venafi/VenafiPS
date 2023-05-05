# Export-VenafiCertificate

## SYNOPSIS
Get certificate data

## SYNTAX

### VaasChain
```
Export-VenafiCertificate -CertificateId <String> -VaasFormat <String> [-OutPath <String>] [-IncludeChain]
 [-RootFirst] [-VenafiSession <PSObject>] [<CommonParameters>]
```

### Vaas
```
Export-VenafiCertificate -CertificateId <String> -VaasFormat <String> [-OutPath <String>]
 [-VenafiSession <PSObject>] [<CommonParameters>]
```

### TppJks
```
Export-VenafiCertificate -CertificateId <String> [-IncludeChain] -FriendlyName <String>
 [-PrivateKeyPassword <SecureString>] -KeystorePassword <SecureString> [-VenafiSession <PSObject>]
 [<CommonParameters>]
```

### Tpp
```
Export-VenafiCertificate -CertificateId <String> -TppFormat <String> [-OutPath <String>] [-IncludeChain]
 [-FriendlyName <String>] [-PrivateKeyPassword <SecureString>] [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Get certificate data from either Venafi as a Service or TPP.

## EXAMPLES

### EXAMPLE 1
```
$certId | Export-VenafiCertificate -VaasFormat PEM
Get certificate data from Venafi as a Service
```

### EXAMPLE 2
```
$cert | Export-VenafiCertificate -TppFormat 'PKCS #7' -OutPath 'c:\temp'
Get certificate data and save to a file
```

### EXAMPLE 3
```
$cert | Export-VenafiCertificate -TppFormat 'PKCS #7' -IncludeChain
Get one or more certificates with the certificate chain included, TPP
```

### EXAMPLE 4
```
$cert | Export-VenafiCertificate -VaasFormat PEM -IncludeChain -RootFirst
Get one or more certificates with the certificate chain included and the root first in the chain, VaaS
```

### EXAMPLE 5
```
$cert | Export-VenafiCertificate -TppFormat 'PKCS #12' -PrivateKeyPassword $cred.password
Get one or more certificates with private key included, TPP
```

### EXAMPLE 6
```
$cert | Export-VenafiCertificate -FriendlyName 'MyFriendlyName' -KeystorePassword $cred.password
Get certificates in JKS format, TPP.  -TppFormat not needed since we know its JKS via -KeystorePassword.
```

## PARAMETERS

### -CertificateId
Certificate identifier. 
For Venafi as a Service, this is the unique guid. 
For TPP, use the full path.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path, id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TppFormat
Certificate format, either Base64, Base64 (PKCS#8), DER, PKCS #7, or PKCS #12.

```yaml
Type: String
Parameter Sets: Tpp
Aliases: Format

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VaasFormat
Certificate format, either DER or PEM

```yaml
Type: String
Parameter Sets: VaasChain, Vaas
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

```yaml
Type: String
Parameter Sets: VaasChain, Vaas, Tpp
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
Parameter Sets: VaasChain
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: SwitchParameter
Parameter Sets: TppJks, Tpp
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RootFirst
Use with -IncludeChain for VaaS to return the root first instead of the end entity first

```yaml
Type: SwitchParameter
Parameter Sets: VaasChain
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
Required when exporting JKS. 
TPP Only.

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
Parameter Sets: TppJks, Tpp
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### CertificateId / Path from TppObject
## OUTPUTS

### Vaas, System.String.  TPP, PSCustomObject.
## NOTES

## RELATED LINKS
