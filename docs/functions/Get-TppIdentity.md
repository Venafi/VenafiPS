# Get-TppIdentity

## SYNOPSIS
Get identity details

## SYNTAX

### Id (Default)
```
Get-TppIdentity -ID <String[]> [-IncludeAssociated] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### Me
```
Get-TppIdentity [-Me] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Returns information about individual identity, group identity, or distribution groups from a local or non-local provider such as Active Directory.

## EXAMPLES

### EXAMPLE 1
```
Get-TppIdentity -ID 'AD+myprov:asdfgadsf9g87df98g7d9f8g7'
```

Get identity details from an id

### EXAMPLE 2
```
Get-TppIdentity -ID 'AD+myprov:asdfgadsf9g87df98g7d9f8g7' -IncludeAssociated
```

Get identity details from an id and include associated groups/folders

### EXAMPLE 3
```
Get-TppIdentity -Me
```

Get identity details for user in the current session

## PARAMETERS

### -ID
The individual identity, group identity, or distribution group prefixed universal id

```yaml
Type: String[]
Parameter Sets: Id
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -IncludeAssociated
Include all associated identity groups and folders

```yaml
Type: SwitchParameter
Parameter Sets: Id
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Me
Returns the identity of the authenticated user

```yaml
Type: SwitchParameter
Parameter Sets: Me
Aliases:

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

### ID
## OUTPUTS

### PSCustomObject with the following properties:
###     Name
###     ID
###     Path
###     Associated (if -IncludeAssociated provided)
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppIdentity/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppIdentity/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppIdentity.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppIdentity.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Validate.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Validate.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Identity-Self.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Identity-Self.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-GetAssociatedEntries.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-GetAssociatedEntries.php)

