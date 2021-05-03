# Get-TppCodeSignEnvironment

## SYNOPSIS
Get a code sign environment

## SYNTAX

```
Get-TppCodeSignEnvironment [-Path] <String> [[-VenafiSession] <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Get code sign environment details

## EXAMPLES

### EXAMPLE 1
```
Get-TppCodeSignEnvironment -Path '\ved\code signing\projects\my_project\my_env'
```

Get a code sign environment

### EXAMPLE 2
```
$envObj | Get-TppCodeSignEnvironment
```

Get a environment after searching using Find-TppCodeSignEnvironment

## PARAMETERS

### -Path
Path of the environment to get

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
Session object created from New-VenafiSession method.
The value defaults to the script session object $VenafiSession.

```yaml
Type: VenafiSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $Script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Path
## OUTPUTS

### PSCustomObject with the following properties:
###     AllowUserKeyImport
###     Disabled
###     Guid
###     Id
###     CertificateStatus
###     CertificateStatusText
###     CertificateTemplate
###     SynchronizeChain
###     Path
###     Name
###     TypeName
###     OrganizationalUnit
###     IPAddressRestriction
###     KeyUseFlowPath
###     TemplatePath
###     CertificateAuthorityPath
###     CertificatePath
###     CertificateSubject
###     City
###     KeyAlgorithm
###     KeyStorageLocation
###     Organization
###     OrganizationUnit
###     SANEmail
###     State
###     Country
## NOTES

## RELATED LINKS

[http://venafitppps.readthedocs.io/en/latest/functions/Get-TppCodeSignEnvironment/](http://venafitppps.readthedocs.io/en/latest/functions/Get-TppCodeSignEnvironment/)

[https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Get-TppCodeSignEnvironment.ps1](https://github.com/gdbarron/VenafiTppPS/blob/main/VenafiTppPS/Code/Public/Get-TppCodeSignEnvironment.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-GetEnvironment.php?tocpath=CodeSign%20Protect%20Admin%20REST%C2%A0API%7CProjects%20and%20environments%7C_____9](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-GetEnvironment.php?tocpath=CodeSign%20Protect%20Admin%20REST%C2%A0API%7CProjects%20and%20environments%7C_____9)

