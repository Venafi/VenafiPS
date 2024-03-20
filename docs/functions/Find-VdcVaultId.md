# Find-VdcVaultId

## SYNOPSIS
Find vault IDs in the secret store

## SYNTAX

```
Find-VdcVaultId [-Attribute] <Hashtable> [[-VenafiSession] <PSObject>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Find vault IDs in the secret store by their attributes and associated values

## EXAMPLES

### EXAMPLE 1
```
Find-VdcVaultId -Attribute @{'Serial'='0812E11D213DE8E07890BCC1234567'}
Find a vault id
```

## PARAMETERS

### -Attribute
Name and value to search.
See https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Secretstore-lookupbyassociation.php for more details.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TLSPDC token can also be provided.
If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Attribute
## OUTPUTS

### String
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Find-VdcVaultId/](http://VenafiPS.readthedocs.io/en/latest/functions/Find-VdcVaultId/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-VdcVaultId.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-VdcVaultId.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Secretstore-lookupbyassociation.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Secretstore-lookupbyassociation.php)

