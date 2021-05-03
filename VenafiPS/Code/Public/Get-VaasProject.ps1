<#
.SYNOPSIS
Get project info

.DESCRIPTION
Get info for either a specific project or all projects.  Venafi as a Service only, not for TPP.

.PARAMETER ProjectId
Id to get info for a specific project

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
ProjectId

.OUTPUTS
PSCustomObject

.EXAMPLE
Get-VaasProject
Get info for all projects

.EXAMPLE
Get-VaasProject -Id 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Get info for a specific project

#>
function Get-VaasProject {

    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'Id', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [guid] $ProjectId,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('vaas') | Out-Null

        $params = @{
            VenafiSession   = $VenafiSession
            Method       = 'Get'
            CloudUriLeaf = 'devopsprojects'
            Body         = @{
                userDetails = $true
                zoneDetails = $true
            }
        }
    }

    process {

        if ( $ProjectId ) {
            $params.CloudUriLeaf += "/$ZoneId"
        }

        $response = Invoke-TppRestMethod @params

        if ( $response.PSObject.Properties.Name -contains 'devopsProjects' ) {
            $projects = $response | Select-Object -ExpandProperty devopsProjects
        } else {
            $projects = $response
        }

        if ( $projects ) {

            # update all 'id' to their specific name, eg. zoneId, projectId

            $projects | ForEach-Object {
                $thisProject = $_

                $thisProject.users = $thisProject.users | ForEach-Object {
                    $_ | Select-Object -Property *,
                    @{
                        'n' = 'userId'
                        'e' = { $_.id }
                    } -ExcludeProperty id
                }

                $thisProject.zones = $thisProject.zones | ForEach-Object {
                    $_ | Select-Object -Property *,
                    @{
                        'n' = 'zoneId'
                        'e' = { $_.id }
                    } -ExcludeProperty id
                }
            }

            $projects | Select-Object *,
            @{
                'n' = 'projectId'
                'e' = {
                    $_.id
                }
            } -ExcludeProperty id

            # $projects | ForEach-Object { $_.PSObject.TypeNames.Insert(0, 'VenafiPS.Vaas.Project') }
            # $projects

        }
    }
}
