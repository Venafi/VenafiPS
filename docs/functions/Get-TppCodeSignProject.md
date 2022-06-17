# Get-TppCodeSignProject

## SYNOPSIS
Get a code sign project

## SYNTAX

```
Get-TppCodeSignProject [-Path] <String> [[-VenafiSession] <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Get code sign project details

## EXAMPLES

### EXAMPLE 1
```
Get-TppCodeSignProject -Path '\ved\code signing\projects\my_project'
Get a code sign project
```

### EXAMPLE 2
```
$projectObj | Get-TppCodeSignProject
Get a project after searching using Find-TppCodeSignProject
```

## PARAMETERS

### -Path
Path of the project to get

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

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
Position: 2
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Path
## OUTPUTS

### PSCustomObject with the following properties:
###     Application
###     Auditor
###     CertificateEnvironment
###     Collection
###     CreatedOn
###     Guid
###     Id
###     KeyUseApprover
###     KeyUser
###     Owner
###     Status
###     Name
###     Path
###     TypeName
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppCodeSignProject/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppCodeSignProject/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppCodeSignProject.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppCodeSignProject.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-GetProject.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-GetProject.php)

