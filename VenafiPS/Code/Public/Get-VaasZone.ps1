<#
.SYNOPSIS
Get certificate information

.DESCRIPTION
Get certificate information, either all available to the api key provided or by id or zone.

.PARAMETER Id
Get certificate information for a specific id

.PARAMETER ZoneId
Get certificate information for all within a specific zone

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

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
function Get-VaasZone {

    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'Id', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [guid] $ZoneId,

        [Parameter(ParameterSetName = 'Id')]
        [switch] $DevOps,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('vaas')

        $params = @{
            VenafiSession   = $VenafiSession
            Method       = 'Get'
            CloudUriLeaf = 'projectzones'
        }
    }

    process {

        if ( $ZoneId ) {
            $params.CloudUriLeaf += "/$ZoneId"
            if ( $DevOps.IsPresent ) {
                $params.CloudUriLeaf += '/devopsintegrations'
            }
        }

        $response = Invoke-TppRestMethod @params

        if ( $response.PSObject.Properties.Name -contains 'zones' ) {
            $zones = $response | Select-Object -ExpandProperty zones
        } else {
            $zones = $response
        }

        if ( $zones ) {
            $zones | Select-Object *,
            @{
                'n' = 'zoneId'
                'e' = {
                    $_.Id
                }
            } -ExcludeProperty Id
        }
    }
}
