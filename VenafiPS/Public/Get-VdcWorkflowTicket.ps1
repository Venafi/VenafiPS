function Get-VdcWorkflowTicket {
    <#
    .SYNOPSIS
    Get workflow ticket

    .DESCRIPTION
    Get details about workflow tickets associated with a certificate.

    .PARAMETER InputObject
    TppObject which represents a certificate object

    .PARAMETER Path
    Path to the certificate

    .PARAMETER Guid
    Certificate guid

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    InputObject, Path, or Guid

    .OUTPUTS
    PSCustomObject with the following properties:
        Guid: Workflow ticket Guid
        ApprovalExplanation: The explanation supplied by the approver.
        ApprovalFrom: The identity to be contacted for approving.
        ApprovalReason: The administrator-defined reason text.
        Approvers: An array of workflow approvers for the certificate.
        Blocking: The object that the ticket is associated with.
        Created: The date/time the ticket was created.
        IssuedDueTo: The workflow object that caused this ticket to be created (if any).
        Result: Integer result code indicating success 1 or failure. For more information, see Workflow result codes.
        Status: The status of the ticket.
        Updated: The date/time that the ticket was last updated.

    .EXAMPLE
    Get-VdcWorkflowTicket -Path '\VED\policy\myapp.company.com'
    Get ticket details for 1 certificate

    .EXAMPLE
    $certs | Get-VdcWorkflowTicket
    Get ticket details for multiple certificates

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Get-VdcWorkflowTicket/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VdcWorkflowTicket.ps1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Workflow-ticket-enumerate.php

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Workflow-ticket-details.php

    #>

    [CmdletBinding()]
    [Alias('Get-TppWorkflowTicket')]

    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('DN', 'CertificateDN')]
        [String[]] $Path,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'
        Write-Verbose ("Parameter set {0}" -f $PsCmdlet.ParameterSetName)
    }

    process {

        $ticketGuid = foreach ($thisDn in $Path) {

            $params = @{
                VenafiSession = $VenafiSession
                Method     = 'Post'
                UriLeaf    = 'Workflow/Ticket/Enumerate'
                Body       = @{
                    'ObjectDN' = $thisDn
                }
            }

            $response = Invoke-VenafiRestMethod @params

            if ( $response ) {
                Write-Verbose ("Found {0} workflow tickets for certificate {1}" -f $response.GUIDs.count, $thisDn)
                $response.GUIDs
            }
        }

        foreach ($thisGuid in $ticketGuid) {
            $params = @{
                VenafiSession = $VenafiSession
                Method     = 'Post'
                UriLeaf    = 'Workflow/Ticket/Details'
                Body       = @{
                    'GUID' = $thisGuid
                }
            }

            $response = Invoke-VenafiRestMethod @params

            if ( $response.Result -eq [TppWorkflowResult]::Success ) {
                $response | Add-Member @{
                    TicketGuid = [guid] $thisGuid
                }
                $response
            }
            else {
                throw ("Error getting ticket details, error is {0}" -f [enum]::GetName([TppWorkflowResult], $response.Result))
            }
        }
    }
}