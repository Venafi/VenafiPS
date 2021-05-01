# Invoke-TppCertificatePush

## SYNOPSIS
Push a certificate to an application

## SYNTAX

```
Invoke-TppCertificatePush [-CertificatePath] <String> [[-ApplicationPath] <String[]>]
 [[-TppSession] <TppSession>] [<CommonParameters>]
```

## DESCRIPTION
Push a certificate to one or more applications, or all associated
This will only be successful if the certificate management type is Provisioning and is not disabled, in error, or a push is already in process.

## EXAMPLES

### EXAMPLE 1
```
$cert | Invoke-TppCertificatePush
```

Push certificate to all associated applications, certificate object piped

### EXAMPLE 2
```
Invoke-TppCertificatePush -CertificatePath '\ved\policy\my cert' -ApplicationPath '\ved\policy\my capi'
```

Push to a specific application associated with a certificate

### EXAMPLE 3
```
Invoke-TppCertificatePush -Path '\ved\policy\my cert'
```

Push certificate to all associated applications

## PARAMETERS

### -CertificatePath
Path to the certificate.

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

### -ApplicationPath
List of application object paths to push to.
If not provided, all associated applications will be pushed.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TppSession
Session object created from New-TppSession method. 
The value defaults to the script session object $TppSession.

```yaml
Type: TppSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: $Script:TppSession
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

[http://venafitppps.readthedocs.io/en/latest/functions/Invoke-TppCertificatePush/](http://venafitppps.readthedocs.io/en/latest/functions/Invoke-TppCertificatePush/)

[https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Invoke-TppCertificatePush.ps1](https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Invoke-TppCertificatePush.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Push.php?tocpath=Web%20SDK%7CCertificates%20programming%20interface%7C_____15](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Push.php?tocpath=Web%20SDK%7CCertificates%20programming%20interface%7C_____15)

