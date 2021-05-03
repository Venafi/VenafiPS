# Remove-TppCertificateAssociation

## SYNOPSIS
Remove certificate associations

## SYNTAX

### RemoveAllByObject
```
Remove-TppCertificateAssociation -InputObject <TppObject> [-OrphanCleanup] [-All] [-VenafiSession <VenafiSession>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### RemoveOneByObject
```
Remove-TppCertificateAssociation -InputObject <TppObject> -ApplicationPath <String[]> [-OrphanCleanup]
 [-VenafiSession <VenafiSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### RemoveAllByPath
```
Remove-TppCertificateAssociation -Path <String> [-OrphanCleanup] [-All] [-VenafiSession <VenafiSession>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### RemoveOneByPath
```
Remove-TppCertificateAssociation -Path <String> -ApplicationPath <String[]> [-OrphanCleanup]
 [-VenafiSession <VenafiSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Dissociates one or more Application objects from an existing certificate.
Optionally, you can remove the application objects and corresponding orphaned device objects that no longer have any applications

## EXAMPLES

### EXAMPLE 1
```
Remove-TppCertificateAssocation -Path '\ved\policy\my cert' -ApplicationPath '\ved\policy\my capi'
```

Remove a single application object association

### EXAMPLE 2
```
Remove-TppCertificateAssocation -Path '\ved\policy\my cert' -ApplicationPath '\ved\policy\my capi' -OrphanCleanup
```

Disassociate and delete the application object

### EXAMPLE 3
```
Remove-TppCertificateAssocation -Path '\ved\policy\my cert' -RemoveAll
```

Remove all certificate associations

## PARAMETERS

### -InputObject
TppObject which represents a unique object

```yaml
Type: TppObject
Parameter Sets: RemoveAllByObject, RemoveOneByObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
Path to the certificate

```yaml
Type: String
Parameter Sets: RemoveAllByPath, RemoveOneByPath
Aliases: DN, CertificateDN

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ApplicationPath
List of application object paths to dissociate

```yaml
Type: String[]
Parameter Sets: RemoveOneByObject, RemoveOneByPath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OrphanCleanup
Delete the Application object after dissociating it.
Only delete the corresponding Device DN when it has no child objects.
Otherwise retain the Device DN and its children.

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

### -All
Remove all associated application objects

```yaml
Type: SwitchParameter
Parameter Sets: RemoveAllByObject, RemoveAllByPath
Aliases: RemoveAll

Required: True
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

### InputObject, Path
## OUTPUTS

### None
## NOTES
You must have:
- Write permission to the Certificate object.
- Write or Associate permission to Application objects that are associated with the certificate
- Delete permission to Application and device objects when specifying -OrphanCleanup

## RELATED LINKS

[http://venafitppps.readthedocs.io/en/latest/functions/Remove-TppCertificateAssociation/](http://venafitppps.readthedocs.io/en/latest/functions/Remove-TppCertificateAssociation/)

[https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Remove-TppCertificateAssociation.ps1](https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Remove-TppCertificateAssociation.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Dissociate.php?tocpath=Web%20SDK%7CCertificates%20programming%20interface%7C_____8](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Dissociate.php?tocpath=Web%20SDK%7CCertificates%20programming%20interface%7C_____8)

