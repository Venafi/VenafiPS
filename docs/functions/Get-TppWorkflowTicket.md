# Get-TppWorkflowTicket

## SYNOPSIS
Get workflow ticket

## SYNTAX

### ByObject
```
Get-TppWorkflowTicket -InputObject <TppObject> [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### ByPath
```
Get-TppWorkflowTicket -Path <String[]> [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

### ByGuid
```
Get-TppWorkflowTicket -Guid <Guid[]> [-VenafiSession <VenafiSession>] [<CommonParameters>]
```

## DESCRIPTION
Get details about workflow tickets associated with a certificate.

## EXAMPLES

### EXAMPLE 1
```
Get-TppWorkflowTicket -Path '\VED\policy\myapp.company.com'
Get ticket details for 1 certificate
```

### EXAMPLE 2
```
$certs | Get-TppWorkflowTicket
Get ticket details for multiple certificates
```

## PARAMETERS

### -InputObject
TppObject which represents a certificate object

```yaml
Type: TppObject
Parameter Sets: ByObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
Path to the certificate

```yaml
Type: String[]
Parameter Sets: ByPath
Aliases: DN, CertificateDN

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Guid
Certificate guid

```yaml
Type: Guid[]
Parameter Sets: ByGuid
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
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
Position: Named
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### InputObject, Path, or Guid
## OUTPUTS

### PSCustomObject with the following properties:
###     Guid: Workflow ticket Guid
###     ApprovalExplanation: The explanation supplied by the approver.
###     ApprovalFrom: The identity to be contacted for approving.
###     ApprovalReason: The administrator-defined reason text.
###     Approvers: An array of workflow approvers for the certificate.
###     Blocking: The object that the ticket is associated with.
###     Created: The date/time the ticket was created.
###     IssuedDueTo: The workflow object that caused this ticket to be created (if any).
###     Result: Integer result code indicating success 1 or failure. For more information, see Workflow result codes.
###     Status: The status of the ticket.
###     Updated: The date/time that the ticket was last updated.
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppWorkflowTicket/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppWorkflowTicket/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppWorkflowTicket.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppWorkflowTicket.ps1)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Workflow-ticket-enumerate.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Workflow-ticket-enumerate.php)

[https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Workflow-ticket-details.php](https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Workflow-ticket-details.php)

