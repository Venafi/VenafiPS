function Get-VcCertificate {
    <#
    .SYNOPSIS
    Get certificate information

    .DESCRIPTION
    Get certificate information, either all available to the api key provided or by id or zone.

    .PARAMETER ID
    Certificate identifier.
    For Venafi as a Service, this is the ID or certificate name.

    .PARAMETER All
    Retrieve all certificates

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    CertificateId

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-VdcCertificate -CertificateId 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'

    Get certificate info for a specific cert on Venafi as a Serivce

    .EXAMPLE
    Get-VdcCertificate -CertificateId '\ved\policy\mycert.com'

    Get certificate info for a specific cert on TPP

    .EXAMPLE
    Get-VdcCertificate -All

    Get certificate info for all certs

    .EXAMPLE
    Get-VdcCertificate -CertificateId '\ved\policy\mycert.com' -IncludeTppPreviousVersions

    Get certificate info for a specific cert on TPP, including historical versions of the certificate.

    .EXAMPLE
    Get-VdcCertificate -CertificateId '\ved\policy\mycert.com' -IncludeTppPreviousVersions -ExcludeRevoked -ExcludeExpired

    Get certificate info for a specific cert on TPP, including historical versions of the certificate that are not revoked or expired.

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates-guid.php
    #>

    [CmdletBinding(DefaultParameterSetName = 'Id')]

    param (

        [Parameter(ParameterSetName = 'Id', Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('CertificateID')]
        [string] $ID,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [Switch] $All,

        [Parameter()]
        [switch] $IncludeVaasOwner,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

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
                $_.applicationIds | Get-VcApplication -VenafiSession $VenafiSession | Select-Object -Property * -ExcludeProperty ownerIdsAndTypes, ownership
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
                            $thisOwnerDetail = Get-VenafiIdentity -ID $thisOwner -VenafiSession $VenafiSession | Select-Object firstName, lastName, emailAddress,
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
                            $thisOwnerDetail = Get-VenafiTeam -ID $thisOwner -VenafiSession $VenafiSession | Select-Object name, role, members,
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
