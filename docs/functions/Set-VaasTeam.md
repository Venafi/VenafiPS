# Set-VaasTeam

## SYNOPSIS
Update an existing team

## SYNTAX

### ID
```
Set-VaasTeam -ID <String> [-NewName <String>] [-NewRole <String>] [-NewUserMatchingRule <Hashtable[]>]
 [-NoOverwrite] [-PassThru] [-VenafiSession <PSObject>] [<CommonParameters>]
```

### Name
```
Set-VaasTeam -Name <String> [-NewName <String>] [-NewRole <String>] [-NewUserMatchingRule <Hashtable[]>]
 [-NoOverwrite] [-PassThru] [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Update name, role, and/or user matching rules for existing teams.

## EXAMPLES

### EXAMPLE 1
```
Set-VaasTeam -Name 'MyTeam' -NewName 'ThisTeamIsBetter'
```

Rename an existing team

### EXAMPLE 2
```
Set-VaasTeam -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Role 'PKI Admin'
```

Change the role for an existing team

### EXAMPLE 3
```
Set-VaasTeam -Name 'MyTeam' -NewUserMatchingRule @{'ClaimName'='MyClaim';'Operator'='equals';'ClaimValue'='matchme'}
```

Replace a teams user matching rules

### EXAMPLE 4
```
Set-VaasTeam -Name 'MyTeam' -NewUserMatchingRule @{'ClaimName'='MyClaim';'Operator'='equals';'ClaimValue'='matchme'} -NoOverwrite
```

Update a teams user matching rules, appending instead of overwriting

### EXAMPLE 5
```
Set-VaasTeam -Name 'MyTeam' -NewName 'ThisTeamIsBetter' -PassThru
```

Rename an existing team and return the updated team object

### EXAMPLE 6
```
Get-VenafiTeam -All | Where-Object {$_.name -like '*shouldnt be sysadmin*'} | Set-VaasTeam -NewRole 'PKI Admin'
```

Update many teams

## PARAMETERS

### -ID
Team ID. 
Provide this or -Name.

```yaml
Type: String
Parameter Sets: ID
Aliases: teamId

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Team name. 
This should be the complete name of the team.
Provide this or -ID.

```yaml
Type: String
Parameter Sets: Name
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -NewName
Provide a new name for the team if you wish to change it.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NewRole
Provide a new role for the team if you wish to change it.
Accepted values are 'System Admin', 'PKI Admin', 'Resource Owner', or 'Guest'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NewUserMatchingRule
Rule(s) for user membership which matches SSO claim data.
Each rule has 3 parts, ClaimName, Operator, and ClaimValue, in the form of a hashtable.
A list/array of hashtables is supported.
For a singlepart claim, the operator can be 'equals', 'does not equal', 'starts with', or 'ends with'.
For a multivalue claim where ClaimValue will be an array, the operator can be 'contains' or 'does not contain'.
ClaimName and ClaimValue are case sensitive.
When providing user AD groups or other groups they are most commonly provided as multivalue claims.
This parameter will overwrite existing rules by default. 
To append use -NoOverwrite.

```yaml
Type: Hashtable[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoOverwrite
Append to existing user matching rules as opposed to overwriting

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

### -PassThru
Return the newly updated team object

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
Aliases: Key

Required: False
Position: Named
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### ID, Name
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS
