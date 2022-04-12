# Remove-TppCodeSignEnvironment

## SYNOPSIS
Delete a code sign certificate environment

## SYNTAX

```
Remove-TppCodeSignEnvironment [-Path] <String> [[-VenafiSession] <PSObject>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Delete a code sign certificate environment and related objects such as keys and certificates.
You must be a code sign admin or owner of the project.

## EXAMPLES

### EXAMPLE 1
```
Remove-TppCodeSignEnvironment -Path '\ved\code signing\projects\my_project\dev'
Delete an environment
```

### EXAMPLE 2
```
$envObj | Remove-TppCodeSignEnvironment
Remove 1 or more environments.  Get environments with Find-TppCodeSignEnvironment
```

## PARAMETERS

### -Path
Path of the environment to delete

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TppServer must also be set.

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

### Path
## OUTPUTS

### None
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppCodeSignEnvironment/](http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppCodeSignEnvironment/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppCodeSignEnvironment.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppCodeSignEnvironment.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-DeleteEnvironment.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-DeleteEnvironment.php)

