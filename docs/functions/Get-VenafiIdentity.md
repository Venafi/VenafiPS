# Get-VenafiIdentity

## SYNOPSIS
Get user and group details

## SYNTAX

### Id (Default)
```
Get-VenafiIdentity -ID <String> [-IncludeAssociated] [-IncludeMembers] [-VenafiSession <PSObject>]
 [<CommonParameters>]
```

### Me
```
Get-VenafiIdentity [-Me] [-VenafiSession <PSObject>] [<CommonParameters>]
```

### All
```
Get-VenafiIdentity [-All] [-IncludeAssociated] [-IncludeMembers] [-VenafiSession <PSObject>]
 [<CommonParameters>]
```

## DESCRIPTION
Returns user/group information for VaaS and TPP.
For VaaS, this returns user information.
For TPP, this returns individual identity, group identity, or distribution groups from a local or non-local provider such as Active Directory.

## EXAMPLES

### EXAMPLE 1
```
Get-VenafiIdentity -ID 'AD+myprov:asdfgadsf9g87df98g7d9f8g7'
```

Get TPP identity details from an id

### EXAMPLE 2
```
Get-VenafiIdentity -ID 9e9db8d6-234a-409c-8299-e3b81ce2f916
```

Get VaaS identity details from an id

### EXAMPLE 3
```
Get-VenafiIdentity -ID me@x.com
```

Get VaaS identity details from a username

### EXAMPLE 4
```
Get-VenafiIdentity -ID 'AD+myprov:asdfgadsf9g87df98g7d9f8g7' -IncludeMembers
```

Get TPP identity details. 
If the identity is a group it will also return the members

### EXAMPLE 5
```
Get-VenafiIdentity -ID 'AD+myprov:asdfgadsf9g87df98g7d9f8g7' -IncludeAssociated
```

Get TPP identity details from an id and include associated groups/folders

### EXAMPLE 6
```
Get-VenafiIdentity -Me
```

Get identity details for authenticated/current user, TPP or VaaS

### EXAMPLE 7
```
Get-VenafiIdentity -All
```

Get all users (VaaS) or all users/groups (TPP)

## PARAMETERS

### -ID
For TPP this is the guid or prefixed universal id. 
To search, use Find-TppIdentity.
For VaaS this can either be the user id (guid) or username which is the email address.

```yaml
Type: String
Parameter Sets: Id
Aliases: Guid, FullName

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Me
Returns the identity of the authenticated/current user

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

### -All
Return a complete list of local users.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeAssociated
Include all associated identity groups and folders. 
TPP only.

```yaml
Type: SwitchParameter
Parameter Sets: Id, All
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeMembers
Include all individual members if the ID is a group. 
TPP only.

```yaml
Type: SwitchParameter
Parameter Sets: Id, All
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
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

### PSCustomObject
### For TPP:
###     Name
###     ID
###     Path
###     FullName
###     Associated (if -IncludeAssociated provided)
###     Members (if -IncludeMembers provided)
### For VaaS:
###     username
###     userId
###     companyId
###     firstname
###     lastname
###     emailAddress
###     userType
###     userAccountType
###     userStatus
###     systemRoles
###     productRoles
###     localLoginDisabled
###     hasPassword
###     firstLoginDate
###     creationDate
###     ownedTeams
###     memberedTeams
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppIdentity/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppIdentity/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppIdentity.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppIdentity.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Validate.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Validate.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Identity-Self.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Identity-Self.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-GetAssociatedEntries.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-GetAssociatedEntries.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-GetMembers.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-GetMembers.php)

[https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Users/users_getAll](https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Users/users_getAll)

[https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Users/users_getById](https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Users/users_getById)

[https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Users/users_getByUsername](https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Users/users_getByUsername)

