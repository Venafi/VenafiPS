# Set-TppCodeSignProjectStatus

## SYNOPSIS
Set project status

## SYNTAX

```
Set-TppCodeSignProjectStatus [-Path] <String> [-Status] <TppCodeSignProjectStatus>
 [[-VenafiSession] <VenafiSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Set project status

## EXAMPLES

### EXAMPLE 1
```
Set-TppCodeSignProject -Path '\ved\code signing\projects\my_project' -Status Pending
Update project status
```

## PARAMETERS

### -Path
Path of the project to update

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

### -Status
New project status, must have the appropriate perms. 
Status can be Disabled, Enabled, Draft, or Pending.

```yaml
Type: TppCodeSignProjectStatus
Parameter Sets: (All)
Aliases:
Accepted values: Disabled, Enabled, Draft, Pending

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

[http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppCodeSignProjectStatus/](http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppCodeSignProjectStatus/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Set-TppCodeSignProjectStatus.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Set-TppCodeSignProjectStatus.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-UpdateProjectStatus.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-UpdateProjectStatus.php)

