# Get-TppSystemStatus

## SYNOPSIS
Get the TPP system status

## SYNTAX

```
Get-TppSystemStatus [[-VenafiSession] <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Returns service module statuses for Trust Protection Platform, Log Server, and Trust Protection Platform services that run on Microsoft Internet Information Services (IIS)

## EXAMPLES

### EXAMPLE 1
```
Get-TppSystemStatus
```

Get the status

## PARAMETERS

### -VenafiSession
Session object created from New-VenafiSession method.
The value defaults to the script session object $VenafiSession.

```yaml
Type: VenafiSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $Script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### none
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS

[http://venafitppps.readthedocs.io/en/latest/functions/Get-TppSystemStatus/](http://venafitppps.readthedocs.io/en/latest/functions/Get-TppSystemStatus/)

[https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Get-TppSystemStatus.ps1](https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Get-TppSystemStatus.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-SystemStatus.php?tocpath=Web%20SDK%7CSystemStatus%20programming%20interface%7C_____3](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-SystemStatus.php?tocpath=Web%20SDK%7CSystemStatus%20programming%20interface%7C_____3)

