# Add-VenafiTeamMember

## SYNOPSIS
Add members to a team

## SYNTAX

```
Add-VenafiTeamMember [-ID] <String> [-Member] <String[]> [[-VenafiSession] <VenafiSession>]
 [<CommonParameters>]
```

## DESCRIPTION
Add members to either a VaaS or TPP team

## EXAMPLES

### EXAMPLE 1
```
Add-VenafiTeamMember -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Member @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4')
```

Add members to a VaaS team

### EXAMPLE 2
```
Add-VenafiTeamMember -ID 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Member 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}'
```

Add members to a TPP team

## PARAMETERS

### -ID
Team ID.
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

### -Member
1 or more members to add to the team.
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
Session object created from New-VenafiSession method. 
The value defaults to the script session object $VenafiSession.

```yaml
Type: VenafiSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: $script:VenafiSession
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

[https://api.venafi.cloud/webjars/swagger-ui/index.html#/Teams/addMember](https://api.venafi.cloud/webjars/swagger-ui/index.html#/Teams/addMember)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-PUT-Teams-AddTeamMembers.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-PUT-Teams-AddTeamMembers.php)

