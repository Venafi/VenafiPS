# Invoke-VaasWorkflow

## SYNOPSIS
Start a machine or machine identity workflow

## SYNTAX

```
Invoke-VaasWorkflow [-ID] <String> [[-WorkflowName] <String>] [[-VenafiSession] <PSObject>]
 [<CommonParameters>]
```

## DESCRIPTION
Start a workflow to either test machine credentials or provision or discover machine identities

## EXAMPLES

### EXAMPLE 1
```
Invoke-VaasWorkflow -ID '1345baf1-fc56-49b7-aa03-78e35bfe0a1a' -WorkflowName 'Provision'
```

ID                                   WorkflowName Success
--                                   ------------ -------
89fa4370-2026-11ee-8a18-ff9579bb988e Test         True

Trigger provisioning

### EXAMPLE 2
```
Invoke-VaasWorkflow -ID '1345baf1-fc56-49b7-aa03-78e35bfe0a1a' -WorkflowName 'Provision'
```

ID                                   WorkflowName Success Error
--                                   ------------ ------- -----
1345baf1-fc56-49b7-aa03-78e35bfe0a1a Provision    False   Failed for some reason....

Trigger provisioning, but it failed

### EXAMPLE 3
```
Find-VaasObject -Type MachineIdentity -Filter @('and', @('certificateValidityEnd', 'lt', (get-date).AddDays(30)), @('certificateValidityEnd', 'gt', (get-date))) | ForEach-Object {
    $renewResult = $_ | Invoke-VenafiCertificateAction -Renew
    # optionally add renew validation
    $_ | Invoke-VaasWorkflow -WorkflowName 'Provision'
}
```

ID                                   WorkflowName Success
--                                   ------------ -------
89fa4370-2026-11ee-8a18-ff9579bb988e Provision    True
7598917c-7027-4927-be73-e592bcc4c567 Provision    True

Renew and provision all machine identities with certificates expiring within 30 days

## PARAMETERS

### -ID
Machine or machine identity id for the workflow to trigger.
Workflows 'Test' and 'GetConfig' require the machine ID.
Workflows 'Provision' and 'Discover' require the machine identity ID.

```yaml
Type: String
Parameter Sets: (All)
Aliases: machineID, machineIdentityID

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -WorkflowName
The name of the workflow to trigger.
Valid values are 'Test', 'GetConfig', 'Provision', or 'Discover'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Test
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
Position: 3
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### ID
## OUTPUTS

### pscustomobject
## NOTES

## RELATED LINKS
