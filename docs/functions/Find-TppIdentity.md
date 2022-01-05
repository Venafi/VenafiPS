# Find-TppIdentity

## SYNOPSIS
Search for identity details

## SYNTAX

### Find (Default)
```
Find-TppIdentity -Name <String[]> [-First <Int32>] [-IncludeUsers] [-IncludeSecurityGroups]
 [-IncludeDistributionGroups] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### Me
```
Find-TppIdentity [-Me] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Returns information about individual identity, group identity, or distribution groups from a local or non-local provider such as Active Directory.
You can specify individual identity types to search for or all

## EXAMPLES

### EXAMPLE 1
```
Find-TppIdentity -Name 'greg' -IncludeUsers
```

Find only user identities with the name greg

### EXAMPLE 2
```
'greg', 'brownstein' | Find-TppIdentity
```

Find all identity types with the name greg and brownstein

## PARAMETERS

### -Name
The individual identity, group identity, or distribution group name to search for

```yaml
Type: String[]
Parameter Sets: Find
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -First
First how many items are returned, the default is 500, but is limited by the provider.

```yaml
Type: Int32
Parameter Sets: Find
Aliases: Limit

Required: False
Position: Named
Default value: 500
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeUsers
Include user identity type in search

```yaml
Type: SwitchParameter
Parameter Sets: Find
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeSecurityGroups
Include security group identity type in search

```yaml
Type: SwitchParameter
Parameter Sets: Find
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDistributionGroups
Include distribution group identity type in search

```yaml
Type: SwitchParameter
Parameter Sets: Find
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Me
Returns the identity of the authenticated user and all associated identities. 
Will be deprecated in a future release, use Get-TppIdentity -Me instead.

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

### Name
## OUTPUTS

### PSCustomObject with the following properties:
###     Name
###     ID
###     Path
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppIdentity/](http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppIdentity/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppIdentity.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppIdentity.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Browse.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Browse.php)

