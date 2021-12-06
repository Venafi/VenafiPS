# Convert-TppObject

## SYNOPSIS
Change the class/object type of an existing object

## SYNTAX

```
Convert-TppObject [-Path] <String> [-Class] <String> [[-VenafiSession] <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Change the class/object type of an existing object

## EXAMPLES

### EXAMPLE 1
```
Convert-TppObject -Path '\ved\policy\' -Class 'X509 Device Certificate'
```

Convert an object to a different type

## PARAMETERS

### -Path
Path to the object

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

### -Class
New class/type

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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

### Path
## OUTPUTS

### None
## NOTES

## RELATED LINKS
