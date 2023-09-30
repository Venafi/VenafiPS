function Get-VenafiTeam {
    <#
    .SYNOPSIS
    Get Team info

    .DESCRIPTION
    Get info for a VaaS or TPP team including members and owners.
    For VaaS, you can retrieve info on all teams as well.

    .PARAMETER ID
    Team ID.
    For VaaS, this is the team name or guid.
    For TPP, this is the local prefixed universal ID.  You can find the group ID with Find-VdcIdentity.

    .PARAMETER All
    Provide this switch to get all teams

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    ID

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-VenafiTeam -ID 'MyTeam'

    Get info for a VaaS team by name

    .EXAMPLE
    Get-VenafiTeam -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'

    Get info for a VaaS team by id

    .EXAMPLE
    Get-VenafiTeam -ID 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}'

    Get info for a TPP team

    .EXAMPLE
    Find-VdcIdentity -Name MyTeamName | Get-VenafiTeam

    Search for a team and then get details

    .EXAMPLE
    Get-VenafiTeam -All

    Get info for all teams

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Teams/get_2

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Teams/get_1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Teams-prefix-universal.php
    #>

    [CmdletBinding()]
    [Alias('Get-TppTeam', 'Get-VaasTeam')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('PrefixedUniversal', 'Guid', 'PrefixedName')]
        [string] $ID,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch] $All,

        [Parameter()]
        [Alias('Key', 'AccessToken')]
        [psobject] $VenafiSession
    )

    begin {
        $platform = Test-VenafiSession -VenafiSession $VenafiSession -PassThru

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Get'
        }
    }

    process {

        if ( $platform -eq 'VaaS' ) {
            if ($PsCmdlet.ParameterSetName -eq 'All') {
                Get-VaasObject -TeamAll
            }
            else {
                Get-VaasObject -TeamID $ID
            }
        }
        else {
            if ( $PSCmdlet.ParameterSetName -eq 'All' ) {

                # no built-in api for this, get group objects and then get details
                Find-VdcObject -Path '\VED\Identity' -Class 'Group' -VenafiSession $VenafiSession | Where-Object { $_.Name -ne 'Everyone' } | Get-VenafiTeam -VenafiSession $VenafiSession
            }
            else {

                # not only does -match set $matches, but -notmatch does as well
                if ( $ID -notmatch '(?im)^(local:)?\{?([0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12})\}?$' ) {
                    Write-Error "'$ID' is not the proper format for a Team.  Format should either be a guid or local:{guid}."
                    return
                }

                $params.UriLeaf = ('Teams/local/{{{0}}}' -f $matches[2])

                try {

                    $response = Invoke-VenafiRestMethod @params

                    $out = [pscustomobject] ($response.ID | ConvertTo-VdcIdentity)
                    $out | Add-Member @{
                        Members = $response.Members | ConvertTo-VdcIdentity
                        Owners  = $response.Owners | ConvertTo-VdcIdentity
                    }
                    $out
                }
                catch {

                    # handle known errors where the local group is not actually a team
                    if ( $_.ErrorDetails.Message -like '*Failed to read the team identity;*' ) {
                        Write-Verbose "$ID looks to be a local group and not a Team.  The server responded with $_"
                    }
                    else {
                        Write-Error "$ID : $_"
                    }
                }
            }
        }
    }
}
