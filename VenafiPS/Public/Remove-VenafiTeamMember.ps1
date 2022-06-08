<#
.SYNOPSIS
Remove team member

.DESCRIPTION
Remove a team member from VaaS or TPP

.PARAMETER ID
Team ID
For VaaS, this is the unique guid obtained from Get-VenafiTeam.
For TPP, this is the ID property from Find-TppIdentity or Get-VenafiTeam.

.PARAMETER Member
1 or more members to remove from the team
For VaaS, this is the unique guid obtained from Get-VenafiIdentity.
For TPP, this is the identity ID property from Find-TppIdentity or Get-VenafiIdentity.

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
ID

.EXAMPLE
Remove-VenafiTeamMember -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Member @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4')

Remove members from a team

.EXAMPLE
Remove-VenafiTeamMember -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Member 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f3' -Confirm:$false

Remove members from a team with no confirmation prompting

.EXAMPLE
Remove-VenafiTeamMember -ID 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Member 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}'

Remove members from a TPP team

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-PUT-Teams-RemoveTeamMembers.php

.LINK
https://api.venafi.cloud/webjars/swagger-ui/index.html#/Teams/removeMember
#>
function Remove-VenafiTeamMember {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]

    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('PrefixedUniversal', 'Guid')]
        [string] $ID,

        [Parameter(Mandatory)]
        [string[]] $Member,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        $platform = Test-VenafiSession -VenafiSession $VenafiSession -PassThru

        $params = @{
            VenafiSession = $VenafiSession
        }
    }

    process {

        if ( $platform -eq 'VaaS' ) {

            $params.Method = 'Delete'
            $params.UriLeaf = "teams/$ID/members"
            $params.Body = @{
                'members' = @($Member)
            }
        }
        else {
            $teamName = Get-VenafiIdentity -ID $ID -VenafiSession $VenafiSession | Select-Object -ExpandProperty FullName
            $members = foreach ($thisMember in $Member) {
                if ( $thisMember.StartsWith('local') ) {
                    $teamIdentity = Get-VenafiIdentity -ID $thisMember -VenafiSession $VenafiSession
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
