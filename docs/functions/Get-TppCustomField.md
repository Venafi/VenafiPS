# Get-TppCustomField

## SYNOPSIS
Get custom field details

## SYNTAX

```
Get-TppCustomField [-Class] <String> [[-VenafiSession] <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Get details about custom fields

## EXAMPLES

### EXAMPLE 1
```
Get-TppCustomField -Class 'X509 Certificate'
Get custom fields for certificates
```

## PARAMETERS

### -Class
Class to get details on

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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

### None
## OUTPUTS

### Query returns a PSCustomObject with the following properties:
###     Items
###         AllowedValues
###         Classes
###         ConfigAttribute
###         DN
###         DefaultValues
###         Guid
###         Label
###         Mandatory
###         Name
###         Policyable
###         RenderHidden
###         RenderReadOnly
###         Single
###         Type
###     Locked
###     Result
## NOTES
All custom fields are retrieved upon inital connect to the server and a property of VenafiSession

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppCustomField/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppCustomField/)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-GetItemsForClass.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-GetItemsForClass.php)

