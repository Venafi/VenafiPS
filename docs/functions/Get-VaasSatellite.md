# Get-VaasSatellite

## SYNOPSIS
Get VSatellite info

## SYNTAX

### ID (Default)
```
Get-VaasSatellite -ID <String> [-IncludeKey] [-VenafiSession <PSObject>] [<CommonParameters>]
```

### All
```
Get-VaasSatellite [-All] [-IncludeKey] [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Get info for either a specific VSatellite or all.
There is an option to also include the encryption key and algorithm.

## EXAMPLES

### EXAMPLE 1
```
Get-VaasSatellite -ID 'VSatellite Hub 0001'
```

companyId                   : a05013bd-921d-440c-bc22-c9ead5c8d548
productEntitlements         : {ANY}
environmentId               : a05013bd-921d-440c-bc22-c9ead5c8d548
pairingCodeId               : a05013bd-921d-440c-bc22-c9ead5c8d548
name                        : VSatellite Hub 0001
edgeType                    : HUB
edgeStatus                  : ACTIVE
clientId                    : a05013bd-921d-440c-bc22-c9ead5c8d548
modificationDate            : 6/15/2023 11:48:40 AM
address                     : 1.2.3.4
deploymentDate              : 6/15/2023 11:44:14 AM
lastSeenOnDate              : 7/13/2023 12:00:40 PM
reconciliationFailed        : False
encryptionKeyId             : mwU4oTet9KwTGggRfhek0UtvighIw=
encryptionKeyDeploymentDate : 6/15/2023 11:48:40 AM
kubernetesVersion           : v1.23.6+k3s1
integrationServicesCount    : 0
vsatelliteId                : a05013bd-921d-440c-bc22-c9ead5c8d548
encryptionKey               :
encryptionKeyAlgorithm      :

Get info for a specific VSatellite by name

### EXAMPLE 2
```
Get-VaasSatellite -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
```

Get info for a specific VSatellite

### EXAMPLE 3
```
Get-VaasSatellite -All
```

Get info for all VSatellites

### EXAMPLE 4
```
Get-VaasSatellite -All -IncludeKey
```

companyId                   : a05013bd-921d-440c-bc22-c9ead5c8d548
productEntitlements         : {ANY}
environmentId               : a05013bd-921d-440c-bc22-c9ead5c8d548
pairingCodeId               : a05013bd-921d-440c-bc22-c9ead5c8d548
name                        : VSatellite Hub 0001
edgeType                    : HUB
edgeStatus                  : ACTIVE
clientId                    : a05013bd-921d-440c-bc22-c9ead5c8d548
modificationDate            : 6/15/2023 11:48:40 AM
address                     : 1.2.3.4
deploymentDate              : 6/15/2023 11:44:14 AM
lastSeenOnDate              : 7/13/2023 12:00:40 PM
reconciliationFailed        : False
encryptionKeyId             : mwU4oTet9KwTGggRfhek0UtvighIw=
encryptionKeyDeploymentDate : 6/15/2023 11:48:40 AM
kubernetesVersion           : v1.23.6+k3s1
integrationServicesCount    : 0
vsatelliteId                : a05013bd-921d-440c-bc22-c9ead5c8d548
encryptionKey               : o4aFaJUTtCydprvgRupQ1ZiY=
encryptionKeyAlgorithm      : ED25519

Get info for VSatellites including the encryption key and algorithm

## PARAMETERS

### -ID
Name or uuid to get info for a specific VSatellite

```yaml
Type: String
Parameter Sets: ID
Aliases: applicationId

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -All
Get all VSatellites

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeKey
Include the encryption key and algorithm

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
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A VaaS key can also provided.

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

### ID
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-VaasSatellite/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-VaasSatellite/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VaasSatellite.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VaasSatellite.ps1)

[https://developer.venafi.com/tlsprotectcloud/reference/edgeinstances_getall](https://developer.venafi.com/tlsprotectcloud/reference/edgeinstances_getall)

[https://developer.venafi.com/tlsprotectcloud/reference/edgeencryptionkeys_getall](https://developer.venafi.com/tlsprotectcloud/reference/edgeencryptionkeys_getall)

