﻿<#
.SYNOPSIS
Remove team owner

.DESCRIPTION
Remove a team owner from VaaS or TPP.

.PARAMETER ID
Team ID
For VaaS, this is the unique guid obtained from Get-VenafiTeam.
For TPP, this is the ID property from Find-TppIdentity or Get-VenafiTeam.

.PARAMETER Owner
1 or more owners to remove from the team
For VaaS, this is the unique guid obtained from Get-VenafiIdentity.
For TPP, this is the identity ID property from Find-TppIdentity or Get-VenafiIdentity.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
ID

.EXAMPLE
Remove-VenafiTeamOwner -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Owner @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4')

Remove owners from a team

.EXAMPLE
Remove-VenafiTeamOwner -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Owner 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f3' -Confirm:$false

Remove an owner from a team with no confirmation prompting

.EXAMPLE
Remove-VenafiTeamOwner -ID 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Owner 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}'

Remove owners from a TPP team

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

            # get team details and ensure at least 1 owner will remain
            $thisTeam = Get-VenafiTeam -ID $ID -VenafiSession $VenafiSession
            $ownerCompare = Compare-Object -ReferenceObject $thisTeam.owners -DifferenceObject $Owner
            if ( -not ($ownerCompare | Where-Object { $_.SideIndicator -eq '<=' }) ) {
                throw 'A team must have at least one owner and you are attempting to remove them all'
            }

            $params.Method = 'Delete'
            $params.UriLeaf = "teams/$ID/owners"
            $params.Body = @{
                'owners' = @($Owner)
            }

            if ( $PSCmdlet.ShouldProcess($ID, "Delete team owners") ) {
                Invoke-VenafiRestMethod @params | Out-Null
            }
        }
        else {

            # get team details and ensure at least 1 owner will remain
            $thisTeam = Get-VenafiTeam -ID $ID -VenafiSession $VenafiSession
            $ownerCompare = Compare-Object -ReferenceObject $thisTeam.owners.ID -DifferenceObject $Owner
            if ( -not ($ownerCompare | Where-Object { $_.SideIndicator -eq '<=' }) ) {
                throw 'A team must have at least one owner and you are attempting to remove them all'
            }

            # $teamName = Get-VenafiIdentity -ID $ID -VenafiSession $VenafiSession | Select-Object -ExpandProperty FullName
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
                'Team'   = @{'PrefixedName' = $thisTeam.FullName }
                'Owners' = @($owners)
            }

            if ( $PSCmdlet.ShouldProcess($ID, "Delete team owners") ) {
                Invoke-VenafiRestMethod @params | Out-Null

                # we've only demoted the owners to members.  now remove them
                Remove-VenafiTeamMember -ID $ID -Member $Owner -VenafiSession $VenafiSession
            }
        }
    }
}
