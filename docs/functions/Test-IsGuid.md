# Test-IsGuid

## SYNOPSIS
Validates a given input string and checks string is a valid GUID

## SYNTAX

```
Test-IsGuid [-InputObject] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Validates a given input string and checks string is a valid GUID by using the .NET method Guid.TryParse

## EXAMPLES

### EXAMPLE 1
```
Test-Guid -InputObject "3363e9e1-00d8-45a1-9c0c-b93ee03f8c13"
```

## PARAMETERS

### -InputObject
{{ Fill InputObject Description }}

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
Uses .NET method \[guid\]::TryParse()

## RELATED LINKS
