# Set-VcApplication

## SYNOPSIS
Update an existing application

## SYNTAX

```
Set-VcApplication [-Application] <String> [[-Name] <String>] [[-TeamOwner] <String[]>] [-NoOverwrite]
 [-PassThru] [[-VenafiSession] <PSObject>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Update name or team owners of an existing applications.
Additional properties will be available in the future.

## EXAMPLES

### EXAMPLE 1
```
Set-VcApplication -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Name 'ThisAppNameIsBetter'
```

Rename an existing application

### EXAMPLE 2
```
Set-VcApplication -ID 'MyApp' -TeamOwner 'GreatTeam'
```

Change the owner to this team

### EXAMPLE 3
```
Set-VcApplication -ID 'MyApp' -TeamOwner 'GreatTeam' -NoOverwrite
```

Append this team to the list of owners

## PARAMETERS

### -Application
{{ Fill Application Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: applicationId, ID

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Provide a new name for the application if you wish to change it.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TeamOwner
Associate a team as an owner of this application

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoOverwrite
Append to existing details as opposed to overwriting

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
Return the newly updated object

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
A TLSPC key can also provided.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases: Key

Required: False
Position: 4
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

### PSCustomObject
## NOTES

## RELATED LINKS
