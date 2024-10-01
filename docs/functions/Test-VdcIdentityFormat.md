# Test-VdcIdentityFormat

## SYNOPSIS
Validate identity formats

## SYNTAX

```
Test-VdcIdentityFormat [-ID] <String> [[-Format] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Validate the format for identities prefixed name, prefixed universal, and local.
As these formats are often interchangeable with api calls, you can validate multiple formats at once.
By default, prefixed name and prefixed universal will be validated.

## EXAMPLES

### EXAMPLE 1
```
Test-VdcIdentityFormat -ID "AD+BigSur:cypher"
```

Test the identity against all formats. 
This would succeed for Name, but fail on Universal

### EXAMPLE 2
```
Test-VdcIdentityFormat -ID "AD+BigSur:cypher" -Format Name
```

Test the identity against a specific format.

## PARAMETERS

### -ID
{{ Fill ID Description }}

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

### -Format
Format to validate, Name, Universal, and/or Local.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Boolean
## NOTES

## RELATED LINKS
