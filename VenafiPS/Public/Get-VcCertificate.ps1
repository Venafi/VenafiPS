function Get-VcCertificate {
    <#
    .SYNOPSIS
    Get certificate information

    .DESCRIPTION
    Get certificate information, either all available to the api key provided or by id or zone.

    .PARAMETER ID
    Certificate identifier, the ID or certificate name.

    .PARAMETER All
    Retrieve all certificates

    .PARAMETER IncludeVaasOwner
    Retrieve extended application owner info

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also be provided.

    .INPUTS
    CertificateId

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-VdcCertificate -CertificateId 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'

    Get certificate info for a specific cert

    .EXAMPLE
    Get-VdcCertificate -All

    Get certificate info for all certs
    #>

    [CmdletBinding(DefaultParameterSetName = 'Id')]

    param (

        [Parameter(ParameterSetName = 'Id', Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('certificateID')]
        [string] $ID,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [Switch] $All,

        [Parameter()]
        [switch] $IncludeVaasOwner,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'

        $appOwners = [System.Collections.Generic.List[object]]::new()

    }

    process {

        if ( $All ) {
            return (Find-VcCertificate -IncludeVaasOwner:$IncludeVaasOwner)
        }

        $params.UriRoot = 'outagedetection/v1'
        $params.UriLeaf = "certificates/"

        if ( Test-IsGuid($ID) ) {
            $params.UriLeaf += $ID
        }
        else {
            $findParams = @{
                Filter           = @('certificateName', 'eq', $ID)
                IncludeVaasOwner = $IncludeVaasOwner
            }
            return (Find-VcCertificate @findParams | Get-VcCertificate)
        }

        $params.UriLeaf += "?ownershipTree=true"

        $response = Invoke-VenafiRestMethod @params

        if ( $response.PSObject.Properties.Name -contains 'certificates' ) {
            $certs = $response | Select-Object -ExpandProperty certificates
        }
        else {
            $certs = $response
        }

        $certs | Select-Object @{
            'n' = 'certificateId'
            'e' = {
                $_.Id
            }
        },
        @{
            'n' = 'application'
            'e' = {
                $_.applicationIds | Get-VcApplication | Select-Object -Property * -ExcludeProperty ownerIdsAndTypes, ownership
            }
        },
        @{
            'n' = 'owner'
            'e' = {
                if ( $IncludeVaasOwner ) {

                    # this scriptblock requires ?ownershipTree=true be part of the url
                    foreach ( $thisOwner in $_.ownership.owningContainers.owningUsers ) {
                        $thisOwnerDetail = $appOwners | Where-Object { $_.id -eq $thisOwner }
                        if ( -not $thisOwnerDetail ) {
                            $thisOwnerDetail = Get-VcIdentity -ID $thisOwner | Select-Object firstName, lastName, emailAddress,
                            @{
                                'n' = 'status'
                                'e' = { $_.userStatus }
                            },
                            @{
                                'n' = 'role'
                                'e' = { $_.systemRoles }
                            },
                            @{
                                'n' = 'type'
                                'e' = { 'USER' }
                            },
                            @{
                                'n' = 'userId'
                                'e' = { $_.id }
                            }

                            $appOwners.Add($thisOwnerDetail)

                        }
                        $thisOwnerDetail
                    }

                    foreach ($thisOwner in $_.ownership.owningContainers.owningTeams) {
                        $thisOwnerDetail = $appOwners | Where-Object { $_.id -eq $thisOwner }
                        if ( -not $thisOwnerDetail ) {
                            $thisOwnerDetail = Get-VcTeam -ID $thisOwner | Select-Object name, role, members,
                            @{
                                'n' = 'type'
                                'e' = { 'TEAM' }
                            },
                            @{
                                'n' = 'teamId'
                                'e' = { $_.id }
                            }

                            $appOwners.Add($thisOwnerDetail)
                        }
                        $thisOwnerDetail
                    }
                }
                else {
                    $_.ownership.owningContainers | Select-Object owningUsers, owningTeams
                }
            }
        },
        @{
            'n' = 'instance'
            'e' = { $_.instances }
        },
        * -ExcludeProperty Id, applicationIds, instances, totalInstanceCount, ownership
    }
}
