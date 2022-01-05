# Get-TppIdentityAttribute

## SYNOPSIS
Get attribute values for TPP identity objects

## SYNTAX

```
Get-TppIdentityAttribute [-ID] <String[]> [[-Attribute] <String[]>] [[-VenafiSession] <VenafiSession>]
 [<CommonParameters>]
```

## DESCRIPTION
Get attribute values for TPP identity objects.

## EXAMPLES

### EXAMPLE 1
```
Get-TppIdentityAttribute -IdentityId 'AD+blah:{1234567890olikujyhtgrfedwsqa}'
```

Get basic attributes

### EXAMPLE 2
```
Get-TppIdentityAttribute -IdentityId 'AD+blah:{1234567890olikujyhtgrfedwsqa}' -Attribute 'Surname'
```

Get specific attribute for user

## PARAMETERS

### -ID
The id that represents the user or group. 
Use Find-TppIdentity to get the id.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: PrefixedUniversalId, Contact, IdentityId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Attribute
Retrieve identity attribute values for the users and groups.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
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
Position: 3
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### ID
## OUTPUTS

### PSCustomObject with the properties Identity and Attribute
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppIdentityAttribute/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppIdentityAttribute/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppIdentityAttribute.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppIdentityAttribute.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Validate.php?tocpath=Web%20SDK%7CIdentity%20programming%20interface%7C_____15](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Validate.php?tocpath=Web%20SDK%7CIdentity%20programming%20interface%7C_____15)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Readattribute.php?tocpath=Web%20SDK%7CIdentity%20programming%20interface%7C_____10](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Readattribute.php?tocpath=Web%20SDK%7CIdentity%20programming%20interface%7C_____10)

