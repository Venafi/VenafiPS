# Set-TppWorkflowTicketStatus

## SYNOPSIS
Set workflow ticket status

## SYNTAX

```
Set-TppWorkflowTicketStatus [-TicketGuid] <Guid[]> [-Status] <String> [[-Explanation] <String>]
 [[-ScheduledStart] <DateTime>] [[-ScheduledStop] <DateTime>] [[-VenafiSession] <VenafiSession>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Set workflow ticket status for a certificate

## EXAMPLES

### EXAMPLE 1
```
Get-TppWorkflowTicket -Path '\VED\policy\myapp.company.com' | Set-TppWorkflowTicketStatus -Status Approved
```

Approve all tickets for a certificate

### EXAMPLE 2
```
Get-TppWorkflowTicket -Path '\VED\policy\myapp.company.com' | Set-TppWorkflowTicketStatus -Status 'Approved After' -ScheduledStart (Get-Date).AaaDays(3) -Explanation 'weekend upgrade'
```

Approve all tickets for a certificate after a certain date with an explanation

## PARAMETERS

### -TicketGuid
Guid representing a unique ticket

```yaml
Type: Guid[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Status
The new status to assign to the ticket.
Possible values include "Pending", "Approved", "Approved After", "Approved Between", and "Rejected".

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

### -Explanation
Explanation for the status change

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

### -ScheduledStart
Specifies the time after which the ticket should be processed.
ScheduledStart must be specified when the "Approved After" or "Approved Between" statuses are set

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScheduledStop
Specifies the time before which the ticket should be processed.
ScheduledStop must be specified when the "Approved Between" status is set

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VenafiSession
Session object created from New-VenafiSession method. 
The value defaults to the script session object $VenafiSession.

```yaml
Type: VenafiSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### TicketGuid
## OUTPUTS

### None
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppWorkflowTicketStatus/](http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppWorkflowTicketStatus/)

[https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Set-TppWorkflowTicketStatus.ps1](https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Set-TppWorkflowTicketStatus.ps1)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Workflow-ticket-updatestatus.php?tocpath=Web%20SDK%7CWorkflow%20Ticket%20programming%20interface%7C_____10](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Workflow-ticket-updatestatus.php?tocpath=Web%20SDK%7CWorkflow%20Ticket%20programming%20interface%7C_____10)

