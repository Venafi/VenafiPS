# Set-TppPermission

## SYNOPSIS
Set permissions for TPP objects

## SYNTAX

### ByGuid (Default)
```
Set-TppPermission -Guid <Guid[]> -IdentityId <String[]> -Permission <TppPermission> [-Force]
 [-VenafiSession <VenafiSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByPath
```
Set-TppPermission -Path <String[]> -IdentityId <String[]> -Permission <TppPermission> [-Force]
 [-VenafiSession <VenafiSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Adds or modifies permissions on TPP objects

## EXAMPLES

### EXAMPLE 1
```
Set-TppPermission -Guid '1234abcd-g6g6-h7h7-faaf-f50cd6610cba' -IdentityId 'AD+mydomain.com:azsxdcfvgbhnjmlk09877654321' -Permission $TppPermObject
```

Permission a user/group on an object specified by guid

### EXAMPLE 2
```
Set-TppPermission -Path '\ved\policy\my folder' -IdentityId 'AD+mydomain.com:azsxdcfvgbhnjmlk09877654321' -Permission $TppPermObject
```

Permission a user/group on an object specified by path

### EXAMPLE 3
```
$id = Find-TppIdentity -Name 'brownstein' | Select-Object -ExpandProperty Id
```

Find-TppObject -Path '\VED' -Recursive | Get-TppPermission -IdentityId $id | Set-TppPermission -Permission $TppPermObject -Force

Reset permissions for a specific user/group for all objects. 
Note the use of -Force to overwrite existing permissions.

## PARAMETERS

### -Path
Path to an object. 
Can pipe output from many other functions.

```yaml
Type: String[]
Parameter Sets: ByPath
Aliases: DN

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Guid
Guid representing a unique object

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
The id that represents the user or group. 
You can use Find-TppIdentity or Get-TppPermission to get the id.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: PrefixedUniversalId, ID

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Permission
TppPermission object. 
You can create a new object or get existing object from Get-TppPermission.

```yaml
Type: TppPermission
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Overwrite an existing permission if one exists

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
Session object created from New-VenafiSession method. 
The value defaults to the script session object $VenafiSession.

```yaml
Type: VenafiSession
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
Confirmation impact is set to Medium, set ConfirmPreference accordingly.

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppPermission/](http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppPermission/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Set-TppPermission.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Set-TppPermission.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Permissions-object-guid-principal.php?tocpath=Web%20SDK%7CPermissions%20programming%20interface%7C_____8](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Permissions-object-guid-principal.php?tocpath=Web%20SDK%7CPermissions%20programming%20interface%7C_____8)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-PUT-Permissions-object-guid-principal.php?tocpath=Web%20SDK%7CPermissions%20programming%20interface%7C_____9](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-PUT-Permissions-object-guid-principal.php?tocpath=Web%20SDK%7CPermissions%20programming%20interface%7C_____9)

