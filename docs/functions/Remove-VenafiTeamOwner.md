# Remove-VenafiTeamOwner

## SYNOPSIS
Remove team owner

## SYNTAX

```
Remove-VenafiTeamOwner [-ID] <String> [-Owner] <String[]> [[-VenafiSession] <PSObject>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Remove a team owner from VaaS or TPP.

## EXAMPLES

### EXAMPLE 1
```
Remove-VenafiTeamOwner -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Owner @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4')
```

Remove owners from a team

### EXAMPLE 2
```
Remove-VenafiTeamOwner -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Owner 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f3' -Confirm:$false
```

Remove an owner from a team with no confirmation prompting

### EXAMPLE 3
```
Remove-VenafiTeamOwner -ID 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Owner 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}'
```

Remove owners from a TPP team

## PARAMETERS

### -ID
Team ID
For VaaS, this is the unique guid obtained from Get-VenafiTeam.
For TPP, this is the ID property from Find-TppIdentity or Get-VenafiTeam.

```yaml
Type: String
Parameter Sets: (All)
Aliases: PrefixedUniversal, Guid

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Owner
1 or more owners to remove from the team
For VaaS, this is the unique guid obtained from Get-VenafiIdentity.
For TPP, this is the identity ID property from Find-TppIdentity or Get-VenafiIdentity.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
Position: 3
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

### ID
## OUTPUTS

## NOTES

## RELATED LINKS

[https://api.venafi.cloud/webjars/swagger-ui/index.html#/Teams/removeOwner](https://api.venafi.cloud/webjars/swagger-ui/index.html#/Teams/removeOwner)

[https://docs.venafi.com/Docs/21.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-PUT-Teams-DemoteTeamOwners.php](https://docs.venafi.com/Docs/21.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-PUT-Teams-DemoteTeamOwners.php)

