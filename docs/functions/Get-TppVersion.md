# Get-TppVersion

## SYNOPSIS
Get the TPP version

## SYNTAX

```
Get-TppVersion [[-VenafiSession] <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Returns the TPP version

## EXAMPLES

### EXAMPLE 1
```
Get-TppVersion
Get the version
```

## PARAMETERS

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

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppVersion.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppVersion.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-SystemStatusVersion.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-SystemStatusVersion.php)

