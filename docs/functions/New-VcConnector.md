# New-VcConnector

## SYNOPSIS
Create a new connector

## SYNTAX

```
New-VcConnector [-ManifestPath] <String> [-PassThru] [[-VenafiSession] <PSObject>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Create a new machine, CA, TPP, or credential connector

## EXAMPLES

### EXAMPLE 1
```
New-VcConnector -ManifestPath '/tmp/manifest.json'
```

Create a new connector

### EXAMPLE 2
```
New-VcConnector -ManifestPath '/tmp/manifest.json' -PassThru
```

Create a new connector and return the newly created connector object

## PARAMETERS

### -ManifestPath
Path to an existing manifest.
Ensure the manifest has the deployment element which is not needed when testing in the simulator.
See https://github.com/Venafi/vmware-avi-connector?tab=readme-ov-file#manifest for details.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Return newly created connector object

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
A TLSPC key can also provided.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
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

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSCustomObject, if PassThru provided
## NOTES

## RELATED LINKS

[https://developer.venafi.com/tlsprotectcloud/reference/post-v1-plugins](https://developer.venafi.com/tlsprotectcloud/reference/post-v1-plugins)

