# Remove-TppPermission

## SYNOPSIS
Remove permissions from TPP objects

## SYNTAX

### ByGuid (Default)
```
Remove-TppPermission -Guid <Guid[]> [-IdentityId <String[]>] [-VenafiSession <VenafiSession>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### ByPath
```
Remove-TppPermission -Path <String[]> [-IdentityId <String[]>] [-VenafiSession <VenafiSession>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Remove permissions from TPP objects
You can opt to remove permissions for a specific user or all assigned

## EXAMPLES

### EXAMPLE 1
```
Find-TppObject -Path '\VED\Policy\My folder' | Remove-TppPermission
```

Remove all permissions from a specific object

### EXAMPLE 2
```
Find-TppObject -Path '\VED' -Recursive | Remove-TppPermission -IdentityId 'AD+blah:879s8d7f9a8ds7f9s8d7f9'
```

Remove all permissions for a specific user

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
Session object created from New-VenafiSession method.
The value defaults to the script session object $VenafiSession.

```yaml
Type: VenafiSession
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $Script:VenafiSession
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

[http://venafitppps.readthedocs.io/en/latest/functions/Remove-TppPermission/](http://venafitppps.readthedocs.io/en/latest/functions/Remove-TppPermission/)

[https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Remove-TppPermission.ps1](https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Remove-TppPermission.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-DELETE-Permissions-object-guid-principal.php?tocpath=Web%20SDK%7CPermissions%20programming%20interface%7C_____6](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-DELETE-Permissions-object-guid-principal.php?tocpath=Web%20SDK%7CPermissions%20programming%20interface%7C_____6)

