function Get-VcTeam {
    <#
    .SYNOPSIS
    Get team info

    .DESCRIPTION
    Get info on teams including members and owners.
    Retrieve info on 1 or all.

    .PARAMETER ID
    Team name or guid.

    .PARAMETER All
    Get all teams

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    ID

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-VcTeam -ID 'MyTeam'

    Get info for a team by name

    .EXAMPLE
    Get-VcTeam -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'

    Get info for a team by id

    .EXAMPLE
    Get-VcTeam -All

    Get info for all teams

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Teams/get_2

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Teams/get_1
    #>

    [CmdletBinding()]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('teamID', 'owningTeam', 'owningTeams', 'owningTeamId', 'ownedTeams', 'ID')]
        [string[]] $Team,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch] $All,

        [Parameter()]
        [Alias('Key', 'AccessToken')]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'
    }

    process {

        if ( $PSCmdlet.ParameterSetName -eq 'All' ) {
            $uriLeaf = 'teams'
        }
        else {
            if ( $ID.Count -gt 1 ) {
                foreach ($teamId in $ID) {
                    Get-VcTeam -ID $teamId
                }
            }
            else {
                $thisID = $ID[0]
            }

            if ( Test-IsGuid -InputObject $thisID ) {
                $guid = [guid] $thisID
                $uriLeaf = 'teams/{0}' -f $guid.ToString()
            }
            else {
                # assume team name
                return Get-VcTeam -All | Where-Object { $_.name -eq $thisID }
            }
        }

        $response = Invoke-VenafiRestMethod -UriLeaf $uriLeaf

        if ( $response.PSObject.Properties.Name -contains 'teams' ) {
            $response | Select-Object -ExpandProperty teams | ConvertTo-VcTeam
        }
        else {
            $response | ConvertTo-VcTeam
        }
    }
}
