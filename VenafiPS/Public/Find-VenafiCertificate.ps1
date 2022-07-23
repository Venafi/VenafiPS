function Find-VenafiCertificate {
    <#
    .SYNOPSIS
    Find certificates in TPP or VaaS based on various attributes

    .DESCRIPTION
    Find certificates based on various attributes.
    Supports standard PS paging parameters First, Skip, and IncludeTotalCount.
    If -First or -IncludeTotalCount not provided, the default return is 1000 records.

    .PARAMETER Path
    Starting path to search from.  If not provided, the default is \ved\policy.  TPP only.

    .PARAMETER Guid
    Guid which represents a starting path.  TPP only.

    .PARAMETER Recursive
    Search recursively starting from the search path.  TPP only.

    .PARAMETER Country
    Find certificates by Country attribute of Subject DN.  TPP only.

    .PARAMETER CommonName
    Find certificates by Common name attribute of Subject DN.  TPP only.

    .PARAMETER Issuer
    Find certificates by issuer. Use the CN, O, L, S, and C values from the certificate request.  TPP only.

    .PARAMETER KeyAlgorithm
    Find certificates by algorithm for the public key.  TPP only.

    .PARAMETER KeySize
    Find certificates by public key size.  TPP only.

    .PARAMETER KeySizeGreaterThan
    Find certificates with a key size greater than the specified value.  TPP only.

    .PARAMETER KeySizeLessThan
    Find certificates with a key size less than the specified value.  TPP only.

    .PARAMETER Locale
    Find certificates by Locality/City attribute of Subject Distinguished Name (DN).  TPP only.

    .PARAMETER Organization
    Find certificates by Organization attribute of Subject DN.  TPP only.

    .PARAMETER OrganizationUnit
    Find certificates by Organization Unit (OU).  TPP only.

    .PARAMETER State
    Find certificates by State/Province attribute of Subject DN.  TPP only.

    .PARAMETER SanDns
    Find certificates by Subject Alternate Name (SAN) Distinguished Name Server (DNS).  TPP only.

    .PARAMETER SanEmail
    Find certificates by SAN Email RFC822.  TPP only.

    .PARAMETER SanIP
    Find certificates by SAN IP Address.  TPP only.

    .PARAMETER SanUpn
    Find certificates by SAN User Principal Name (UPN) or OtherName.  TPP only.

    .PARAMETER SanUri
    Find certificates by SAN Uniform Resource Identifier (URI).  TPP only.

    .PARAMETER SerialNumber
    Find certificates by Serial number.  TPP only.

    .PARAMETER SignatureAlgorithm
    Find certificates by the algorithm used to sign the certificate (e.g. SHA1RSA).  TPP only.

    .PARAMETER Thumbprint
    Find certificates by one or more SHA-1 thumbprints.  TPP only.

    .PARAMETER IssueDate
    Find certificates by the date of issue.  TPP only.

    .PARAMETER ExpireDate
    Find certificates by expiration date.  TPP only.

    .PARAMETER ExpireAfter
    Find certificates that expire after a certain date.  TPP only.

    .PARAMETER ExpireBefore
    Find certificates that expire before a certain date.  TPP only.

    .PARAMETER Enabled
    Include only certificates that are enabled or disabled.  TPP only.

    .PARAMETER InError
    Only include certificates in an error state.  TPP only.

    .PARAMETER NetworkValidationEnabled
    Only include certificates with network validation enabled or disabled.  TPP only.

    .PARAMETER CreatedDate
    Find certificates that were created at an exact date and time.  TPP only.

    .PARAMETER CreatedAfter
    Find certificate created after this date and time.  TPP only.

    .PARAMETER CreatedBefore
    Find certificate created before this date and time.  TPP only.

    .PARAMETER CertificateType
    Find certificate by category of usage. Use CodeSigning, Device, Server, and/or User.  TPP only.

    .PARAMETER ManagementType
    Find certificates with a Management type of Unassigned, Monitoring, Enrollment, or Provisioning.  TPP only.

    .PARAMETER PendingWorkflow
    Only include certificates that have a pending workflow resolution (have an outstanding workflow ticket).  TPP only.

    .PARAMETER Stage
    Find certificates by one or more stages in the certificate lifecycle.  TPP only.

    .PARAMETER StageGreaterThan
    Find certificates with a stage greater than the specified stage (does not include specified stage).  TPP only.

    .PARAMETER StageLessThan
    Find certificates with a stage less than the specified stage (does not include specified stage).  TPP only.

    .PARAMETER ValidationEnabled
    Only include certificates with validation enabled or disabled.  TPP only.

    .PARAMETER ValidationState
    Find certificates with a validation state of Blank, Success, or Failure.  TPP only.

    .PARAMETER Filter
    VaaS.  Array or multidimensional array of fields and values to filter on.
    Each array should be of the format @(field, comparison operator, value).
    To combine filters use the format @('operator', @(field, comparison operator, value), @(field2, comparison operator2, value2)).
    Nested filters are supported.
    Field names and values are case sensitive.
    For a complete list of comparison operators, see https://docs.venafi.cloud/api/about-api-search-operators/.

    .PARAMETER Order
    VaaS.  Array of fields to order on.
    For each item in the array, you can provide a field name by itself; this will default to ascending.
    You can also provide a hashtable with the field name as the key and either asc or desc as the value.

    .PARAMETER CountOnly
    Return the count of certificates found from the query as opposed to the certificates themselves

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    Path

    .OUTPUTS
    TPP: TppObject, Int when CountOnly provided
    VaaS: PSCustomObject

    .EXAMPLE
    Find-VenafiCertificate

    Find first 1000 certificates

    .EXAMPLE
    Find-VenafiCertificate -ExpireBefore [datetime]'2018-01-01'

    Find certificates expiring before a certain date

    .EXAMPLE
    Find-VenafiCertificate -ExpireBefore "2018-01-01" -First 5

    Find 5 certificates expiring before a certain date

    .EXAMPLE
    Find-VenafiCertificate -ExpireBefore "2018-01-01" -First 5 -Skip 2

    Find 5 certificates expiring before a certain date, starting at the 3rd certificate found.
    Skip is only supported on TPP.

    .EXAMPLE
    Find-VenafiCertificate -Path '\VED\Policy\My Policy'

    Find certificates in a specific path

    .EXAMPLE
    Find-VenafiCertificate -Issuer 'CN=Example Root CA, O=Venafi,Inc., L=Salt Lake City, S=Utah, C=US'

    Find certificates by issuer

    .EXAMPLE
    Find-VenafiCertificate -Path '\VED\Policy\My Policy' -Recursive

    Find certificates in a specific path and all subfolders

    .EXAMPLE
    Find-VenafiCertificate | Get-VenafiCertificate

    Get detailed certificate info

    .EXAMPLE
    Find-VenafiCertificate -ExpireBefore "2019-09-01" -IncludeTotalCount | Invoke-VenafiCertificateAction -Renew

    Renew all certificates expiring before a certain date

    .EXAMPLE
    Find-VenafiCertificate -IncludeTotalCount

    Find all certificates, paging 1000 at a time

    .EXAMPLE
    Find-VenafiCertificate -First 500 -IncludeTotalCount

    Find all certificates, paging 500 at a time

    .EXAMPLE
    Find-VenafiCertificate -Filter @('fingerprint', 'EQ', '075C43428E70BCF941039F54B8ED78DE4FACA87F')

    Find VaaS certificates matching a single value

    .EXAMPLE
    Find-VenafiCertificate -Filter ('and', @('validityEnd','GTE',(get-date)), @('validityEnd','LTE',(get-date).AddDays(30)))

    Find VaaS certificates matching multiple values.  In this case, find all certificates expiring in the next 30 days.

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Find-VenafiCertificate/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-VenafiCertificate.ps1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates.php

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates-guid.php

    .LINK
    https://msdn.microsoft.com/en-us/library/system.web.httputility(v=vs.110).aspx

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Certificates/certificates_search_getByExpressionAsCsv

    #>

    [CmdletBinding(DefaultParameterSetName = 'NoParams', SupportsPaging)]
    [Alias('Find-TppCertificate', 'Find-VaasCertificate')]

    param (

        [Parameter(ParameterSetName = 'TPP', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                } else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('DN')]
        [String] $Path = '\ved\policy',

        [Parameter(ParameterSetName = 'TPP')]
        [ValidateNotNullOrEmpty()]
        [guid] $Guid,

        [Parameter(ParameterSetName = 'TPP')]
        [Switch] $Recursive,

        [Parameter(ParameterSetName = 'TPP')]
        [int] $Limit = 1000,

        [Parameter(ParameterSetName = 'TPP')]
        [int] $Offset,

        [Parameter(ParameterSetName = 'TPP')]
        [Alias('C')]
        [String] $Country,

        [Parameter(ParameterSetName = 'TPP')]
        [Alias('CN')]
        [String] $CommonName,

        [Parameter(ParameterSetName = 'TPP')]
        [String] $Issuer,

        [Parameter(ParameterSetName = 'TPP')]
        [String[]] $KeyAlgorithm,

        [Parameter(ParameterSetName = 'TPP')]
        [Int[]] $KeySize,

        [Parameter(ParameterSetName = 'TPP')]
        [Int] $KeySizeGreaterThan,

        [Parameter(ParameterSetName = 'TPP')]
        [Int] $KeySizeLessThan,

        [Parameter(ParameterSetName = 'TPP')]
        [Alias('L')]
        [String[]] $Locale,

        [Parameter(ParameterSetName = 'TPP')]
        [Alias('O')]
        [String[]] $Organization,

        [Parameter(ParameterSetName = 'TPP')]
        [Alias('OU')]
        [String[]] $OrganizationUnit,

        [Parameter(ParameterSetName = 'TPP')]
        [Alias('S')]
        [String[]] $State,

        [Parameter(ParameterSetName = 'TPP')]
        [String] $SanDns,

        [Parameter(ParameterSetName = 'TPP')]
        [String] $SanEmail,

        [Parameter(ParameterSetName = 'TPP')]
        [String] $SanIP,

        [Parameter(ParameterSetName = 'TPP')]
        [String] $SanUpn,

        [Parameter(ParameterSetName = 'TPP')]
        [String] $SanUri,

        [Parameter(ParameterSetName = 'TPP')]
        [String] $SerialNumber,

        [Parameter(ParameterSetName = 'TPP')]
        [String] $SignatureAlgorithm,

        [Parameter(ParameterSetName = 'TPP')]
        [String] $Thumbprint,

        [Parameter(ParameterSetName = 'TPP')]
        [Alias('ValidFrom')]
        [DateTime] $IssueDate,

        [Parameter(ParameterSetName = 'TPP')]
        [Alias('ValidTo')]
        [DateTime] $ExpireDate,

        [Parameter(ParameterSetName = 'TPP')]
        [Alias('ValidToGreater')]
        [DateTime] $ExpireAfter,

        [Parameter(ParameterSetName = 'TPP')]
        [Alias('ValidToLess')]
        [DateTime] $ExpireBefore,

        [Parameter(ParameterSetName = 'TPP')]
        [Switch] $Enabled,

        [Parameter(ParameterSetName = 'TPP')]
        [bool] $InError,

        [Parameter(ParameterSetName = 'TPP')]
        [bool] $NetworkValidationEnabled,

        [Parameter(ParameterSetName = 'TPP')]
        [Alias('CreatedOn')]
        [datetime] $CreatedDate,

        [Parameter(ParameterSetName = 'TPP')]
        [Alias('CreatedOnGreater')]
        [datetime] $CreatedAfter,

        [Parameter(ParameterSetName = 'TPP')]
        [Alias('CreatedOnLess')]
        [datetime] $CreatedBefore,

        [Parameter(ParameterSetName = 'TPP')]
        [ValidateSet('CodeSigning', 'Device', 'Server', 'User')]
        [String[]] $CertificateType,

        [Parameter(ParameterSetName = 'TPP')]
        [TppManagementType[]] $ManagementType,

        [Parameter(ParameterSetName = 'TPP')]
        [Switch] $PendingWorkflow,

        [Parameter(ParameterSetName = 'TPP')]
        [TppCertificateStage[]] $Stage,

        [Parameter(ParameterSetName = 'TPP')]
        [Alias('StageGreater')]
        [TppCertificateStage] $StageGreaterThan,

        [Parameter(ParameterSetName = 'TPP')]
        [Alias('StageLess')]
        [TppCertificateStage] $StageLessThan,

        [Parameter(ParameterSetName = 'TPP')]
        [Switch] $ValidationEnabled,

        [Parameter(ParameterSetName = 'TPP')]
        [ValidateSet('Blank', 'Success', 'Failure')]
        [String[]] $ValidationState,

        [Parameter(ParameterSetName = 'VaaS')]
        [System.Collections.ArrayList] $Filter,

        [parameter(ParameterSetName = 'VaaS')]
        [psobject[]] $Order,

        [Parameter(ParameterSetName = 'TPP')]
        [Switch] $CountOnly,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        # this function can be run without params so we won't know tpp or vaas
        # have a different default param set for this
        if ( $PSCmdlet.ParameterSetName -eq 'NoParams' ) {
            # validate based on the session platform
            $platform = Test-VenafiSession -VenafiSession $VenafiSession -PassThru
        } else {
            # validate based on the paramset
            $platform = Test-VenafiSession -VenafiSession $VenafiSession -Platform $PSCmdlet.ParameterSetName -PassThru
        }

        if ( $platform -eq 'VaaS' ) {

            if ( $PSBoundParameters.ContainsKey('Skip') ) {
                Write-Warning '-Skip is not currently supported by VaaS'
            }

            $toRetrieveCount = if ($PSBoundParameters.ContainsKey('First') ) {
                $PSCmdlet.PagingParameters.First
            } else {
                1000 # default to max page size allowed
            }

            $queryParams = @{
                Filter            = $Filter
                Order             = $Order
                First             = $PSCmdlet.PagingParameters.First
                Skip              = $PSCmdlet.PagingParameters.Skip # not available in vaas yet
                IncludeTotalCount = $PSCmdlet.PagingParameters.IncludeTotalCount
            }

            $body = New-VaasSearchQuery @queryParams

            $params = @{
                VenafiSession = $VenafiSession
                Method        = 'Post'
                UriRoot       = 'outagedetection/v1'
                UriLeaf       = 'certificatesearch'
                Body          = $body
                # ensure we get json back otherwise we might get csv
                Header        = @{'Accept' = 'application/json' }
            }
        } else {

            $params = @{
                VenafiSession = $VenafiSession
                Method        = 'Get'
                UriLeaf       = 'certificates/'
                Body          = @{
                    Limit = 1000
                }
                FullResponse  = $true
            }

            if ( $PSBoundParameters.ContainsKey('Limit') ) {
                Write-Warning '-Limit parameter to be deprecated, please use -First'
                $params.Body.Limit = $Limit
            }

            if ($PSCmdlet.PagingParameters.First -ne [uint64]::MaxValue) {
                $params.Body.Limit = $PSCmdlet.PagingParameters.First
            }

            if ( $PSBoundParameters.ContainsKey('Offset') ) {
                Write-Warning '-Offset parameter to be deprecated, please use -Skip'
                $params.Body.Offset = $Offset
            }

            if ($PSCmdlet.PagingParameters.Skip) {
                $params.Body.Offset = $PSCmdlet.PagingParameters.Skip
            }

            if ( $CountOnly.IsPresent ) {
                $params.Method = 'Head'
            }

            switch ($PSBoundParameters.Keys) {
                'CreatedDate' {
                    $params.Body.Add( 'CreatedOn', ($CreatedDate | ConvertTo-UtcIso8601) )
                }
                'CreatedBefore' {
                    $params.Body.Add( 'CreatedOnLess', ($CreatedBefore | ConvertTo-UtcIso8601) )
                }
                'CreatedAfter' {
                    $params.Body.Add( 'CreatedOnGreater', ($CreatedAfter | ConvertTo-UtcIso8601) )
                }
                'CertificateType' {
                    $params.Body.Add( 'CertificateType', $CertificateType -join ',' )
                }
                'Country' {
                    $params.Body.Add( 'C', $Country )
                }
                'CommonName' {
                    $params.Body.Add( 'CN', $CommonName )
                }
                'Issuer' {
                    $params.Body.Add( 'Issuer', $Issuer )
                }
                'KeyAlgorithm' {
                    $params.Body.Add( 'KeyAlgorithm', $KeyAlgorithm -join ',' )
                }
                'KeySize' {
                    $params.Body.Add( 'KeySize', $KeySize -join ',' )
                }
                'KeySizeGreaterThan' {
                    $params.Body.Add( 'KeySizeGreater', $KeySizeGreaterThan )
                }
                'KeySizeLessThan' {
                    $params.Body.Add( 'KeySizeLess', $KeySizeLessThan )
                }
                'Locale' {
                    $params.Body.Add( 'L', $Locale -join ',' )
                }
                'Organization' {
                    $params.Body.Add( 'O', $Organization -join ',' )
                }
                'OrganizationUnit' {
                    $params.Body.Add( 'OU', $OrganizationUnit -join ',' )
                }
                'State' {
                    $params.Body.Add( 'S', $State -join ',' )
                }
                'SanDns' {
                    $params.Body.Add( 'SAN-DNS', $SanDns )
                }
                'SanEmail' {
                    $params.Body.Add( 'SAN-Email', $SanEmail )
                }
                'SanIP' {
                    $params.Body.Add( 'SAN-IP', $SanIP )
                }
                'SanUpn' {
                    $params.Body.Add( 'SAN-UPN', $SanUpn )
                }
                'SanUri' {
                    $params.Body.Add( 'SAN-URI', $SanUri )
                }
                'SerialNumber' {
                    $params.Body.Add( 'Serial', $SerialNumber )
                }
                'SignatureAlgorithm' {
                    $params.Body.Add( 'SignatureAlgorithm', $SignatureAlgorithm -join ',' )
                }
                'Thumbprint' {
                    $params.Body.Add( 'Thumbprint', $Thumbprint )
                }
                'IssueDate' {
                    $params.Body.Add( 'ValidFrom', ($IssueDate | ConvertTo-UtcIso8601) )
                }
                'ExpireDate' {
                    $params.Body.Add( 'ValidTo', ($ExpireDate | ConvertTo-UtcIso8601) )
                }
                'ExpireAfter' {
                    $params.Body.Add( 'ValidToGreater', ($ExpireAfter | ConvertTo-UtcIso8601) )
                }
                'ExpireBefore' {
                    $params.Body.Add( 'ValidToLess', ($ExpireBefore | ConvertTo-UtcIso8601) )
                }
                'Enabled' {
                    $params.Body.Add( 'Disabled', [int] (-not $Enabled) )
                }
                'InError' {
                    $params.Body.Add( 'InError', [int] $InError )
                }
                'NetworkValidationEnabled' {
                    $params.Body.Add( 'NetworkValidationDisabled', [int] (-not $NetworkValidationEnabled) )
                }
                'ManagementType' {
                    $params.Body.Add( 'ManagementType', $ManagementType -join ',' )
                }
                'PendingWorkflow' {
                    $params.Body.Add( 'PendingWorkflow', '')
                }
                'Stage' {
                    $params.Body.Add( 'Stage', ($Stage | ForEach-Object { [TppCertificateStage]::$_.value__ }) -join ',' )
                }
                'StageGreaterThan' {
                    $params.Body.Add( 'StageGreater', [TppCertificateStage]::$StageGreaterThan.value__ )
                }
                'StageLessThan' {
                    $params.Body.Add( 'StageLess', [TppCertificateStage]::$StageLessThan.value__ )
                }
                'ValidationEnabled' {
                    $params.Body.Add( 'ValidationDisabled', [int] (-not $ValidationEnabled) )
                }
                'ValidationState' {
                    $params.Body.Add( 'ValidationState', $ValidationState -join ',' )
                }
            }
        }
    }

    process {

        if ( $platform -eq 'VaaS' ) {

            do {

                $response = Invoke-VenafiRestMethod @params
                $response.certificates | Select-Object @{
                    'n' = 'certificateId'
                    'e' = {
                        $_.Id
                    }
                }, * -ExcludeProperty Id

                $body.paging.pageNumber += 1

                if ( -not $PSCmdlet.PagingParameters.IncludeTotalCount ) {
                    $toRetrieveCount -= $response.'count'

                    if ( $toRetrieveCount -le 0 ) {
                        break
                    }

                    if ( $toRetrieveCount -lt $body.paging.pageSize ) {
                        # if what's left to retrieve is less than the page size
                        # adjust to just retrieve the remaining amount
                        $body.paging.pageSize = $toRetrieveCount
                    }
                }

            } until (
                $response.'count' -eq 0 -or $response.'count' -lt $body.paging.pageSize
            )

        } else {


            if ( $PSBoundParameters.ContainsKey('Path') ) {
                $thisPath = $Path
            } elseif ( $PSBoundParameters.ContainsKey('Guid') ) {
                # guid provided, get path
                $thisPath = $Guid | ConvertTo-TppPath -VenafiSession $VenafiSession
            }

            if ( $thisPath ) {
                if ( $Recursive.IsPresent ) {
                    $params.Body.ParentDnRecursive = $thisPath
                } else {
                    $params.Body.ParentDn = $thisPath
                }
            }

            $response = Invoke-VenafiRestMethod @params

            $totalRecordCount = 0
            if ($PSVersionTable.PSVersion.Major -lt 6) {
                $totalRecordCount = [int]$response.Headers.'X-Record-Count'
            } else {
                $totalRecordCount = [int]($response.Headers.'X-Record-Count'[0])
            }

            if ( $CountOnly ) {
                return $totalRecordCount
            }

            Write-Verbose "Total number of records for this query: $totalRecordCount"

            $content = $response.content | ConvertFrom-Json
            $content.Certificates.ForEach{
                [TppObject] @{
                    TypeName = $_.SchemaClass
                    Path     = $_.DN
                    Guid     = [guid] $_.Guid
                }
            }

            # if option to get all records was provided, loop and get them all
            if ( $PSCmdlet.PagingParameters.IncludeTotalCount ) {

                $setPoint = $params.Body.Offset + $params.Body.Limit

                while ($totalRecordCount -gt $setPoint) {

                    # up the offset so we get the next set of records
                    $params.Body.Offset += $params.Body.Limit
                    $setPoint = $params.Body.Offset + $params.Body.Limit

                    $end = if ( $totalRecordCount -lt $setPoint ) {
                        $totalRecordCount
                    } else {
                        $setPoint
                    }

                    Write-Verbose ('getting {0}-{1} of {2}' -f ($params.Body.Offset + 1), $end, $totalRecordCount)
                    try {
                        $response = Invoke-VenafiRestMethod @params -Verbose:$false
                    } catch {
                        $ProgressPreference = $oldProgressPreference
                        throw $_
                    }

                    $content = $response.content | ConvertFrom-Json
                    $content.Certificates.ForEach{
                        [TppObject] @{
                            TypeName = $_.SchemaClass
                            Path     = $_.DN
                            Guid     = [guid] $_.Guid
                        }
                    }
                }
            }
        }
    }
}