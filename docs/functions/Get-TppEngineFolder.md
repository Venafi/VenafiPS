# Get-TppEngineFolder

## SYNOPSIS
Get TPP folder/engine assignments

## SYNTAX

### ID (Default)
```
Get-TppEngineFolder [-ID] <String> [-VenafiSession <PSObject>] [<CommonParameters>]
```

### All
```
Get-TppEngineFolder [-All] [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
When the input is a policy folder, retrieves an array of assigned TPP processing engines.
When the input is a TPP engine, retrieves an array of assigned policy folders.
If there are no matching assignments, nothing will be returned.

## EXAMPLES

### EXAMPLE 1
```
Get-TppEngineFolder -Path '\VED\Engines\MYVENSERVER'
```

Get an array of policy folders assigned to the TPP processing engine 'MYVENSERVER'.

### EXAMPLE 2
```
Get-TppEngineFolder -Path '\VED\Policy\Certificates\Web Team'
```

Get an array of TPP processing engines assigned to the policy folder '\VED\Policy\Certificates\Web Team'.

### EXAMPLE 3
```
[guid]'866e1d59-d5d2-482a-b9e6-7bb657e0f416' | Get-TppEngineFolder
```

When the GUID is assigned to a TPP processing engine, returns an array of assigned policy folders.
When the GUID is assigned to a policy folder, returns an array of assigned TPP processing engines.
Otherwise nothing will be returned.

## PARAMETERS

### -ID
The full DN path or Guid to a TPP processing engine or policy folder.

```yaml
Type: String
Parameter Sets: ID
Aliases: EngineGuid, Guid, EnginePath, Path

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -All
Get all engine/folder assignments

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
A TPP token can also provided, but this requires an environment variable TPP_SERVER to be set.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### ID
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppEngineFolder/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppEngineFolder/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppEngineFolder.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppEngineFolder.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-ProcessingEngines-Engine-eguid.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-ProcessingEngines-Engine-eguid.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-ProcessingEngines-Folder-fguid.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-ProcessingEngines-Folder-fguid.php)

