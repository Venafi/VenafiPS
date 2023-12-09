﻿function Get-VdcCertificate {
    <#
    .SYNOPSIS
    Get certificate information

    .DESCRIPTION
    Get certificate information, either all available to the api key provided or by id or zone.

    .PARAMETER ID
    Certificate identifier by either path or guid.
    \ved\policy will be automatically applied if a full path isn't provided.

    .PARAMETER IncludePreviousVersions
    Returns details about previous (historical) versions of a certificate.
    This option will add a property named PreviousVersions to the returned object.

    .PARAMETER ExcludeExpired
    Omits expired versions of the previous (historical) versions of a certificate.
    Can only be used with the IncludePreviousVersions parameter.

    .PARAMETER ExcludeRevoked
    Omits revoked versions of the previous (historical) versions of a certificate.
    Can only be used with the IncludePreviousVersions parameter.

    .PARAMETER All
    Retrieve all certificates

    .PARAMETER ThrottleLimit
    Limit the number of threads when running in parallel; the default is 100.  Applicable to PS v7+ only.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

    .INPUTS
    CertificateId

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-VdcCertificate -CertificateId '\ved\policy\mycert.com'

    Get certificate info for a specific cert

    .EXAMPLE
    Get-VdcCertificate -All

    Get certificate info for all certs

    .EXAMPLE
    Get-VdcCertificate -CertificateId '\ved\policy\mycert.com' -IncludeTppPreviousVersions

    Get certificate info for a specific cert, including historical versions of the certificate.

    .EXAMPLE
    Get-VdcCertificate -CertificateId '\ved\policy\mycert.com' -IncludeTppPreviousVersions -ExcludeRevoked -ExcludeExpired

    Get certificate info for a specific cert, including historical versions of the certificate that are not revoked or expired.

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates-guid.php
    #>

    [CmdletBinding(DefaultParameterSetName = 'Id')]

    param (

        [Parameter(ParameterSetName = 'Id', Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Parameter(ParameterSetName = 'IdWithPrevious', Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('Guid', 'Path')]
        [string] $ID,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [Parameter(Mandatory, ParameterSetName = 'AllWithPrevious')]
        [Switch] $All,

        [Parameter(Mandatory, ParameterSetName = 'IdWithPrevious')]
        [Parameter(Mandatory, ParameterSetName = 'AllWithPrevious')]
        [switch] $IncludePreviousVersions,

        [Parameter(ParameterSetName = 'IdWithPrevious')]
        [Parameter(ParameterSetName = 'AllWithPrevious')]
        [switch] $ExcludeExpired,

        [Parameter(ParameterSetName = 'IdWithPrevious')]
        [Parameter(ParameterSetName = 'AllWithPrevious')]
        [switch] $ExcludeRevoked,

        [Parameter()]
        [int32] $ThrottleLimit = 100,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VDC'

        $certs = [System.Collections.Generic.List[string]]::new()

    }

    process {

        if ( $All ) {
            return (Find-VdcCertificate -Path '\ved' -Recursive | Get-VdcCertificate -IncludePreviousVersions:$IncludePreviousVersions -ExcludeExpired:$ExcludeExpired -ExcludeRevoked:$ExcludeRevoked)
        }

        if ( Test-IsGuid($ID) ) {
            $certs.Add($ID)
        }
        else {
            $certs.Add((ConvertTo-VdcFullPath -Path $ID))
        }
    }

    end {

        Invoke-VenafiParallel -InputObject $certs -ScriptBlock {

            if ( $PSItem -like '\ved*' ) {
                # a path was provided, get the guid
                $thisGuid = ConvertTo-VdcGuid -Path $PSItem
            } else {
                $thisGuid = ([guid] $PSItem).ToString()
            }

            $params = @{
                UriLeaf = [System.Web.HttpUtility]::UrlEncode("certificates/{$thisGuid}")
            }

            $response = Invoke-VenafiRestMethod @params

            if ( $IncludePreviousVersions ) {
                $params.UriLeaf = [System.Web.HttpUtility]::UrlEncode("certificates/{$thisGuid}/PreviousVersions")
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

        } -ThrottleLimit $ThrottleLimit -ProgressTitle 'Getting certificates'
    }
}
