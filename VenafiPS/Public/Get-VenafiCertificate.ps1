function Get-VenafiCertificate {
    <#
    .SYNOPSIS
    Get certificate information

    .DESCRIPTION
    Get certificate information, either all available to the api key provided or by id or zone.

    .PARAMETER CertificateId
    Certificate identifier.
    For Venafi as a Service, this is the unique guid.
    For TPP, use the full path.  \ved\policy will be automatically applied if a full path isn't provided.

    .PARAMETER IncludeTppPreviousVersions
    Returns details about previous (historical) versions of a certificate (only from TPP).
    This option will add a property named PreviousVersions to the returned object.

    .PARAMETER ExcludeExpired
    Omits expired versions of the previous (historical) versions of a certificate (only from TPP).
    Can only be used with the IncludePreviousVersions parameter.

    .PARAMETER ExcludeRevoked
    Omits revoked versions of the previous (historical) versions of a certificate (only from TPP).
    Can only be used with the IncludePreviousVersions parameter.

    .PARAMETER IncludeVaasOwner
    Retrieve detailed user/team owner info, only for VaaS.
    This will cause additional api calls to be made and take longer.

    .PARAMETER All
    Retrieve all certificates

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    CertificateId

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-VenafiCertificate -CertificateId 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'

    Get certificate info for a specific cert on Venafi as a Serivce

    .EXAMPLE
    Get-VenafiCertificate -CertificateId '\ved\policy\mycert.com'

    Get certificate info for a specific cert on TPP

    .EXAMPLE
    Get-VenafiCertificate -All

    Get certificate info for all certs in either TPP or VaaS

    .EXAMPLE
    Get-VenafiCertificate -CertificateId '\ved\policy\mycert.com' -IncludeTppPreviousVersions

    Get certificate info for a specific cert on TPP, including historical versions of the certificate.

    .EXAMPLE
    Get-VenafiCertificate -CertificateId '\ved\policy\mycert.com' -IncludeTppPreviousVersions -ExcludeRevoked -ExcludeExpired

    Get certificate info for a specific cert on TPP, including historical versions of the certificate that are not revoked or expired.

    .EXAMPLE
    Get-VenafiCertificate -CertificateId 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -IncludeVaasOwner

    In addition to certificate info, get user and team owner info as well

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates-guid.php
    #>

    [CmdletBinding(DefaultParameterSetName = 'All')]
    [Alias('Get-TppCertificateDetail')]

    param (

        [Parameter(ParameterSetName = 'Id', Mandatory, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'VaasId', Mandatory, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'TppOldVersions', Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Guid', 'Path')]
        [string] $CertificateId,

        [Parameter(Mandatory, ParameterSetName = 'TppAll')]
        [Parameter(Mandatory, ParameterSetName = 'VaasAll')]
        [Switch] $All,

        [Parameter(Mandatory, ParameterSetName = 'TppOldVersions')]
        [Parameter(ParameterSetName = 'TppAll')]
        [Alias('IncludePreviousVersions')]
        [switch] $IncludeTppPreviousVersions,

        [Parameter(ParameterSetName = 'TppOldVersions')]
        [switch] $ExcludeExpired,

        [Parameter(ParameterSetName = 'TppOldVersions')]
        [switch] $ExcludeRevoked,

        [Parameter(ParameterSetName = 'VaasId')]
        [Parameter(ParameterSetName = 'VaasAll')]
        [Switch] $IncludeVaasOwner,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        $platform = Test-VenafiSession -VenafiSession $VenafiSession -PassThru

        # paramset 'Id' is applicable to either platform
        if ( $PsCmdlet.ParameterSetName -ne 'Id' -and $PsCmdlet.ParameterSetName -notmatch "^$platform" ) {
            throw "The parameters selected are not applicable to $platform"
        }

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

        $appOwners = [System.Collections.Generic.List[object]]::new()

    }

    process {

        switch ($platform) {
            'VaaS' {
                $params.UriRoot = 'outagedetection/v1'
                $params.UriLeaf = "certificates"

                if ( $PSBoundParameters.ContainsKey('CertificateId') ) {
                    $params.UriLeaf += "/$CertificateId"
                }

                $params.UriLeaf += "?ownershipTree=true"

                $response = Invoke-VenafiRestMethod @params

                if ( $response.PSObject.Properties.Name -contains 'certificates' ) {
                    $certs = $response | Select-Object -ExpandProperty certificates
                } else {
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
                        $_.applicationIds | Get-VaasApplication -VenafiSession $VenafiSession | Select-Object -Property * -ExcludeProperty ownerIdsAndTypes, ownership
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
                        } else {
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

            Default {

                if ( $PSCmdlet.ParameterSetName -in 'Id', 'TppOldVersions' ) {

                    if ( [guid]::TryParse($CertificateId, $([ref][guid]::Empty)) ) {
                        $thisGuid = ([guid] $CertificateId).ToString()
                    } else {
                        # a path was provided
                        $thisGuid = $CertificateId | ConvertTo-TppGuid -VenafiSession $VenafiSession
                    }

                    $params.UriLeaf = [System.Web.HttpUtility]::HtmlEncode("certificates/{$thisGuid}")

                    $response = Invoke-VenafiRestMethod @params

                    if ( $IncludeTppPreviousVersions ) {
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
                    } catch {

                    }
                    $response | Select-Object @selectProps

                } else {
                    Find-TppCertificate -Path '\ved' -Recursive -VenafiSession $VenafiSession | Get-VenafiCertificate -IncludeTppPreviousVersions:$IncludeTppPreviousVersions -VenafiSession $VenafiSession
                }
            }
        }
    }
}
