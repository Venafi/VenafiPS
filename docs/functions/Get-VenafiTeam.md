# Get-VenafiTeam

## SYNOPSIS
Get Team info

## SYNTAX

### ID
```
Get-VenafiTeam -ID <String> [-VenafiSession <PSObject>] [<CommonParameters>]
```

### All
```
Get-VenafiTeam [-All] [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Get info for a VaaS or TPP team including members and owners.
For VaaS, you can retrieve info on all teams as well.

## EXAMPLES

### EXAMPLE 1
```
Get-VenafiTeam -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
```

Get info for a VaaS team

### EXAMPLE 2
```
Get-VenafiTeam -ID 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}'
```

Get info for a TPP team

### EXAMPLE 3
```
Find-TppIdentity -Name MyTeamName | Get-VenafiTeam
```

Search for a team and then get details

### EXAMPLE 4
```
Get-VenafiTeam -All
```

Get info for all teams

## PARAMETERS

### -ID
Team ID, required for TPP.
For VaaS, this is the team guid.
For TPP, this is the local prefixed universal ID. 
You can find the group ID with Find-TppIdentity.

```yaml
Type: String
Parameter Sets: ID
Aliases: PrefixedUniversal, Guid, PrefixedName

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -All
Provide this switch to get all teams

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

### -VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases: Key, AccessToken

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

[https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Teams/get_2](https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Teams/get_2)

[https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Teams/get_1](https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Teams/get_1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Teams-prefix-universal.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Teams-prefix-universal.php)

