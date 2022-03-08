# Invoke-TppCertificateRenewal

## SYNOPSIS
Renew a certificate

## SYNTAX

```
Invoke-TppCertificateRenewal [-Path] <String> [[-Csr] <String>] [[-VenafiSession] <VenafiSession>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Requests renewal for an existing certificate.
This call marks a certificate for
immediate renewal.
The certificate must not be in error, already being processed, or
configured for Monitoring in order for it be renewable.
You must have Write access
to the certificate object being renewed.

## EXAMPLES

### EXAMPLE 1
```
Invoke-TppCertificateRenewal -Path '\VED\Policy\My folder\app.mycompany.com'
```

### EXAMPLE 2
```
Invoke-TppCertificateRenewal -Path '\VED\Policy\My folder\app.mycompany.com' -Csr '-----BEGIN CERTIFICATE REQUEST-----\nMIIDJDCCAgwCAQAw...-----END CERTIFICATE REQUEST-----'
Renew certificate using a CSR
```

## PARAMETERS

### -Path
Path to the certificate to renew

```yaml
Type: String
Parameter Sets: (All)
Aliases: DN, CertificateDN

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Csr
Optional PKCS#10 Certificate Signing Request (CSR).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
Position: 3
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

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

### PSCustomObject with the following properties:
###     Path - Certificate path
###     Success - A value of true indicates that the renewal request was successfully submitted and
###     granted.
###     Error - Indicates any errors that occurred. Not returned when successful
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Invoke-TppCertificateRenewal/](http://VenafiPS.readthedocs.io/en/latest/functions/Invoke-TppCertificateRenewal/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Invoke-TppCertificateRenewal.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Invoke-TppCertificateRenewal.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-renew.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-renew.php)

