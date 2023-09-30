function Add-VdcTeamOwner {
    <#
    .SYNOPSIS
    Add owners to a team

    .DESCRIPTION
    Add owners to a TPP/TLSPC team

    .PARAMETER ID
    Team ID, this is the ID property from Find-VdcIdentity or Get-VenafiTeam.

    .PARAMETER Owner
    1 or more owners to add to the team
    This is the identity ID property from Find-VdcIdentity or Get-VenafiIdentity.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    ID

    .EXAMPLE
    Add-VdcTeamOwner -ID 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Owner 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}'

    Add owners

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-PUT-Teams-AddTeamOwners.php
    #>

    [CmdletBinding()]
    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('PrefixedUniversal', 'Guid')]
        [string] $ID,

        [Parameter(Mandatory)]
        [string[]] $Owner,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'
    }

    process {

        $teamName = Get-VenafiIdentity -ID $ID | Select-Object -ExpandProperty FullName
        $owners = foreach ($thisOwner in $Owner) {
            if ( $thisOwner.StartsWith('local') ) {
                $ownerIdentity = Get-VenafiIdentity -ID $thisOwner
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
        $params.UriLeaf = 'Teams/AddTeamOwners'
        $params.Body = @{
            'Team'   = @{'PrefixedName' = $teamName }
            'Owners' = @($owners)
        }

        $null = Invoke-VenafiRestMethod @params
    }
}
