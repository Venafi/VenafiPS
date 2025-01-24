# Import-VcCertificate

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### ByFile (Default)
```
Import-VcCertificate -Path <String> [-PrivateKeyPassword <PSObject>] [-ThrottleLimit <Int32>] [-Force]
 [-VenafiSession <PSObject>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Format
```
Import-VcCertificate -Data <String> -Format <String> [-PrivateKeyPassword <PSObject>] [-ThrottleLimit <Int32>]
 [-Force] [-VenafiSession <PSObject>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### PKCS8
```
Import-VcCertificate -Data <String> [-PKCS8] -PrivateKeyPassword <PSObject> [-ThrottleLimit <Int32>] [-Force]
 [-VenafiSession <PSObject>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### PKCS12
```
Import-VcCertificate -Data <String> [-PKCS12] -PrivateKeyPassword <PSObject> [-ThrottleLimit <Int32>] [-Force]
 [-VenafiSession <PSObject>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Data
{{ Fill Data Description }}

```yaml
Type: String
Parameter Sets: Format, PKCS8, PKCS12
Aliases: certificateData

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Force
{{ Fill Force Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Format
{{ Fill Format Description }}

```yaml
Type: String
Parameter Sets: Format
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PKCS12
{{ Fill PKCS12 Description }}

```yaml
Type: SwitchParameter
Parameter Sets: PKCS12
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PKCS8
{{ Fill PKCS8 Description }}

```yaml
Type: SwitchParameter
Parameter Sets: PKCS8
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
{{ Fill Path Description }}

```yaml
Type: String
Parameter Sets: ByFile
Aliases: FullName, CertificatePath, FilePath

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrivateKeyPassword
{{ Fill PrivateKeyPassword Description }}

```yaml
Type: PSObject
Parameter Sets: ByFile
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: PSObject
Parameter Sets: Format
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: PSObject
Parameter Sets: PKCS8, PKCS12
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ThrottleLimit
{{ Fill ThrottleLimit Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VenafiSession
{{ Fill VenafiSession Description }}

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

### System.String
### System.Management.Automation.PSObject
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
