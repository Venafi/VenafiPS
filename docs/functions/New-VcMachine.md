# New-VcMachine

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### AdvancedMachine
```
New-VcMachine -Name <String> -MachineType <String> -VSatellite <String> -Owner <String> [-Tag <String[]>]
 [-Status <String>] -ConnectionDetail <Hashtable> -DekID <String> [-NoVerify] [-ThrottleLimit <Int32>]
 [-PassThru] [-Force] [-VenafiSession <PSObject>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### BasicMachine
```
New-VcMachine -Name <String> -MachineType <String> [-VSatellite <String>] -Owner <String> [-Tag <String[]>]
 [-Status <String>] [-Hostname <String>] -Credential <PSCredential> [-Port <String>] [-NoVerify]
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

### -ConnectionDetail
{{ Fill ConnectionDetail Description }}

```yaml
Type: Hashtable
Parameter Sets: AdvancedMachine
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Credential
{{ Fill Credential Description }}

```yaml
Type: PSCredential
Parameter Sets: BasicMachine
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DekID
{{ Fill DekID Description }}

```yaml
Type: String
Parameter Sets: AdvancedMachine
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
Parameter Sets: BasicMachine
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MachineType
{{ Fill MachineType Description }}

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

### -Name
{{ Fill Name Description }}

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
Type: String
Parameter Sets: BasicMachine
Aliases:

Required: False
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

### -VSatellite
{{ Fill VSatellite Description }}

```yaml
Type: String
Parameter Sets: AdvancedMachine
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: BasicMachine
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
### System.String[]
### System.Management.Automation.PSCredential
### System.Collections.Hashtable
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
