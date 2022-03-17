<#
.SYNOPSIS
Remove team member

.DESCRIPTION
Remove a team member from VaaS or TPP

.PARAMETER ID
Team ID

.PARAMETER Member
1 or more members to remove from the team

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
ID

.EXAMPLE
Remove-VenafiTeamMember -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Member @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4')
Remove members from a team

.EXAMPLE
Remove-VenafiTeamMember -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Member 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f3' -Confirm:$false
Remove members from a team with no confirmation prompting

#>
function Remove-VenafiTeamMember {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]

    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $ID,

        [Parameter(Mandatory)]
        [string[]] $Member,

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
            $params.UriLeaf = "teams/$ID/members"
            $params.Body = @{
                'members' = @($Member)
            }
        }
        else {
            $teamName = Get-VenafiIdentity -ID $ID | Select-Object -ExpandProperty FullName
            $members = foreach ($thisMember in $Member) {
                if ( $thisMember.StartsWith('local') ) {
                    $teamIdentity = Get-VenafiIdentity -ID $thisMember
                    @{
                        'PrefixedName'      = $teamIdentity.FullName
                        'PrefixedUniversal' = $teamIdentity.ID
                    }
                }
                else {
                    @{'PrefixedUniversal' = $thisMember }
                }
            }
            $params.Method = 'Put'
            $params.UriLeaf = 'Teams/RemoveTeamMembers'
            $params.Body = @{
                'Team'    = @{'PrefixedName' = $teamName }
                'Members' = @($members)
            }
        }

        if ( $PSCmdlet.ShouldProcess($ID, "Delete team members") ) {
            Invoke-VenafiRestMethod @params | Out-Null
        }
    }
}
