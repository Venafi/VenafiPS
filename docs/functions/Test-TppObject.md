# Test-TppObject

## SYNOPSIS
Test if an object exists

## SYNTAX

### DN (Default)
```
Test-TppObject -Path <String[]> [-ExistOnly] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### GUID
```
Test-TppObject -Guid <Guid[]> [-ExistOnly] [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Provided with either a DN path or GUID, find out if an object exists.

## EXAMPLES

### EXAMPLE 1
```
$multDNs | Test-TppObject
Object                    Exists
--------                  -----
\VED\Policy\My folder1    True
\VED\Policy\My folder2    False
```

Test for existence by Path

### EXAMPLE 2
```
Test-TppObject -Path '\VED\Policy\My folder' -ExistOnly
```

Retrieve existence for only one object

## PARAMETERS

### -Path
DN path to object. 
Provide either this or Guid. 
This is the default if both are provided.

```yaml
Type: String[]
Parameter Sets: DN
Aliases: DN

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Guid
Guid which represents a unqiue object. 
Provide either this or Path.

```yaml
Type: Guid[]
Parameter Sets: GUID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ExistOnly
Only return boolean instead of Object and Exists list. 
Helpful when validating just 1 object.

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
Position: Named
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Path or Guid.
## OUTPUTS

### PSCustomObject will be returned with properties 'Object', a System.String, and 'Exists', a System.Boolean.
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Test-TppObject/](http://VenafiPS.readthedocs.io/en/latest/functions/Test-TppObject/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Test-TppObject.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Test-TppObject.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-isvalid.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-isvalid.php)

