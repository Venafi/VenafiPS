<#
.SYNOPSIS
Remove VaaS Team info

.DESCRIPTION
Remove a team, members, or owners

.PARAMETER Id
Team ID

.PARAMETER Member
1 or more members to remove from the team

.PARAMETER Owner
1 or more owners to remove from the team

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Id

.OUTPUTS
PSCustomObject if PassThru provided

.EXAMPLE
Remove-VaasTeam -Id 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Remove a team

.EXAMPLE
Remove-VaasTeam -Id 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Member @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4')
Remove members from a team

.EXAMPLE
Remove-VaasTeam -Id 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Owner 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f3'
Remove an owner from the team

#>
function Remove-VaasTeam {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'Team')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'Team', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Details', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [guid] $Id,

        [Parameter(ParameterSetName = 'Details')]
        [guid[]] $Member,

        [Parameter(ParameterSetName = 'Details')]
        [guid[]] $Owner,

        [Parameter(ParameterSetName = 'Details')]
        [switch] $PassThru,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('VaaS')

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Delete'
            UriLeaf       = ''
        }
    }

    process {

        if ( $PSCmdlet.ParameterSetName -eq 'Team' ) {
            $params.UriLeaf = "teams/$Id"
            if ( $PSCmdlet.ShouldProcess($Id, "Delete team") ) {
                $response = Invoke-VenafiRestMethod @params
            }
        }
        else {
            if ( $Member ) {
                $params.UriLeaf = "teams/$Id/members"
                $params.Body = @{
                    'members' = @($Member)
                }
                if ( $PSCmdlet.ShouldProcess($Id, "Delete team members") ) {
                    $response = Invoke-VenafiRestMethod @params
                }
            }

            if ( $Owner ) {
                $params.UriLeaf = "teams/$Id/owners"
                $params.Body = @{
                    'owners' = @($Owner)
                }
                if ( $PSCmdlet.ShouldProcess($Id, "Delete team owners") ) {
                    $response = Invoke-VenafiRestMethod @params
                }
            }

            if ( $PassThru ) {
                # all calls return a team object so just get the last one executed
                $response
            }
        }
    }
}
