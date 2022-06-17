# Remove-TppPermission

## SYNOPSIS
Remove permissions from TPP objects

## SYNTAX

### ByGuid (Default)
```
Remove-TppPermission -Guid <Guid[]> [-IdentityId <String[]>] [-VenafiSession <PSObject>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### ByPath
```
Remove-TppPermission -Path <String[]> [-IdentityId <String[]>] [-VenafiSession <PSObject>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Remove permissions from TPP objects
You can opt to remove permissions for a specific user or all assigned

## EXAMPLES

### EXAMPLE 1
```
Find-TppObject -Path '\VED\Policy\My folder' | Remove-TppPermission
Remove all permissions from a specific object
```

### EXAMPLE 2
```
Find-TppObject -Path '\VED' -Recursive | Remove-TppPermission -IdentityId 'AD+blah:879s8d7f9a8ds7f9s8d7f9'
Remove all permissions for a specific user
```

## PARAMETERS

### -Path
Full path to an object. 
You can also pipe in a TppObject

```yaml
Type: String[]
Parameter Sets: ByPath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Guid
{{ Fill Guid Description }}

```yaml
Type: Guid[]
Parameter Sets: ByGuid
Aliases: ObjectGuid

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -IdentityId
Prefixed Universal Id of the user or group to have their permissions removed

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: PrefixedUniversalId

Required: False
Position: Named
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

### Path, Guid, IdentityId
## OUTPUTS

### None
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppPermission/](http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppPermission/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppPermission.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppPermission.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-DELETE-Permissions-object-guid-principal.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-DELETE-Permissions-object-guid-principal.php)

