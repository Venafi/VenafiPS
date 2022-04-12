# Get-TppCredential

## SYNOPSIS
Get credential details

## SYNTAX

```
Get-TppCredential [-Path] <String> [[-VenafiSession] <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Get credential details.
Object returned will depend on the credential type.

## EXAMPLES

### EXAMPLE 1
```
Get-TppCredential -Path '\VED\Policy\MySecureCred'
Get a credential
```

## PARAMETERS

### -Path
The full path to the credential object

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
If providing a TPP token, an environment variable named TppServer must also be set.

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

### Password/UsernamePassword Credential - PSCredential
### Certificate Credential - X509Certificate2
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppCredential/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppCredential/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppCredential.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppCredential.ps1)

