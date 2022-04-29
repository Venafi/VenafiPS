﻿<#
.SYNOPSIS
Get OrgUnit info

.DESCRIPTION
Get info for either a specific org unit or all org units.  Venafi as a Service only, not for TPP.

.PARAMETER OrgUnitId
Id to get info for a specific OrgUnit

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TppServer must also be set.

.INPUTS
OrgUnitId

.OUTPUTS
PSCustomObject

.EXAMPLE
Get-VaasOrgUnit
Get info for all org units

.EXAMPLE
Get-VaasOrgUnit -OrgUnitId 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Get info for a specific org unit

#>
function Get-VaasOrgUnit {

    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'Id', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [guid] $OrgUnitId,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        Write-Warning 'Get-VaasOrgUnit will be deprecated in a future release'

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Get'
            UriRoot       = 'outagedetection/v1'
            UriLeaf       = 'organizationalunits'
            Body          = @{
                ownerDetails        = $true
                applicationsDetails = $true
            }
        }
    }

    process {

        if ( $OrgUnitId ) {
            $params.UriLeaf += "/$OrgUnitId"
        }

        $response = Invoke-VenafiRestMethod @params

        if ( $response.PSObject.Properties.Name -contains 'organizationalUnits' ) {
            $orgUnits = $response | Select-Object -ExpandProperty organizationalUnits
        } else {
            $orgUnits = $response
        }

        if ( $orgUnits ) {

            # update all 'id' to their specific name, eg. zoneId, projectId

            $orgUnits | ForEach-Object {
                $thisOrgUnit = $_

                $thisOrgUnit.owningUsers = $thisOrgUnit.owningUsers | ForEach-Object {
                    $_ | Select-Object -Property *,
                    @{
                        'n' = 'owningUserId'
                        'e' = { $_.id }
                    } -ExcludeProperty id
                }

                $thisOrgUnit.applications = $thisOrgUnit.applications | ForEach-Object {
                    $_ | Select-Object -Property *,
                    @{
                        'n' = 'applicationId'
                        'e' = { $_.id }
                    } -ExcludeProperty id
                }
            }

            $orgUnits | Select-Object *,
            @{
                'n' = 'orgUnitId'
                'e' = {
                    $_.id
                }
            } -ExcludeProperty id

            # $orgUnits | ForEach-Object { $_.PSObject.TypeNames.Insert(0, 'VenafiPS.Vaas.Project') }
            # $orgUnits

        }
    }
}
