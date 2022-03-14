<#
.SYNOPSIS
Get Team info

.DESCRIPTION
Get info for either a specific team or all teams.  Venafi as a Service only, not for TPP.

.PARAMETER Id
Id to get info for a specific Team

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Id

.OUTPUTS
PSCustomObject

.EXAMPLE
Get-VaasTeam
Get info for all teams

.EXAMPLE
Get-VaasTeam -Id 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Get info for a specific team

#>
function Get-VaasTeam {

    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'Id', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [guid] $Id,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('VaaS')

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Get'
            UriLeaf       = 'teams'
            Body          = @{}
        }
    }

    process {

        if ( $Id ) {
            $params.UriLeaf += "/$Id"
        }

        $response = Invoke-VenafiRestMethod @params

        if ( $response.PSObject.Properties.Name -contains 'teams' ) {
            $response | Select-Object -ExpandProperty teams
        }
        else {
            $response
        }

    }
}
