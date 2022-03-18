<#
.SYNOPSIS
Remove team owner

.DESCRIPTION
Remove a team owner from VaaS or TPP

.PARAMETER ID
Team ID

.PARAMETER Owner
1 or more owners to remove from the team

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
ID

.EXAMPLE
Remove-VenafiTeamOwner -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Owner @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4')
Remove ownrs from a team

.EXAMPLE
Remove-VenafiTeamOwner -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Owner 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f3' -Confirm:$false
Remove an owner from a team with no confirmation prompting

#>
function Remove-VenafiTeamOwner {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]

    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $ID,

        [Parameter(Mandatory)]
        [string[]] $Owner,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate()

        $params = @{
            VenafiSession = $VenafiSession
        }
    }

    process {

        if ( $VenafiSession.Platform -eq 'VaaS' ) {

            $params.Method = 'Delete'
            $params.UriLeaf = "teams/$ID/owners"
            $params.Body = @{
                'owners' = @($Owner)
            }
        }
        else {
            $teamName = Get-VenafiIdentity -ID $ID -VenafiSession $VenafiSession | Select-Object -ExpandProperty FullName
            $owners = foreach ($thisOwner in $Owner) {
                if ( $thisOwner.StartsWith('local') ) {
                    $ownerIdentity = Get-VenafiIdentity -ID $thisOwner -VenafiSession $VenafiSession
                    @{
                        'PrefixedName'      = $ownerIdentity.FullName
                        'PrefixedUniversal' = $ownerIdentity.ID
                    }
                }
                else {
                    @{'PrefixedUniversal' = $thisOwner }
                }
            }
            $params.Method = 'Put'
            $params.UriLeaf = 'Teams/DemoteTeamOwners'
            $params.Body = @{
                'Team'   = @{'PrefixedName' = $teamName }
                'Owners' = @($owners)
            }
        }

        if ( $PSCmdlet.ShouldProcess($ID, "Delete team owners") ) {
            Invoke-VenafiRestMethod @params | Out-Null
        }
    }
}
