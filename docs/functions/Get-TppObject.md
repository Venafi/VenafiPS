# Get-TppObject

## SYNOPSIS
Get object information

## SYNTAX

### ByPath
```
Get-TppObject [-Path] <String[]> [-VenafiSession <PSObject>] [<CommonParameters>]
```

### ByGuid
```
Get-TppObject -Guid <Guid[]> [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Return object information by either path or guid. 
This will return a TppObject which can be used with many other functions.

## EXAMPLES

### EXAMPLE 1
```
Get-TppObject -Path '\VED\Policy\My object'
```

Get an object by path

### EXAMPLE 2
```
[guid]'dab22152-0a81-4fb8-a8da-8c5e3d07c3f1' | Get-TppObject
```

Get an object by guid

## PARAMETERS

### -Path
The full path to the object

```yaml
Type: String[]
Parameter Sets: ByPath
Aliases: DN

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Guid
Guid of the object

```yaml
Type: Guid[]
Parameter Sets: ByGuid
Aliases: ObjectGuid

Required: True
Position: Named
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
Position: Named
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Path, Guid
## OUTPUTS

### TppObject
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppObject/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppObject/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppObject.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppObject.ps1)

