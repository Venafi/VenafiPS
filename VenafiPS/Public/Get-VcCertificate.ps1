﻿function Get-VcCertificate {
    <#
    .SYNOPSIS
    Get certificate information

    .DESCRIPTION
    Get certificate information, either all available to the api key provided or by id or zone.

    .PARAMETER CertificateId
    Certificate identifier.
    For Venafi as a Service, this is the ID or certificate name.
    For TPP, use the path or guid.  \ved\policy will be automatically applied if a full path isn't provided.

    .PARAMETER IncludeTppPreviousVersions
    Returns details about previous (historical) versions of a certificate (only from TPP).
    This option will add a property named PreviousVersions to the returned object.

    .PARAMETER ExcludeExpired
    Omits expired versions of the previous (historical) versions of a certificate (only from TPP).
    Can only be used with the IncludePreviousVersions parameter.

    .PARAMETER ExcludeRevoked
    Omits revoked versions of the previous (historical) versions of a certificate (only from TPP).
    Can only be used with the IncludePreviousVersions parameter.

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

        $certs = [System.Collections.Generic.List[string]]::new()
        $appOwners = [System.Collections.Generic.List[object]]::new()

    }

    process {

        if ( $All ) {
            return (Find-VcCertificate -IncludeVaasOwner:$IncludeVaasOwner)
        }

        $certs.Add($ID)
    }

    end {

        Invoke-VenafiParallel -InputObject $certs -ScriptBlock {

            if ( [guid]::TryParse($PSItem, $([ref][guid]::Empty)) ) {
                $thisGuid = ([guid] $PSItem).ToString()
            }
            else {
                # a path was provided
                $thisGuid = $PSItem | ConvertTo-VdcFullPath | ConvertTo-VdcGuid
            }

            $params = @{
                UriLeaf = [System.Web.HttpUtility]::HtmlEncode("certificates/{$thisGuid}")
            }

            $response = Invoke-VenafiRestMethod @params

            if ( $IncludePreviousVersions ) {
                $params.UriLeaf = [System.Web.HttpUtility]::HtmlEncode("certificates/{$thisGuid}/PreviousVersions")
                $params.Body = @{}

                if ( $ExcludeExpired.IsPresent ) {
                    $params.Body.ExcludeExpired = $ExcludeExpired
                }
                if ( $ExcludeRevoked.IsPresent ) {
                    $params.Body.ExcludeRevoked = $ExcludeRevoked
                }

                $previous = Invoke-VenafiRestMethod @params

                if ( $previous.PreviousVersions ) {
                    $previous.PreviousVersions.CertificateDetails | ForEach-Object {
                        $_.StoreAdded = [datetime]$_.StoreAdded
                        $_.ValidFrom = [datetime]$_.ValidFrom
                        $_.ValidTo = [datetime]$_.ValidTo
                    }
                }

                $response | Add-Member @{'PreviousVersions' = $previous.PreviousVersions }
            }

            # object transformations
            # put in try/catch in case datetime conversion fails
            try {
                $response.CertificateDetails.StoreAdded = [datetime]$response.CertificateDetails.StoreAdded
                $response.CertificateDetails.ValidFrom = [datetime]$response.CertificateDetails.ValidFrom
                $response.CertificateDetails.ValidTo = [datetime]$response.CertificateDetails.ValidTo
            }
            catch {

            }

            $selectProps = @{
                Property        =
                @{
                    n = 'Name'
                    e = { $_.Name }
                },
                @{
                    n = 'TypeName'
                    e = { $_.SchemaClass }
                },
                @{
                    n = 'Path'
                    e = { $_.DN }
                }, @{
                    n = 'Guid'
                    e = { [guid]$_.guid }
                }, @{
                    n = 'ParentPath'
                    e = { $_.ParentDN }
                }, @{
                    n = 'CreatedOn'
                    e = { [datetime]$_.CreatedOn }
                },
                '*'
                ExcludeProperty = 'DN', 'GUID', 'ParentDn', 'SchemaClass', 'Name', 'CreatedOn'
            }

            $response | Select-Object @selectProps

        }
    }
}