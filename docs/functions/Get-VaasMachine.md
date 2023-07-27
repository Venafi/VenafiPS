# Get-VaasMachine

## SYNOPSIS
Get machine info

## SYNTAX

### ID (Default)
```
Get-VaasMachine -ID <String> [-VenafiSession <PSObject>] [<CommonParameters>]
```

### All
```
Get-VaasMachine [-All] [-IncludeConnectionDetail] [-VenafiSession <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Get info for either a specific machine or all.

## EXAMPLES

### EXAMPLE 1
```
Get-VaasMachine -ID 'c1'
```

companyId         : 0bc771e1-7abe-4339-9fcd-93fffe9cba7f
name              : c1
machineType       : Citrix ADC
pluginId          : ff645e14-bd1a-11ed-a009-ce063932f86d
integrationId     : d68a571d-24df-11ee-a0ae-f24d11bc4208
edgeInstanceId    : 79fe96d0-0b93-11ee-8894-cb74b07067e5
creationDate      : 7/17/2023 4:23:49 PM
modificationDate  : 7/17/2023 4:32:48 PM
status            : VERIFIED
owningTeamId      : 59920180-a3e2-11ec-8dcd-3fcbf84c7da7
connectionDetails : @{credentialType=local; hostnameOrAddress=1.2.3.4; password=RpSYhMjqxRr1QPROGqH4bKa1b3AQoik=;
                    username=7sEvTe9CAEmXB/tKwF3NLCMFFWCv3+}
machineId         : d68c7420-24df-11ee-9c2f-49251618e0a7

Get info for a specific machine by name

### EXAMPLE 2
```
Get-VaasMachine -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
```

Get info for a specific machine by ID

### EXAMPLE 3
```
Get-VaasMachine -All
```

companyId        : 0bc771e1-7abe-4339-9fcd-93fffe9cba7f
name             : c1
machineType      : Citrix ADC
pluginId         : ff645e14-bd1a-11ed-a009-ce063932f86d
integrationId    : d68a571d-24df-11ee-a0ae-f24d11bc4208
edgeInstanceId   : 79fe96d0-0b93-11ee-8894-cb74b07067e5
creationDate     : 7/17/2023 4:23:49 PM
modificationDate : 7/17/2023 4:32:48 PM
status           : VERIFIED
owningTeamId     : 59920180-a3e2-11ec-8dcd-3fcbf84c7da7
machineId        : d68c7420-24df-11ee-9c2f-49251618e0a7

Get info for all machines

### EXAMPLE 4
```
Get-VaasMachine -All -IncludeConnectionDetail
```

companyId         : 0bc771e1-7abe-4339-9fcd-93fffe9cba7f
name              : c1
machineType       : Citrix ADC
pluginId          : ff645e14-bd1a-11ed-a009-ce063932f86d
integrationId     : d68a571d-24df-11ee-a0ae-f24d11bc4208
edgeInstanceId    : 79fe96d0-0b93-11ee-8894-cb74b07067e5
creationDate      : 7/17/2023 4:23:49 PM
modificationDate  : 7/17/2023 4:32:48 PM
status            : VERIFIED
owningTeamId      : 59920180-a3e2-11ec-8dcd-3fcbf84c7da7
connectionDetails : @{credentialType=local; hostnameOrAddress=1.2.3.4; password=RpSYhMjqxRr1QPROGqH4bKa1b3AQoik=;
                    username=7sEvTe9CAEmXB/tKwF3NLCMFFWCv3+}
machineId         : d68c7420-24df-11ee-9c2f-49251618e0a7

Get info for all machines including connection details

## PARAMETERS

### -ID
Name or uuid to get info for a specific machine

```yaml
Type: String
Parameter Sets: ID
Aliases: machineId

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -All
Get all machines

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

### -IncludeConnectionDetail
{{ Fill IncludeConnectionDetail Description }}

```yaml
Type: SwitchParameter
Parameter Sets: All
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
Aliases:

Required: False
Position: Named
Default value: $script:VenafiSession
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
