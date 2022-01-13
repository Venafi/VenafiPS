# Find-TppVaultId

## SYNOPSIS
Find vault IDs in the secret store

## SYNTAX

```
Find-TppVaultId [-Attribute] <Hashtable> [[-VenafiSession] <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Find vault IDs in the secret store by their attributes and associated values

## EXAMPLES

### EXAMPLE 1
```
Find-TppVaultId -Attribute @{'Serial'='0812E11D213DE8E07890BCC1234567'}
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Attribute
## OUTPUTS

### String
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppVaultId/](http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppVaultId/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppVaultId.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppVaultId.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Secretstore-lookupbyassociation.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Secretstore-lookupbyassociation.php)

