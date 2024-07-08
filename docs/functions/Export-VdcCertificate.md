# Export-VdcCertificate

## SYNOPSIS
Export certificate data from TLSPDC

## SYNTAX

### Base64 (Default)
```
Export-VdcCertificate -Path <String> [-Base64] [-IncludeChain] [-FriendlyName <String>] [-OutPath <String>]
 [-ThrottleLimit <Int32>] [-VenafiSession <PSObject>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Pkcs7
```
Export-VdcCertificate -Path <String> [-Pkcs7] [-IncludeChain] [-OutPath <String>] [-ThrottleLimit <Int32>]
 [-VenafiSession <PSObject>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Pkcs8
```
Export-VdcCertificate -Path <String> [-Pkcs8] [-PrivateKeyPassword <PSObject>] [-IncludeChain]
 [-OutPath <String>] [-ThrottleLimit <Int32>] [-VenafiSession <PSObject>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Der
```
Export-VdcCertificate -Path <String> [-Der] [-OutPath <String>] [-ThrottleLimit <Int32>]
 [-VenafiSession <PSObject>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Pkcs12
```
Export-VdcCertificate -Path <String> [-Pkcs12] -PrivateKeyPassword <PSObject> [-IncludeChain]
 [-FriendlyName <String>] [-OutPath <String>] [-ThrottleLimit <Int32>] [-VenafiSession <PSObject>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Jks
```
Export-VdcCertificate -Path <String> [-Jks] [-PrivateKeyPassword <PSObject>] [-IncludeChain]
 -FriendlyName <String> -KeystorePassword <PSObject> [-OutPath <String>] [-ThrottleLimit <Int32>]
 [-VenafiSession <PSObject>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Export certificate data

## EXAMPLES

### EXAMPLE 1
```
Export-VdcCertificate -Path '\ved\policy\mycert.com'
```

Get certificate data in Base64 format, the default

### EXAMPLE 2
```
$cert | Export-VdcCertificate -'PKCS7' -OutPath 'c:\temp'
```

Get certificate data in a specific format and save to a file

### EXAMPLE 3
```
$cert | Export-VdcCertificate -'PKCS7' -IncludeChain
```

Get one or more certificates with the certificate chain included

### EXAMPLE 4
```
$cert | Export-VdcCertificate -'PKCS12' -PrivateKeyPassword 'mySecretPassword!'
```

Get one or more certificates with private key included

### EXAMPLE 5
```
$cert | Export-VdcCertificate -'PKCS8' -PrivateKeyPassword 'mySecretPassword!' -OutPath '~/temp'
```

Save certificate info to a file. 
PKCS8 with private key will save 3 files, .pem (cert+key), .pem.cer (cert only), and .pem.key (key only)

### EXAMPLE 6
```
$cert | Export-VdcCertificate -Jks -FriendlyName 'MyFriendlyName' -KeystorePassword $cred.password
```

Get certificates in JKS format.

## PARAMETERS

### -Path
Full path to the certificate

```yaml
Type: String
Parameter Sets: (All)
Aliases: id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Base64
Provide output in Base64 format. 
This is the default if no format is provided.

```yaml
Type: SwitchParameter
Parameter Sets: Base64
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Pkcs7
Provide output in PKCS #7 format

```yaml
Type: SwitchParameter
Parameter Sets: Pkcs7
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Pkcs8
Provide output in PKCS #8 format

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

### -Der
Provide output in DER format

```yaml
Type: SwitchParameter
Parameter Sets: Der
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Pkcs12
Provide output in PKCS #12 format. 
Requires a value for PrivateKeyPassword.

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

### -Jks
Provide output in JKS format. 
Requires a value for FriendlyName.

```yaml
Type: SwitchParameter
Parameter Sets: Jks
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrivateKeyPassword
Password required to include the private key.
You can either provide a String, SecureString, or PSCredential.
You must adhere to the following rules:
- Password is at least 12 characters.
- Comprised of at least three of the following:
    - Uppercase alphabetic letters
    - Lowercase alphabetic letters
    - Numeric characters
    - Special characters

```yaml
Type: PSObject
Parameter Sets: Pkcs8, Jks
Aliases: SecurePassword

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: PSObject
Parameter Sets: Pkcs12
Aliases: SecurePassword

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeChain
Include the certificate chain with the exported certificate.
The end entity will be first and the root last.

```yaml
Type: SwitchParameter
Parameter Sets: Base64, Pkcs7, Pkcs8, Pkcs12, Jks
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

```yaml
Type: String
Parameter Sets: Base64, Pkcs12
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: Jks
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeystorePassword
Password required to retrieve the certificate in JKS format.
You can either provide a String, SecureString, or PSCredential.
You must adhere to the following rules:
- Password is at least 12 characters.
- Comprised of at least three of the following:
    - Uppercase alphabetic letters
    - Lowercase alphabetic letters
    - Numeric characters
    - Special characters

```yaml
Type: PSObject
Parameter Sets: Jks
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutPath
Folder path to save the certificate/key to. 
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

### -ThrottleLimit
Limit the number of threads when running in parallel; the default is 100. 
Applicable to PS v7+ only.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TLSPDC token can also be provided.
If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

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

### Path
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS
