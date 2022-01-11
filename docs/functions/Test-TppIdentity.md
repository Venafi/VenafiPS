# Test-TppIdentity

## SYNOPSIS
Test if an identity exists

## SYNTAX

```
Test-TppIdentity [-ID] <String[]> [-ExistOnly] [[-VenafiSession] <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Provided with a prefixed universal id, find out if an identity exists.

## EXAMPLES

### EXAMPLE 1
```
'local:78uhjny657890okjhhh', 'AD+mydomain.com:azsxdcfvgbhnjmlk09877654321' | Test-TppIdentity
```

Test multiple identities

### EXAMPLE 2
```
Test-TppIdentity -Identity 'AD+mydomain.com:azsxdcfvgbhnjmlk09877654321' -ExistOnly
```

Retrieve existence for only one identity, returns boolean

## PARAMETERS

### -ID
{{ Fill ID Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: PrefixedUniversal, Contact, IdentityId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ExistOnly
Only return boolean instead of ID and Exists list. 
Helpful when validating just 1 identity.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
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
Position: 2
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Identity
## OUTPUTS

### PSCustomObject will be returned with properties 'ID', a System.String, and 'Exists', a System.Boolean.
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Test-TppIdentity/](http://VenafiPS.readthedocs.io/en/latest/functions/Test-TppIdentity/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Test-TppIdentity.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Test-TppIdentity.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Validate.php?tocpath=Web%20SDK%7CIdentity%20programming%20interface%7C_____15](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Validate.php?tocpath=Web%20SDK%7CIdentity%20programming%20interface%7C_____15)

