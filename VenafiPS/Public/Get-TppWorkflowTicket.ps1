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
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

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
Get-TppWorkflowTicket -Path '\VED\policy\myapp.company.com'
Get ticket details for 1 certificate

.EXAMPLE
$certs | Get-TppWorkflowTicket
Get ticket details for multiple certificates

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppWorkflowTicket/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppWorkflowTicket.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Workflow-ticket-enumerate.php?tocpath=Web%20SDK%7CWorkflow%20Ticket%20programming%20interface%7C_____7

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Workflow-ticket-details.php?tocpath=Web%20SDK%7CWorkflow%20Ticket%20programming%20interface%7C_____6

#>
function Get-TppWorkflowTicket {

    [CmdletBinding()]
    param (

        [Parameter(Mandatory, ParameterSetName = 'ByObject', ValueFromPipeline)]
        [TppObject] $InputObject,

        [Parameter(Mandatory, ParameterSetName = 'ByPath', ValueFromPipeline)]
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

        [Parameter(Mandatory, ParameterSetName = 'ByGuid', ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Guid[]] $Guid,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate() | Out-Null
        Write-Verbose ("Parameter set {0}" -f $PsCmdlet.ParameterSetName)
    }

    process {

        if ( $PSBoundParameters.ContainsKey('InputObject') ) {
            $Path = $InputObject.Path
        }
        elseif ( $PSBoundParameters.ContainsKey('Guid') ) {
            $Path = $Guid | ConvertTo-TppPath -VenafiSession $VenafiSession
        }
        else {
            # we have the cert path we need to get the workflow tickets
        }

        $ticketGuid = foreach ($thisDn in $Path) {

            $params = @{
                VenafiSession = $VenafiSession
                Method     = 'Post'
                UriLeaf    = 'Workflow/Ticket/Enumerate'
                Body       = @{
                    'ObjectDN' = $thisDn
                }
            }

            $response = Invoke-TppRestMethod @params

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

            $response = Invoke-TppRestMethod @params

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