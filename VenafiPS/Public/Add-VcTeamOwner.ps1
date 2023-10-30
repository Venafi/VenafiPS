function Add-VcTeamOwner {
    <#
    .SYNOPSIS
    Add owners to a team

    .DESCRIPTION
    Add owners to a TLSPC team

    .PARAMETER ID
    Team ID.
    This is the unique guid obtained from Get-VcTeam.

    .PARAMETER Owner
    1 or more owners to add to the team
    This is the unique guid obtained from Get-VcIdentity.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    ID

    .EXAMPLE
    Add-VcTeamOwner -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Owner @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4')

    Add owners

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html#/Teams/addOwner
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
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'
    }

    process {

        $params.Method = 'Post'
        $params.UriLeaf = "teams/$ID/owners"
        $params.Body = @{
            'owners' = @($Owner)
        }

        $null = Invoke-VenafiRestMethod @params
    }
}
