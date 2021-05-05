# Export-VenafiCertificate

## SYNOPSIS
Get a certificate

## SYNTAX

### Vaas (Default)
```
Export-VenafiCertificate -CertificateId <String> -Format <String> [-OutPath <String>]
 [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### Tpp
```
Export-VenafiCertificate -CertificateId <String> -Format <String> [-OutPath <String>] [-IncludeChain]
 [-FriendlyName <String>] [-IncludePrivateKey] [-PrivateKeyPassword <SecureString>]
 [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### TppJks
```
Export-VenafiCertificate -CertificateId <String> -Format <String> [-OutPath <String>] -FriendlyName <String>
 -KeystorePassword <SecureString> [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Get a certificate

## EXAMPLES

### EXAMPLE 1
```
$certId | Export-VaasCertificate
```

Get a certificate

## PARAMETERS

### -CertificateId
{{ Fill CertificateId Description }}

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
Certificate format, either PEM or DER

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
{{ Fill OutPath Description }}

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
{{ Fill IncludeChain Description }}

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

### -FriendlyName
{{ Fill FriendlyName Description }}

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
{{ Fill IncludePrivateKey Description }}

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
{{ Fill PrivateKeyPassword Description }}

```yaml
Type: SecureString
Parameter Sets: Tpp
Aliases: SecurePassword

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeystorePassword
{{ Fill KeystorePassword Description }}

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

### Id
## OUTPUTS

### System.String
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Export-VaasCertificate/](http://VenafiPS.readthedocs.io/en/latest/functions/Export-VaasCertificate/)

[https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Export-VaasCertificate.ps1](https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Export-VaasCertificate.ps1)

