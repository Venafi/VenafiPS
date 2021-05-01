<#
.SYNOPSIS
Get certificate information

.DESCRIPTION
Get certificate information, either all available to the api key provided or by id or zone.

.PARAMETER Id
Get certificate information for a specific id

.PARAMETER ZoneId
Get certificate information for all within a specific zone

.PARAMETER TppSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $TppSession.

.INPUTS
Id

.OUTPUTS
PSCustomObject

.EXAMPLE
Get-VaasCertificate
Get certificate info for all certs

.EXAMPLE
Get-VaasCertificate -Id 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Get certificate info for a specific cert

.EXAMPLE
Get-VaasCertificate -ZoneId 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Get certificate info for all certs within a specific zone

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-VaasCertificate/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Get-VaasCertificate.ps1

#>
function Get-VaasProject {

    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'Id', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [guid] $ProjectId,

        [Parameter()]
        [TppSession] $TppSession = $Script:TppSession
    )

    begin {
        $TppSession.Validate('vaas')

        $params = @{
            TppSession   = $TppSession
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

            $projects = $projects | Select-Object *,
            @{
                'n' = 'projectId'
                'e' = {
                    $_.id
                }
            } -ExcludeProperty id

            $projects | ForEach-Object { $_.PSObject.TypeNames.Insert(0, 'VenafiPS.Vaas.Project') }
            $projects

        }
    }
}
