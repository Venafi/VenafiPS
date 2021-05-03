# Revoke-TppCertificate

## SYNOPSIS
Revoke a certificate

## SYNTAX

### ByObject (Default)
```
Revoke-TppCertificate -InputObject <TppObject> [-Reason <Int32>] [-Comments <String>] [-Disable] [-Wait]
 [-VenafiSession <VenafiSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByPath
```
Revoke-TppCertificate -Path <String> [-Reason <Int32>] [-Comments <String>] [-Disable] [-Wait]
 [-VenafiSession <VenafiSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Requests that an existing certificate be revoked.

## EXAMPLES

### EXAMPLE 1
```
$cert | Revoke-TppCertificate -Reason 2
```

Revoke the certificate with a reason of the CA being compromised

### EXAMPLE 2
```
Revoke-TppCertificate -Path '\VED\Policy\My folder\app.mycompany.com' -Reason 2 -Wait
```

Revoke the certificate with a reason of the CA being compromised and wait for it to complete

## PARAMETERS

### -InputObject
TppObject which represents a certificate

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
Full path to a certificate

```yaml
Type: String
Parameter Sets: ByPath
Aliases: DN, CertificateDN

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Reason
The reason for revocation of the certificate:

    0: None
    1: User key compromised
    2: CA key compromised
    3: User changed affiliation
    4: Certificate superseded
    5: Original use no longer valid

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Comments
Optional details as to why the certificate is being revoked

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

### -Disable
The setting to manage the Certificate object upon revocation.
Default is to allow a new certificate to be enrolled to replace the revoked one.
Provide this switch to mark the certificate as disabled and no new certificate will be enrolled to replace the revoked one.

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

### -Wait
Wait for the requested revocation to be complete

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

### TppObject or Path
## OUTPUTS

### PSCustomObject with the following properties:
###     Path - Path to the Certificate
###     Status - InProgress, Revoked, or Error
###     Warning/Error - additional info
## NOTES

## RELATED LINKS

[http://venafitppps.readthedocs.io/en/latest/functions/Revoke-TppCertificate/](http://venafitppps.readthedocs.io/en/latest/functions/Revoke-TppCertificate/)

[https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Revoke-TppCertificate.ps1](https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Revoke-TppCertificate.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-revoke.php?tocpath=Web%20SDK%7CCertificates%20programming%20interface%7C_____24](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-revoke.php?tocpath=Web%20SDK%7CCertificates%20programming%20interface%7C_____24)

