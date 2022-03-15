<#
.SYNOPSIS
Update VaaS Team info

.DESCRIPTION
Add owners or members to a team

.PARAMETER Id
Team ID

.PARAMETER Member
1 or more members to add to the team

.PARAMETER Owner
1 or more owners to add to the team

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Id

.OUTPUTS
PSCustomObject if PassThru provided

.EXAMPLE
Set-VaasTeam -Id 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Member @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4')
Add members to a team

.EXAMPLE
Set-VaasTeam -Id 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Owner 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f3'
Add an owner to the team

#>
function Set-VaasTeam {

    [CmdletBinding()]
    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [guid] $Id,

        [Parameter()]
        [guid[]] $Member,

        [Parameter()]
        [guid[]] $Owner,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('VaaS')

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriLeaf       = ''
            Body          = @{}
        }
    }

    process {

        if ( $Member ) {
            $params.UriLeaf = "teams/$Id/members"
            $params.Body = @{
                'members' = @($Member)
            }
            $response = Invoke-VenafiRestMethod @params
        }

        if ( $Owner ) {
            $params.UriLeaf = "teams/$Id/owners"
            $params.Body = @{
                'owners' = @($Owner)
            }
            $response = Invoke-VenafiRestMethod @params
        }

        if ( $PassThru ) {
            # all calls return a team object so just get the last one executed
            $response
        }
    }
}
