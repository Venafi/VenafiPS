function Add-VcTeamMember {
    <#
    .SYNOPSIS
    Add members to a team

    .DESCRIPTION
    Add members to a TLSPC team

    .PARAMETER ID
    Team ID to add to

    .PARAMETER Member
    1 or more members to add to the team.
    This is the unique guid obtained from Get-VcIdentity.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    ID

    .EXAMPLE
    Add-VcTeamMember -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Member @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4')

    Add members to a TLSPC team

    .EXAMPLE
    Add-VcTeamMember -ID 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Member 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}'

    Add members to a TLSPDC team

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html#/Teams/addMember
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
        Test-VenafiSession $PSCmdlet.MyInvocation
    }

    process {

        $params.Method = 'Post'
        $params.UriLeaf = "teams/$ID/members"
        $params.Body = @{
            'members' = @($Member)
        }

        $null = Invoke-VenafiRestMethod @params
    }
}
