function Add-VdcTeamOwner {
    <#
    .SYNOPSIS
    Add owners to a team

    .DESCRIPTION
    Add owners to a TLSPDC team

    .PARAMETER ID
    Team ID, this is the ID property from Find-VdcIdentity or Get-VdcTeam.

    .PARAMETER Owner
    1 or more owners to add to the team
    This is the identity ID property from Find-VdcIdentity or Get-VdcIdentity.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

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
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VDC'
    }

    process {

        $teamName = Get-VdcIdentity -ID $ID | Select-Object -ExpandProperty FullName
        $owners = foreach ($thisOwner in $Owner) {
            if ( $thisOwner.StartsWith('local') ) {
                $ownerIdentity = Get-VdcIdentity -ID $thisOwner
                @{
                    'PrefixedName'      = $ownerIdentity.FullName
                    'PrefixedUniversal' = $ownerIdentity.ID
                }
            }
            else {
                @{'PrefixedUniversal' = $thisOwner }
            }
        }

        $params = @{
            Method  = 'Put'
            UriLeaf = 'Teams/AddTeamOwners'
            Body    = @{
                'Team'   = @{'PrefixedName' = $teamName }
                'Owners' = @($owners)
            }
        }

        $null = Invoke-VenafiRestMethod @params
    }
}
