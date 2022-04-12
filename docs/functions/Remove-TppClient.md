# Remove-TppClient

## SYNOPSIS
Remove registered client agents

## SYNTAX

```
Remove-TppClient [-ClientId] <String[]> [-RemoveAssociatedDevices] [[-VenafiSession] <PSObject>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Remove registered client agents.
Provide an array of client IDs to remove a large list at once.

## EXAMPLES

### EXAMPLE 1
```
Remove-TppClient -ClientId 1234
Remove a client
```

## PARAMETERS

### -ClientId
Unique id for one or more clients

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -RemoveAssociatedDevices
{{ Fill RemoveAssociatedDevices Description }}

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

### ClientId
## OUTPUTS

### None
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppClient/](http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppClient/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppClient.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppClient.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-ClientDelete.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-ClientDelete.php)

