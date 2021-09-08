# Add-TppCertificateAssociation

## SYNOPSIS
Add certificate association

## SYNTAX

### AddByObject
```
Add-TppCertificateAssociation -InputObject <TppObject> [-ApplicationPath <String[]>] [-PushCertificate]
 [-VenafiSession <VenafiSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### AddByPath
```
Add-TppCertificateAssociation -CertificatePath <String> [-ApplicationPath <String[]>] [-PushCertificate]
 [-VenafiSession <VenafiSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Associates one or more Application objects to an existing certificate.
Optionally, you can push the certificate once the association is complete.

## EXAMPLES

### EXAMPLE 1
```
Add-TppCertificateAssocation -CertificatePath '\ved\policy\my cert' -ApplicationPath '\ved\policy\my capi'
```

Add a single application object association

### EXAMPLE 2
```
Add-TppCertificateAssocation -Path '\ved\policy\my cert' -ApplicationPath '\ved\policy\my capi' -PushCertificate
```

Add the association and push the certificate

## PARAMETERS

### -InputObject
TppObject which represents a certificate

```yaml
Type: TppObject
Parameter Sets: AddByObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -CertificatePath
Path to the certificate. 
Required if InputObject not provided.

```yaml
Type: String
Parameter Sets: AddByPath
Aliases: DN, CertificateDN

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ApplicationPath
List of application object paths to associate

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

### -PushCertificate
Push the certificate after associating it to the Application objects.
This will only be successful if the certificate management type is Provisioning and is not disabled, in error, or a push is already in process.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: ProvisionCertificate

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

### InputObject, Path
## OUTPUTS

### None
## NOTES
You must have:
- Write permission to the Certificate object.
- Write or Associate and Delete permission to Application objects that are associated with the certificate

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Add-TppCertificateAssociation/](http://VenafiPS.readthedocs.io/en/latest/functions/Add-TppCertificateAssociation/)

[https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Public/Add-TppCertificateAssociation.ps1](https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Public/Add-TppCertificateAssociation.ps1)

[https://docs.venafi.com/Docs/19.2SDK/TopNav/Content/SDK/WebSDK/API_Reference/r-SDK-POST-Certificates-Associate.php?tocpath=REST%20API%20reference%7CCertificates%20programming%20interface%7C_____6](https://docs.venafi.com/Docs/19.2SDK/TopNav/Content/SDK/WebSDK/API_Reference/r-SDK-POST-Certificates-Associate.php?tocpath=REST%20API%20reference%7CCertificates%20programming%20interface%7C_____6)

