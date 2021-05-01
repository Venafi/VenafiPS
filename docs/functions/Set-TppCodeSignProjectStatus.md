# Set-TppCodeSignProjectStatus

## SYNOPSIS
Set project status

## SYNTAX

```
Set-TppCodeSignProjectStatus [-Path] <String> [-Status] <TppCodeSignProjectStatus> [[-TppSession] <TppSession>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Set project status

## EXAMPLES

### EXAMPLE 1
```
Set-TppCodeSignProject -Path '\ved\code signing\projects\my_project' -Status Pending
```

Update project status

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

### -TppSession
Session object created from New-TppSession method. 
The value defaults to the script session object $TppSession.

```yaml
Type: TppSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: $Script:TppSession
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

[http://venafitppps.readthedocs.io/en/latest/functions/Set-TppCodeSignProjectStatus/](http://venafitppps.readthedocs.io/en/latest/functions/Set-TppCodeSignProjectStatus/)

[https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Set-TppCodeSignProjectStatus.ps1](https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Set-TppCodeSignProjectStatus.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-UpdateProjectStatus.php?tocpath=CodeSign%20Protect%20Admin%20REST%C2%A0API%7CProjects%20and%20environments%7C_____14](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-UpdateProjectStatus.php?tocpath=CodeSign%20Protect%20Admin%20REST%C2%A0API%7CProjects%20and%20environments%7C_____14)

