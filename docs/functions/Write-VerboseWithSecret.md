# Write-VerboseWithSecret

## SYNOPSIS
Remove sensitive information when writing verbose info

## SYNTAX

```
Write-VerboseWithSecret [-InputObject] <PSObject> [[-PropertyName] <String[]>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Remove sensitive information when writing verbose info

## EXAMPLES

### EXAMPLE 1
```
@{'password'='foobar'} | Write-VerboseWithSecret
Hide password value from hashtable
```

### EXAMPLE 2
```
$jsonString | Write-VerboseWithSecret
Hide value(s) from JSON string
```

## PARAMETERS

### -InputObject
JSON string or other object

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -PropertyName
{{ Fill PropertyName Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: @('AccessToken', 'Password', 'RefreshToken', 'access_token', 'refresh_token', 'Authorization', 'KeystorePassword', 'tppl-api-key', 'CertificateData', 'certificate')
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

### InputObject
## OUTPUTS

### None
## NOTES

## RELATED LINKS
