# Get-TppVersion

## SYNOPSIS
Get the TPP version

## SYNTAX

```
Get-TppVersion [[-VenafiSession] <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Returns the TPP version

## EXAMPLES

### EXAMPLE 1
```
Get-TppVersion
```

Get the version

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
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### none
## OUTPUTS

### Version
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppVersion/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppVersion/)

[https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Get-TppVersion.ps1](https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Get-TppVersion.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-SystemStatusVersion.php?tocpath=Web%20SDK%7CSystemStatus%20programming%20interface%7C_____9](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-SystemStatusVersion.php?tocpath=Web%20SDK%7CSystemStatus%20programming%20interface%7C_____9)

