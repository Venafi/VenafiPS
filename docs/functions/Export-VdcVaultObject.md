# Export-VdcVaultObject

## SYNOPSIS
Export an object from the vault

## SYNTAX

```
Export-VdcVaultObject [-ID] <Int32> [-OutPath] <String> [[-VenafiSession] <PSObject>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Export different object types from the vault.
The currently supported types are certificate, key, and PKCS12.
If the type is not supported, the base64 data will be returned as is.

## EXAMPLES

### EXAMPLE 1
```
Export-VdcVaultObject -ID 12345 -OutPath 'c:\temp'
```

Get vault object and save to a file

## PARAMETERS

### -ID
ID of the vault object to export

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: VaultId

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -OutPath
Folder path to save the certificate/key to. 
The name of the file will be determined automatically.

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
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TLSPDC token can also be provided.
If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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

### ID
## OUTPUTS

### PSCustomObject if unhandled type, otherwise saves the object to a file
## NOTES

## RELATED LINKS
