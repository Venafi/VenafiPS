# Set-VaasCertificateAssignment

## SYNOPSIS
Associate certificates with applications

## SYNTAX

```
Set-VaasCertificateAssignment [-CertificateID] <String> [-ApplicationID] <String[]> [-NoOverwrite] [-PassThru]
 [[-VenafiSession] <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Associate one or more certificates with one or more applications.
The associated applications can either replace or be added to existing.
By default, applications will be replaced.

## EXAMPLES

### EXAMPLE 1
```
Set-VaasCertificateAssignment -CertificateID '7ac56ec0-2017-11ee-9417-a17dd25b82f9' -ApplicationID '96fc9310-67ec-11eb-a8a7-794fe75a8e6f'
```

Associate a certificate to an application

### EXAMPLE 2
```
Set-VaasCertificateAssignment -CertificateID '7ac56ec0-2017-11ee-9417-a17dd25b82f9' -ApplicationID '96fc9310-67ec-11eb-a8a7-794fe75a8e6f', 'a05013bd-921d-440c-bc22-c9ead5c8d548'
```

Associate a certificate to multiple applications

### EXAMPLE 3
```
Find-VenafiCertificate -First 5 | Set-VaasCertificateAssignment -ApplicationID '96fc9310-67ec-11eb-a8a7-794fe75a8e6f'
```

Associate multiple certificates to 1 application

### EXAMPLE 4
```
Set-VaasCertificateAssignment -CertificateID '7ac56ec0-2017-11ee-9417-a17dd25b82f9' -ApplicationID '96fc9310-67ec-11eb-a8a7-794fe75a8e6f' -NoOverwrite
```

Associate a certificate to another application, keeping the existing

## PARAMETERS

### -CertificateID
Certificate ID to be associated

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ApplicationID
One or more application IDs

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoOverwrite
Append to existing applications as opposed to overwriting

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

### -PassThru
Return the newly updated certificate object(s)

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
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A VaaS key can also provided.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases: Key

Required: False
Position: 3
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### CertificateID
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS
