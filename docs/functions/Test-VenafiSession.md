# Test-VenafiSession

## SYNOPSIS
Validate authentication session/key/token

## SYNTAX

### All (Default)
```
Test-VenafiSession -VenafiSession <PSObject> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Platform
```
Test-VenafiSession -VenafiSession <PSObject> -Platform <String> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Validate authentication session from New-VenafiSession, a TLSPC key, or TLSPDC token.

## EXAMPLES

### EXAMPLE 1
```
Test-VenafiSession -VenafiSession $VenafiSession
Test a session
```

### EXAMPLE 2
```
Test-VenafiSession -VenafiSession $VenafiSession -PassThru
Test a session and return the platform type found
```

### EXAMPLE 3
```
Test-VenafiSession -VenafiSession $key
Test a TLSPC key
```

### EXAMPLE 4
```
Test-VenafiSession -VenafiSession $VenafiSession -Platform TLSPDC
Test session ensuring the platform is TLSPDC
```

## PARAMETERS

### -VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TLSPDC token or TLSPC key can also provided.
If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases: Key, AccessToken

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Platform
Platform, either TLSPDC or Vaas, to validate VenafiSession against.

```yaml
Type: String
Parameter Sets: Platform
Aliases:

Required: True
Position: Named
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

### String - if PassThru provided
## NOTES

## RELATED LINKS
