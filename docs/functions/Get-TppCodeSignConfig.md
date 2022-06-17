# Get-TppCodeSignConfig

## SYNOPSIS
Get CodeSign Protect project settings

## SYNTAX

```
Get-TppCodeSignConfig [[-VenafiSession] <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Get CodeSign Protect project settings. 
Must have token with scope codesign:manage.

## EXAMPLES

### EXAMPLE 1
```
Get-TppCodeSignConfig
Get settings
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

### None
## OUTPUTS

### PSCustomObject with the following properties:
###     ApprovedKeyStorageLocations
###     AvailableKeyStorageLocations
###     DefaultCAContainer
###     DefaultCertificateContainer
###     DefaultCredentialContainer
###     KeyUseTimeout
###     ProjectDescriptionTooltip
###     RequestInProgressMessage
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppCodeSignConfig/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppCodeSignConfig/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppCodeSignConfig.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppCodeSignConfig.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-GET-Codesign-GetGlobalConfiguration.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-GET-Codesign-GetGlobalConfiguration.php)

