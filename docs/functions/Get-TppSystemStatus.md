# Get-TppSystemStatus

## SYNOPSIS
Get the TPP system status

## SYNTAX

```
Get-TppSystemStatus [[-VenafiSession] <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Returns service module statuses for Trust Protection Platform, Log Server, and Trust Protection Platform services that run on Microsoft Internet Information Services (IIS)

## EXAMPLES

### EXAMPLE 1
```
Get-TppSystemStatus
Get the status
```

## PARAMETERS

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
Position: 1
Default value: $script:VenafiSession
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

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppSystemStatus/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppSystemStatus/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppSystemStatus.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppSystemStatus.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-SystemStatus.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-SystemStatus.php)

