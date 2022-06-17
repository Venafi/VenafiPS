# Invoke-VenafiCertificateAction

## SYNOPSIS
Perform an action against a certificate on TPP or VaaS

## SYNTAX

### Retire
```
Invoke-VenafiCertificateAction -CertificateId <String> [-Retire] [-AdditionalParameters <Hashtable>]
 [-VenafiSession <PSObject>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Reset
```
Invoke-VenafiCertificateAction -CertificateId <String> [-Reset] [-AdditionalParameters <Hashtable>]
 [-VenafiSession <PSObject>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Renew
```
Invoke-VenafiCertificateAction -CertificateId <String> [-Renew] [-AdditionalParameters <Hashtable>]
 [-VenafiSession <PSObject>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Push
```
Invoke-VenafiCertificateAction -CertificateId <String> [-Push] [-AdditionalParameters <Hashtable>]
 [-VenafiSession <PSObject>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Validate
```
Invoke-VenafiCertificateAction -CertificateId <String> [-Validate] [-AdditionalParameters <Hashtable>]
 [-VenafiSession <PSObject>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Revoke
```
Invoke-VenafiCertificateAction -CertificateId <String> [-Revoke] [-AdditionalParameters <Hashtable>]
 [-VenafiSession <PSObject>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
One stop shop for basic certificate actions against either TPP or VaaS.
When supported by the platform, you can Retire, Reset, Renew, Push, Validate, or Revoke.

## EXAMPLES

### EXAMPLE 1
```
Invoke-VenafiCertificateAction -CertificateId '\VED\Policy\My folder\app.mycompany.com' -Revoke
Perform an action
```

### EXAMPLE 2
```
Invoke-VenafiCertificateAction -CertificateId '\VED\Policy\My folder\app.mycompany.com' -Revoke -AdditionalParameters @{'Comments'='Key compromised'}
Perform an action sending additional parameters.
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
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Retire
Retire/disable a certificate

```yaml
Type: SwitchParameter
Parameter Sets: Retire
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Reset
Reset the state of a certificate and its associated applications. 
TPP only.

```yaml
Type: SwitchParameter
Parameter Sets: Reset
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Renew
Requests immediate renewal for an existing certificate

```yaml
Type: SwitchParameter
Parameter Sets: Renew
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Push
Provisions the same certificate and private key to one or more devices or servers.
The certificate must be associated with one or more Application objects.
TPP only.

```yaml
Type: SwitchParameter
Parameter Sets: Push
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Validate
Initiates SSL/TLS network validation

```yaml
Type: SwitchParameter
Parameter Sets: Validate
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Revoke
Sends a revocation request to the certificate CA. 
TPP only.

```yaml
Type: SwitchParameter
Parameter Sets: Revoke
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AdditionalParameters
Additional items specific to the action being taken, if needed.
See the api documentation for appropriate items, many are in the links in this help.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
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

### CertificateId
## OUTPUTS

### PSCustomObject with the following properties:
###     CertificateId - Certificate path (TPP) or Guid (VaaS)
###     Success - A value of true indicates that the action was successful
###     Error - Indicates any errors that occurred. Not returned when Success is true
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Invoke-TppCertificateRenewal/](http://VenafiPS.readthedocs.io/en/latest/functions/Invoke-TppCertificateRenewal/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Invoke-TppCertificateRenewal.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Invoke-TppCertificateRenewal.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Reset.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Reset.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-renew.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-renew.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Push.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Push.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Validate.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Validate.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-revoke.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-revoke.php)

[https://api.venafi.cloud/webjars/swagger-ui/index.html?configUrl=%2Fv3%2Fapi-docs%2Fswagger-config&urls.primaryName=outagedetection-service](https://api.venafi.cloud/webjars/swagger-ui/index.html?configUrl=%2Fv3%2Fapi-docs%2Fswagger-config&urls.primaryName=outagedetection-service)

