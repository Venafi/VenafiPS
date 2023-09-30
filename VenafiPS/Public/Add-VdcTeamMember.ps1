function Add-VdcTeamMember {
    <#
    .SYNOPSIS
    Add members to a team

    .DESCRIPTION
    Add members to a TPP/TLSPDC team

    .PARAMETER ID
    Team ID from Find-VdcIdentity or Get-VenafiTeam.

    .PARAMETER Member
    1 or more members to add to the team.
    The identity ID property from Find-VdcIdentity or Get-VenafiIdentity.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token can be provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    ID

    .EXAMPLE
    Add-VdcTeamMember -ID 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Member 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}'

    Add members to a TPP team

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-PUT-Teams-AddTeamMembers.php
    #>

    [CmdletBinding()]

    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('PrefixedUniversal', 'Guid')]
        [string] $ID,

        [Parameter(Mandatory)]
        [string[]] $Member,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'
    }

    process {

        $teamName = Get-VenafiIdentity -ID $ID | Select-Object -ExpandProperty FullName
        $members = foreach ($thisMember in $Member) {
            if ( $thisMember.StartsWith('local') ) {
                $memberIdentity = Get-VenafiIdentity -ID $thisMember
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
            'Team'    = @{'PrefixedName' = $teamName }
            'Members' = @($members)
        }

        Invoke-VenafiRestMethod @params | Out-Null
    }
}
