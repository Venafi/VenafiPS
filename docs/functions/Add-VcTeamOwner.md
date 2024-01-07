# Add-VcTeamOwner

## SYNOPSIS
Add owners to a team

## SYNTAX

```
Add-VcTeamOwner [-Team] <String> [-Owner] <String[]> [[-VenafiSession] <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Add owners to a TLSPC team

## EXAMPLES

### EXAMPLE 1
```
Add-VcTeamOwner -Team 'DevOps' -Owner @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4')
```

Add owners

## PARAMETERS

### -Team
Team ID or name

```yaml
Type: String
Parameter Sets: (All)
Aliases: ID

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Owner
1 or more owners to add to the team
This is the unique guid obtained from Get-VcIdentity.

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
A TLSPC key can also provided.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Team
## OUTPUTS

## NOTES

## RELATED LINKS

[https://api.venafi.cloud/webjars/swagger-ui/index.html#/Teams/addOwner](https://api.venafi.cloud/webjars/swagger-ui/index.html#/Teams/addOwner)

