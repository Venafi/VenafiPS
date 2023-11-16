# Get-VcTag

## SYNOPSIS
Get tags from TLSPC

## SYNTAX

### ID
```
Get-VcTag [-Name] <String> [-VenafiSession <PSObject>] [<CommonParameters>]
```

### All
```
Get-VcTag [-All] [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Get 1 or all tags.
Tag values will be provided.

## EXAMPLES

### EXAMPLE 1
```
Get-VcTag -Name 'MyTag'
```

Get a single tag

### EXAMPLE 2
```
Get-VcTag -All
```

Get all tags

## PARAMETERS

### -Name
Tag name

```yaml
Type: String
Parameter Sets: ID
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -All
Get all tags

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TLSPC key can also provided.key can also provided.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Name
## OUTPUTS

## NOTES

## RELATED LINKS
