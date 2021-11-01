# Get-TppAttribute

## SYNOPSIS
Get attributes for a given object

## SYNTAX

### ByPath (Default)
```
Get-TppAttribute -Path <String[]> [-Attribute <String[]>] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### AllByPath
```
Get-TppAttribute -Path <String[]> [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### EffectiveByPath
```
Get-TppAttribute -Path <String[]> -Attribute <String[]> [-Effective] [-VenafiSession <VenafiSession>]
 [<CommonParameters>]
```

### ByGuid
```
Get-TppAttribute -Guid <Guid[]> [-Attribute <String[]>] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### EffectiveByGuid
```
Get-TppAttribute -Guid <Guid[]> -Attribute <String[]> [-Effective] [-VenafiSession <VenafiSession>]
 [<CommonParameters>]
```

## DESCRIPTION
Retrieves object attributes. 
You can either retrieve all attributes or individual ones.
By default, the attributes returned are not the effective policy, but that can be requested with the
EffectivePolicy switch.

## EXAMPLES

### EXAMPLE 1
```
Get-TppAttribute -Path '\VED\Policy\My Folder\myapp.company.com'
```

Retrieve all configurations for a certificate

### EXAMPLE 2
```
Get-TppAttribute -Path '\VED\Policy\My Folder\myapp.company.com' -EffectivePolicy
```

Retrieve all effective configurations for a certificate

### EXAMPLE 3
```
Get-TppAttribute -Path '\VED\Policy\My Folder\myapp.company.com' -AttributeName 'driver name'
```

Retrieve all the value for attribute driver name from certificate myapp.company.com

## PARAMETERS

### -Path
Path to the object to retrieve configuration attributes. 
Just providing DN will return all attributes.

```yaml
Type: String[]
Parameter Sets: ByPath, AllByPath, EffectiveByPath
Aliases: DN

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Guid
Object Guid. 
Just providing Guid will return all attributes.

```yaml
Type: Guid[]
Parameter Sets: ByGuid, EffectiveByGuid
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Attribute
{{ Fill Attribute Description }}

```yaml
Type: String[]
Parameter Sets: ByPath, ByGuid
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String[]
Parameter Sets: EffectiveByPath, EffectiveByGuid
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Effective
Get the effective values of the attribute

```yaml
Type: SwitchParameter
Parameter Sets: EffectiveByPath, EffectiveByGuid
Aliases: EffectivePolicy

Required: True
Position: Named
Default value: False
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
Position: Named
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Path, Guid
## OUTPUTS

### PSCustomObject with properties Name, Value, IsCustomField, and CustomName
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppAttribute/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppAttribute/)

[https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Public/Get-TppAttribute.ps1](https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Public/Get-TppAttribute.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-read.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____27](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-read.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____27)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-readall.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____28](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-readall.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____28)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-readeffectivepolicy.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____31](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-readeffectivepolicy.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____31)

