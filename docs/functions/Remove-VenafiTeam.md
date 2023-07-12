# Remove-VenafiTeam

## SYNOPSIS
Remove a team

## SYNTAX

```
Remove-VenafiTeam [-ID] <String> [[-VenafiSession] <PSObject>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Remove a team from either VaaS or TPP

## EXAMPLES

### EXAMPLE 1
```
Remove-VenafiTeam -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Remove a VaaS team
```

### EXAMPLE 2
```
Remove-VenafiTeam -ID 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}'
Remove a TPP team
```

### EXAMPLE 3
```
Remove-VenafiTeam -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Confirm:$false
Remove a team bypassing the confirmation prompt
```

## PARAMETERS

### -ID
Team ID. 
For VaaS, this is the team uuid. 
For TPP, this is the local ID.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Guid

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### ID
## OUTPUTS

## NOTES

## RELATED LINKS
