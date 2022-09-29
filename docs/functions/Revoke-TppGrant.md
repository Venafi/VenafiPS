# Revoke-TppGrant

## SYNOPSIS
Revoke all grants for a specific user

## SYNTAX

```
Revoke-TppGrant [[-ID] <String[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Revoke all grants for a specific user.
You must either be an administrator or oauth administrator to perform this action.
Also, your token must have the admin:delete scope.

## EXAMPLES

### EXAMPLE 1
```
Revoke-TppGrant -ID local:{9e9db8d6-234a-409c-8299-e3b81ce2f916}
```

Revoke all grants for a user

### EXAMPLE 2
```
Get-VenafiIdentity -ID me@x.com | Revoke-TppGrant
```

Revoke all grants getting universal id from other identity functions

## PARAMETERS

### -ID
Prefixed universal id for the user. 
To search, use Find-TppIdentity.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: PrefixedUniversalID, IdentityID

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### None
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Revoke-TppGrant/](http://VenafiPS.readthedocs.io/en/latest/functions/Revoke-TppGrant/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Revoke-TppGrant.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Revoke-TppGrant.ps1)

[https://doc.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-oauth-revokegrants.htm](https://doc.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-oauth-revokegrants.htm)

