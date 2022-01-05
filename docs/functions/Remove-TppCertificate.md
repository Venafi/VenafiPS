# Remove-TppCertificate

## SYNOPSIS
Remove a certificate

## SYNTAX

```
Remove-TppCertificate [-Path] <String> [-Force] [[-VenafiSession] <VenafiSession>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Removes a Certificate object, all associated objects including pending workflow tickets, and the corresponding Secret Store vault information.
All associations must be removed for the certificate to be removed.
You must either be a Master Admin or have Delete permission to the Certificate object
and to the Application and Device objects if they are to be deleted automatically with -Force

## EXAMPLES

### EXAMPLE 1
```
$cert | Remove-TppCertificate
```

Remove a certificate via pipeline

### EXAMPLE 2
```
Remove-TppCertificate -Path '\ved\policy\my cert'
```

Remove a certificate

### EXAMPLE 3
```
Remove-TppCertificate -Path '\ved\policy\my cert' -force
```

Remove a certificate and automatically remove all associations

## PARAMETERS

### -Path
Path to the certificate to remove

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

### -Force
Provide this switch to force all associations to be removed prior to certificate removal

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
Position: 2
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

### InputObject or Path
## OUTPUTS

### None
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppCertificate/](http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppCertificate/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppCertificate.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppCertificate.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-DELETE-Certificates-Guid.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-DELETE-Certificates-Guid.php)

