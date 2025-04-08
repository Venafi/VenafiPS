# Find-VdcVaultId

## SYNOPSIS
Find vault IDs in the secret store

## SYNTAX

```
Find-VdcVaultId [-Path] <String> [[-VenafiSession] <PSObject>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Find vault IDs in the secret store associated to an existing object.

## EXAMPLES

### EXAMPLE 1
```
Find-VdcVaultId -Path '\ved\policy\awesomeobject.cyberark.com'
```

Find the vault IDs associated with an object.
For certificates with historical references, the vault IDs will

## PARAMETERS

### -Path
Path of the object

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### Path
## OUTPUTS

### String
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Find-VdcVaultId/](http://VenafiPS.readthedocs.io/en/latest/functions/Find-VdcVaultId/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-VdcVaultId.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-VdcVaultId.ps1)

