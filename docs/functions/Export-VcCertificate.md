# Export-VcCertificate

## SYNOPSIS
Export certificate data from TLSPC

## SYNTAX

```
Export-VcCertificate [-ID] <String> [[-PrivateKeyPassword] <PSObject>] [-IncludeChain] [[-OutPath] <String>]
 [[-ThrottleLimit] <Int32>] [[-VenafiSession] <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Export certificate data in PEM format. 
You can retrieve the certificate, chain, and key.

## EXAMPLES

### EXAMPLE 1
```
$certId | Export-VcCertificate
```

Export certificate data

### EXAMPLE 2
```
$certId | Export-VcCertificate -PrivateKeyPassword 'myPassw0rd!'
```

Export certificate and private key data

### EXAMPLE 3
```
$cert | Export-VcCertificate -OutPath '~/temp'
```

Get certificate data and save to a file

### EXAMPLE 4
```
$cert | Export-VcCertificate -IncludeChain
```

Get certificate data with the certificate chain included.

## PARAMETERS

### -ID
Certificate ID, also known as uuid. 
Use Find-VcCertificate or Get-VcCertificate to determine the ID.
You can pipe those functions as well.

```yaml
Type: String
Parameter Sets: (All)
Aliases: certificateId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -PrivateKeyPassword
Password required to include the private key.
You can either provide a String, SecureString, or PSCredential.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeChain
Include the certificate chain with the exported certificate.

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

### -OutPath
Folder path to save the certificate to. 
The name of the file will be determined automatically.
For each certificate a directory will be created in this folder with the format Name-ID.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ThrottleLimit
Limit the number of threads when running in parallel; the default is 100. 
Applicable to PS v7+ only.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TLSPC key can also provided.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### ID
## OUTPUTS

### PSCustomObject
## NOTES

## RELATED LINKS
