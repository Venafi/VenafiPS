# Get-VenafiCertificate

## SYNOPSIS
Get certificate information

## SYNTAX

### Id (Default)
```
Get-VenafiCertificate -CertificateId <String> [-VenafiSession <PSObject>] [<CommonParameters>]
```

### TppId
```
Get-VenafiCertificate -CertificateId <String> [-IncludeTppPreviousVersions] [-ExcludeExpired] [-ExcludeRevoked]
 [-VenafiSession <PSObject>] [<CommonParameters>]
```

### VaasId
```
Get-VenafiCertificate -CertificateId <String> [-IncludeVaasOwner] [-VenafiSession <PSObject>]
 [<CommonParameters>]
```

### TppAll
```
Get-VenafiCertificate [-All] [-IncludeTppPreviousVersions] [-ExcludeExpired] [-ExcludeRevoked]
 [-VenafiSession <PSObject>] [<CommonParameters>]
```

### VaasAll
```
Get-VenafiCertificate [-All] [-IncludeVaasOwner] [-VenafiSession <PSObject>] [<CommonParameters>]
```

### All
```
Get-VenafiCertificate [-All] [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Get certificate information, either all available to the api key provided or by id or zone.

## EXAMPLES

### EXAMPLE 1
```
Get-VenafiCertificate -CertificateId 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
```

Get certificate info for a specific cert on Venafi as a Serivce

### EXAMPLE 2
```
Get-VenafiCertificate -CertificateId '\ved\policy\mycert.com'
```

Get certificate info for a specific cert on TPP

### EXAMPLE 3
```
Get-VenafiCertificate -All
```

Get certificate info for all certs in either TPP or VaaS

### EXAMPLE 4
```
Get-VenafiCertificate -CertificateId '\ved\policy\mycert.com' -IncludeTppPreviousVersions
```

Get certificate info for a specific cert on TPP, including historical versions of the certificate.

### EXAMPLE 5
```
Get-VenafiCertificate -CertificateId '\ved\policy\mycert.com' -IncludeTppPreviousVersions -ExcludeRevoked -ExcludeExpired
```

Get certificate info for a specific cert on TPP, including historical versions of the certificate that are not revoked or expired.

### EXAMPLE 6
```
Get-VenafiCertificate -CertificateId 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -IncludeVaasOwner
```

In addition to certificate info, get user and team owner info as well

## PARAMETERS

### -CertificateId
Certificate identifier.
For Venafi as a Service, this is the unique guid.
For TPP, use the path or guid. 
\ved\policy will be automatically applied if a full path isn't provided.

```yaml
Type: String
Parameter Sets: Id, TppId, VaasId
Aliases: Guid, Path, id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -All
Retrieve all certificates

```yaml
Type: SwitchParameter
Parameter Sets: TppAll, VaasAll, All
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeTppPreviousVersions
Returns details about previous (historical) versions of a certificate (only from TPP).
This option will add a property named PreviousVersions to the returned object.

```yaml
Type: SwitchParameter
Parameter Sets: TppId, TppAll
Aliases: IncludePreviousVersions

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeExpired
Omits expired versions of the previous (historical) versions of a certificate (only from TPP).
Can only be used with the IncludePreviousVersions parameter.

```yaml
Type: SwitchParameter
Parameter Sets: TppId, TppAll
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeRevoked
Omits revoked versions of the previous (historical) versions of a certificate (only from TPP).
Can only be used with the IncludePreviousVersions parameter.

```yaml
Type: SwitchParameter
Parameter Sets: TppId, TppAll
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeVaasOwner
Retrieve detailed user/team owner info, only for VaaS.
This will cause additional api calls to be made and take longer.

```yaml
Type: SwitchParameter
Parameter Sets: VaasId, VaasAll
Aliases:

Required: True
Position: Named
Default value: False
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### CertificateId
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates-guid.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates-guid.php)

