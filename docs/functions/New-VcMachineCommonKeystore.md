# New-VcMachineCommonKeystore

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### SshPassword (Default)
```
New-VcMachineCommonKeystore -Name <String> [-VSatellite <String>] -Owner <String> [-Hostname <String>]
 -Credential <PSCredential> [-Tag <String[]>] [-Status <String>] [-SshPassword] [-Port <Int32>] [-NoVerify]
 [-ThrottleLimit <Int32>] [-PassThru] [-Force] [-VenafiSession <PSObject>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### SshKey
```
New-VcMachineCommonKeystore -Name <String> [-VSatellite <String>] -Owner <String> [-Hostname <String>]
 -Credential <PSCredential> [-Tag <String[]>] [-Status <String>] [-SshKey] [-Port <Int32>] [-NoVerify]
 [-ThrottleLimit <Int32>] [-PassThru] [-Force] [-VenafiSession <PSObject>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### WinrmBasic
```
New-VcMachineCommonKeystore -Name <String> [-VSatellite <String>] -Owner <String> [-Hostname <String>]
 -Credential <PSCredential> [-Tag <String[]>] [-Status <String>] [-WinrmBasic] [-Port <Int32>] [-UseTls]
 [-SkipCertificateCheck] [-NoVerify] [-ThrottleLimit <Int32>] [-PassThru] [-Force] [-VenafiSession <PSObject>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### WinrmKerberos
```
New-VcMachineCommonKeystore -Name <String> [-VSatellite <String>] -Owner <String> [-Hostname <String>]
 -Credential <PSCredential> [-Tag <String[]>] [-Status <String>] [-WinrmKerberos] [-Port <Int32>] [-UseTls]
 [-SkipCertificateCheck] -DomainName <String> -KeyDistributionCenter <String> -SPN <String> [-NoVerify]
 [-ThrottleLimit <Int32>] [-PassThru] [-Force] [-VenafiSession <PSObject>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
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

### -Credential
{{ Fill Credential Description }}

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DomainName
{{ Fill DomainName Description }}

```yaml
Type: String
Parameter Sets: WinrmKerberos
Aliases:

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

### -Hostname
{{ Fill Hostname Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -KeyDistributionCenter
{{ Fill KeyDistributionCenter Description }}

```yaml
Type: String
Parameter Sets: WinrmKerberos
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
{{ Fill Name Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -NoVerify
{{ Fill NoVerify Description }}

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

### -Owner
{{ Fill Owner Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PassThru
{{ Fill PassThru Description }}

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

### -Port
{{ Fill Port Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SPN
{{ Fill SPN Description }}

```yaml
Type: String
Parameter Sets: WinrmKerberos
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SkipCertificateCheck
{{ Fill SkipCertificateCheck Description }}

```yaml
Type: SwitchParameter
Parameter Sets: WinrmBasic, WinrmKerberos
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SshKey
{{ Fill SshKey Description }}

```yaml
Type: SwitchParameter
Parameter Sets: SshKey
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SshPassword
{{ Fill SshPassword Description }}

```yaml
Type: SwitchParameter
Parameter Sets: SshPassword
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Status
{{ Fill Status Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: DRAFT, VERIFIED, UNVERIFIED

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Tag
{{ Fill Tag Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### -UseTls
{{ Fill UseTls Description }}

```yaml
Type: SwitchParameter
Parameter Sets: WinrmBasic, WinrmKerberos
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -VSatellite
{{ Fill VSatellite Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### -WinrmBasic
{{ Fill WinrmBasic Description }}

```yaml
Type: SwitchParameter
Parameter Sets: WinrmBasic
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -WinrmKerberos
{{ Fill WinrmKerberos Description }}

```yaml
Type: SwitchParameter
Parameter Sets: WinrmKerberos
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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
### System.Management.Automation.PSCredential
### System.String[]
### System.Management.Automation.SwitchParameter
### System.Int32
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
