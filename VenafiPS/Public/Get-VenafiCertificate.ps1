<#
.SYNOPSIS
Get certificate information

.DESCRIPTION
Get certificate information, either all available to the api key provided or by id or zone.

.PARAMETER CertificateId
Certificate identifier.  For Venafi as a Service, this is the unique guid.  For TPP, use the full path.

.PARAMETER IncludePreviousVersions
Returns details about previous (historical) versions of a certificate (only from TPP).

.PARAMETER ExcludeExpired
Omits expired versions of the previous (historical) versions of a certificate (only from TPP).
Can only be used with the IncludePreviousVersions parameter.

.PARAMETER ExcludeRevoked
Omits revoked versions of the previous (historical) versions of a certificate (only from TPP).
Can only be used with the IncludePreviousVersions parameter.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
CertificateId/Path from TppObject

.OUTPUTS
PSCustomObject

.EXAMPLE
Get-VenafiCertificate
Get certificate info for all certs

.EXAMPLE
Get-VenafiCertificate -CertificateId 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Get certificate info for a specific cert on Venafi as a Serivce

.EXAMPLE
Get-VenafiCertificate -CertificateId '\ved\policy\mycert.com'
Get certificate info for a specific cert on TPP

.EXAMPLE
Get-VenafiCertificate -CertificateId '\ved\policy\mycert.com' -IncludePreviousVersions
Get certificate info for a specific cert on TPP, including historical versions of the certificate.

.EXAMPLE
Get-VenafiCertificate -CertificateId '\ved\policy\mycert.com' -IncludePreviousVersions -ExcludeRevoked -ExcludeExpired
Get certificate info for a specific cert on TPP, including historical versions of the certificate that are not revoked or expired.

.EXAMPLE
Find-TppCertificate | Get-VenafiCertificate
Get certificate info for all certs in TPP

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates-guid.php
#>
function Get-VenafiCertificate {

    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (

        [Parameter(ParameterSetName = 'Id', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'OldVersions', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Path')]
        [string] $CertificateId,

        [Parameter(Mandatory, ParameterSetName = 'OldVersions')]
        [switch] $IncludePreviousVersions,

        [Parameter(ParameterSetName = 'OldVersions')]
        [switch] $ExcludeExpired,

        [Parameter(ParameterSetName = 'OldVersions')]
        [switch] $ExcludeRevoked,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {

        $authType = $VenafiSession.Validate()

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Get'
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

    }

    process {

        switch ($authType) {
            'vaas' {
                $params.UriRoot = 'outagedetection/v1'
                $params.UriLeaf = "certificates"

                if ( $PSCmdlet.ParameterSetName -eq 'Id' ) {
                    $params.UriLeaf += "/$CertificateId"
                }

                $response = Invoke-VenafiRestMethod @params

                if ( $response.PSObject.Properties.Name -contains 'certificates' ) {
                    $certs = $response | Select-Object -ExpandProperty certificates
                }
                else {
                    $certs = $response
                }

                $certs | Select-Object *,
                @{
                    'n' = 'certificateId'
                    'e' = {
                        $_.id
                    }
                } -ExcludeProperty id
            }

            Default {

                if ( $PSCmdlet.ParameterSetName -in 'Id', 'OldVersions' ) {
                    $thisGuid = $CertificateId | ConvertTo-TppGuid -VenafiSession $VenafiSession

                    $params.UriLeaf = [System.Web.HttpUtility]::HtmlEncode("certificates/{$thisGuid}")

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
                    $response.CertificateDetails.StoreAdded = [datetime]$response.CertificateDetails.StoreAdded
                    $response.CertificateDetails.ValidFrom = [datetime]$response.CertificateDetails.ValidFrom
                    $response.CertificateDetails.ValidTo = [datetime]$response.CertificateDetails.ValidTo
                    $response | Select-Object @selectProps

                }
                else {
                    Find-TppCertificate -Path '\ved' -Recursive -VenafiSession $VenafiSession
                }
            }
        }
    }
}
