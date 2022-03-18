<#
.SYNOPSIS
Add members to a team

.DESCRIPTION
Add members to either a VaaS or TPP team

.PARAMETER ID
Team ID.
For VaaS, this is the unique guid obtained from Get-VenafiTeam.
For TPP, this is the ID property from Find-TppIdentity.

.PARAMETER Member
1 or more members to add to the team.
For VaaS, this is the unique guid obtained from Get-VenafiIdentity.
For TPP, this is the ID property from Find-TppIdentity.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
ID

.EXAMPLE
Add-VenafiTeamMember -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Member @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4')
Add members to a VaaS team

.LINK
https://api.venafi.cloud/webjars/swagger-ui/index.html?configUrl=%2Fv3%2Fapi-docs%2Fswagger-config&urls.primaryName=outagedetection-service#/Teams/addMember

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-PUT-Teams-AddTeamMembers.php
#>
function Add-VenafiTeamMember {

    [CmdletBinding()]
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

            $params.Method = 'Post'
            $params.UriLeaf = "teams/$TeamId/members"
            $params.Body = @{
                'members' = @($Member)
            }
        }
        else {
            $teamName = Get-VenafiIdentity -ID $ID -VenafiSession $VenafiSession | Select-Object -ExpandProperty FullName
            $members = foreach ($thisMember in $Member) {
                if ( $thisMember.StartsWith('local') ) {
                    $memberIdentity = Get-VenafiIdentity -ID $thisMember -VenafiSession $VenafiSession
                    @{
                        'PrefixedName'      = $memberIdentity.FullName
                        'PrefixedUniversal' = $memberIdentity.ID
                    }
                }
                else {
                    @{'PrefixedUniversal' = $thisMember }
                }
            }
            $params.Method = 'Put'
            $params.UriLeaf = 'Teams/AddTeamMembers'
            $params.Body = @{
                'Team'        = @{'PrefixedName' = $teamName }
                'Members'     = @($members)
            }
        }

        Invoke-VenafiRestMethod @params | Out-Null
    }
}
