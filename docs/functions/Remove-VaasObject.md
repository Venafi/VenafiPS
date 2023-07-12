# Remove-VaasObject

## SYNOPSIS
Remove an object from VaaS

## SYNTAX

### Team
```
Remove-VaasObject -TeamID <String> [-VenafiSession <PSObject>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Application
```
Remove-VaasObject -ApplicationID <String> [-VenafiSession <PSObject>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Machine
```
Remove-VaasObject -MachineID <String> [-VenafiSession <PSObject>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### MachineIdentity
```
Remove-VaasObject -MachineIdentityID <String> [-VenafiSession <PSObject>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Tag
```
Remove-VaasObject -TagName <String> [-VenafiSession <PSObject>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Connector
```
Remove-VaasObject -ConnectorID <String> [-VenafiSession <PSObject>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Remove a team, application, machine, machine identity, tag, or connector

## EXAMPLES

### EXAMPLE 1
```
Remove-VaasObject -TeamID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Remove a VaaS team
```

### EXAMPLE 2
```
Get-VenafiTeam -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' | Remove-VaasObject
Remove a VaaS team
```

### EXAMPLE 3
```
Get-VaasConnector | Remove-VaasObject
Remove all connectors
```

### EXAMPLE 4
```
Remove-VaasObject -TeamID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Confirm:$false
Remove a team bypassing the confirmation prompt
```

## PARAMETERS

### -TeamID
Team ID

```yaml
Type: String
Parameter Sets: Team
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ApplicationID
Application ID

```yaml
Type: String
Parameter Sets: Application
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MachineID
Machine ID

```yaml
Type: String
Parameter Sets: Machine
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MachineIdentityID
Machine Identity ID

```yaml
Type: String
Parameter Sets: MachineIdentity
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TagName
Name of the tag to be removed

```yaml
Type: String
Parameter Sets: Tag
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ConnectorID
Connector ID

```yaml
Type: String
Parameter Sets: Connector
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### TeamID, ApplicationID, MachineID, MachineIdentityID, TagName, ConnectorID
## OUTPUTS

## NOTES

## RELATED LINKS
