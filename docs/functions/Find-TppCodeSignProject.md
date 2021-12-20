# Find-TppCodeSignProject

## SYNOPSIS
Search for code sign projects

## SYNTAX

### All (Default)
```
Find-TppCodeSignProject [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### Name
```
Find-TppCodeSignProject -Name <String> [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Search for specific code sign projects or return all

## EXAMPLES

### EXAMPLE 1
```
Find-TppCodeSignProject
```

Get all code sign projects

### EXAMPLE 2
```
Find-TppCodeSignProject -Name CSTest
```

Find all projects that match the name CSTest

## PARAMETERS

### -Name
Name of the project to search for

```yaml
Type: String
Parameter Sets: Name
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
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

### None
## OUTPUTS

### TppObject
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppCodeSignProject/](http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppCodeSignProject/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppCodeSignProject.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppCodeSignProject.ps1)

[https://docs.venafi.com/Docs/20.3/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-EnumerateProjects.php?tocpath=CodeSign%20Protect%20SDK%20reference%7CProjects%20and%20environments%7C_____8](https://docs.venafi.com/Docs/20.3/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-EnumerateProjects.php?tocpath=CodeSign%20Protect%20SDK%20reference%7CProjects%20and%20environments%7C_____8)

