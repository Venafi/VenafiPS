# Remove-TppCertificate

## SYNOPSIS
Remove a certificate

## SYNTAX

```
Remove-TppCertificate [-Path] <String> [-KeepAssociatedApps] [[-VenafiSession] <VenafiSession>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Removes a Certificate object, all associated objects including pending workflow tickets, and the corresponding Secret Store vault information.
You must either be a Master Admin or have Delete permission to the objects and have certificate:delete token scope.

## EXAMPLES

### EXAMPLE 1
```
$cert | Remove-TppCertificate
Remove a certificate via pipeline
```

### EXAMPLE 2
```
Remove-TppCertificate -Path '\ved\policy\my cert'
Remove a certificate and any associated app
```

### EXAMPLE 3
```
Remove-TppCertificate -Path '\ved\policy\my cert' -KeepAssociatedApps
Remove a certificate and first remove all associations, keeping the apps
```

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

### -KeepAssociatedApps
Provide this switch to remove associations prior to certificate removal

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

### Path
## OUTPUTS

### None
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppCertificate/](http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppCertificate/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppCertificate.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppCertificate.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-DELETE-Certificates-Guid.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-DELETE-Certificates-Guid.php)

