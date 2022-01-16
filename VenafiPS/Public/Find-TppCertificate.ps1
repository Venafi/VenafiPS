<#
.SYNOPSIS
Find certificates based on various attributes

.DESCRIPTION
Find certificates based on various attributes

.PARAMETER Path
Starting path to search from

.PARAMETER Guid
Guid which represents a starting path

.PARAMETER Recursive
Search recursively starting from the search path.

.PARAMETER First
Limit how many items are returned.  Default is 0 for no limit.
It is definitely recommended to filter on another property when searching with no limit.

.PARAMETER Offset
The number of results to skip.

.PARAMETER Country
Find certificates by Country attribute of Subject DN.

.PARAMETER CommonName
Find certificates by Common name attribute of Subject DN.

.PARAMETER Issuer
Find certificates by issuer. Use the CN, O, L, S, and C values from the certificate request.

.PARAMETER KeyAlgorithm
Find certificates by algorithm for the public key.

.PARAMETER KeySize
Find certificates by public key size.

.PARAMETER KeySizeGreaterThan
Find certificates with a key size greater than the specified value.

.PARAMETER KeySizeLessThan
Find certificates with a key size less than the specified value.

.PARAMETER Locale
Find certificates by Locality/City attribute of Subject Distinguished Name (DN).

.PARAMETER Organization
Find certificates by Organization attribute of Subject DN.

.PARAMETER OrganizationUnit
Find certificates by Organization Unit (OU).

.PARAMETER State
Find certificates by State/Province attribute of Subject DN.

.PARAMETER SanDns
Find certificates by Subject Alternate Name (SAN) Distinguished Name Server (DNS).

.PARAMETER SanEmail
Find certificates by SAN Email RFC822.

.PARAMETER SanIP
Find certificates by SAN IP Address.

.PARAMETER SanUpn
Find certificates by SAN User Principal Name (UPN) or OtherName.

.PARAMETER SanUri
Find certificates by SAN Uniform Resource Identifier (URI).

.PARAMETER SerialNumber
Find certificates by Serial number.

.PARAMETER SignatureAlgorithm
Find certificates by the algorithm used to sign the certificate (e.g. SHA1RSA).

.PARAMETER Thumbprint
Find certificates by one or more SHA-1 thumbprints.

.PARAMETER IssueDate
Find certificates by the date of issue.

.PARAMETER ExpireDate
Find certificates by expiration date.

.PARAMETER ExpireAfter
Find certificates that expire after a certain date.

.PARAMETER ExpireBefore
Find certificates that expire before a certain date.

.PARAMETER Enabled
Include only certificates that are enabled or disabled

.PARAMETER InError
Only include certificates in an error state

.PARAMETER NetworkValidationEnabled
Only include certificates with network validation enabled or disabled

.PARAMETER CreatedDate
Find certificates that were created at an exact date and time

.PARAMETER CreatedAfter
Find certificate created after this date and time

.PARAMETER CreatedBefore
Find certificate created before this date and time

.PARAMETER CertificateType
Find certificate by category of usage. Use CodeSigning, Device, Server, and/or User.

.PARAMETER ManagementType
Find certificates with a Management type of Unassigned, Monitoring, Enrollment, or Provisioning

.PARAMETER PendingWorkflow
Only include certificates that have a pending workflow resolution (have an outstanding workflow ticket)

.PARAMETER Stage
Find certificates by one or more stages in the certificate lifecycle

.PARAMETER StageGreaterThan
Find certificates with a stage greater than the specified stage (does not include specified stage)

.PARAMETER StageLessThan
Find certificates with a stage less than the specified stage (does not include specified stage)

.PARAMETER ValidationEnabled
Only include certificates with validation enabled or disabled

.PARAMETER ValidationState
Find certificates with a validation state of Blank, Success, or Failure

.PARAMETER CountOnly
Return the count of certificates found from the query as opposed to the certificates themselves

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Path, Guid

.OUTPUTS
TppObject, Int when CountOnly provided

.EXAMPLE
Find-TppCertificate -ExpireBefore "2018-01-01"
Find all certificates expiring before a certain date

.EXAMPLE
Find-TppCertificate -ExpireBefore "2018-01-01" -First 5
Find 5 certificates expiring before a certain date

.EXAMPLE
Find-TppCertificate -ExpireBefore "2018-01-01" -First 5 -Offset 2
Find 5 certificates expiring before a certain date, starting at the 3rd certificate found.

.EXAMPLE
Find-TppCertificate -Path '\VED\Policy\My Policy'
Find all certificates in a specific path

.EXAMPLE
Find-TppCertificate -Issuer 'CN=Example Root CA, O=Venafi,Inc., L=Salt Lake City, S=Utah, C=US'
Find all certificates by issuer

.EXAMPLE
Find-TppCertificate -Path '\VED\Policy\My Policy' -Recursive
Find all certificates in a specific path and all subfolders

.EXAMPLE
Find-TppCertificate -ExpireBefore "2018-01-01" -First 5 | Get-VenafiCertificate
Get detailed certificate info on the first 5 certificates expiring before a certain date

.EXAMPLE
Find-TppCertificate -ExpireBefore "2019-09-01" | Invoke-TppCertificateRenewal
Renew all certificates expiring before a certain date

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppCertificate/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppCertificate.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates-guid.php

.LINK
https://msdn.microsoft.com/en-us/library/system.web.httputility(v=vs.110).aspx

#>
function Find-TppCertificate {

    [CmdletBinding(DefaultParameterSetName = 'NoPath')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ByPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath -AllowRoot ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('DN')]
        [String] $Path,

        [Parameter(Mandatory, ParameterSetName = 'ByGuid', ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [guid] $Guid,

        [Parameter(ParameterSetName = 'ByPath')]
        [Parameter(ParameterSetName = 'ByGuid')]
        [Switch] $Recursive,

        [Parameter()]
        [Alias('Limit')]
        [int] $First = 0,

        [Parameter()]
        [int] $Offset,

        [Parameter()]
        [Alias('C')]
        [String] $Country,

        [Parameter()]
        [Alias('CN')]
        [String] $CommonName,

        [Parameter()]
        [String] $Issuer,

        [Parameter()]
        [String[]] $KeyAlgorithm,

        [Parameter()]
        [Int[]] $KeySize,

        [Parameter()]
        [Int] $KeySizeGreaterThan,

        [Parameter()]
        [Int] $KeySizeLessThan,

        [Parameter()]
        [Alias('L')]
        [String[]] $Locale,

        [Parameter()]
        [Alias('O')]
        [String[]] $Organization,

        [Parameter()]
        [Alias('OU')]
        [String[]] $OrganizationUnit,

        [Parameter()]
        [Alias('S')]
        [String[]] $State,

        [Parameter()]
        [String] $SanDns,

        [Parameter()]
        [String] $SanEmail,

        [Parameter()]
        [String] $SanIP,

        [Parameter()]
        [String] $SanUpn,

        [Parameter()]
        [String] $SanUri,

        [Parameter()]
        [String] $SerialNumber,

        [Parameter()]
        [String] $SignatureAlgorithm,

        [Parameter()]
        [String] $Thumbprint,

        [Parameter()]
        [Alias('ValidFrom')]
        [DateTime] $IssueDate,

        [Parameter()]
        [Alias('ValidTo')]
        [DateTime] $ExpireDate,

        [Parameter()]
        [Alias('ValidToGreater')]
        [DateTime] $ExpireAfter,

        [Parameter()]
        [Alias('ValidToLess')]
        [DateTime] $ExpireBefore,

        [Parameter()]
        [Switch] $Enabled,

        [Parameter()]
        [bool] $InError,

        [Parameter()]
        [bool] $NetworkValidationEnabled,

        [Parameter()]
        [Alias('CreatedOn')]
        [datetime] $CreatedDate,

        [Parameter()]
        [Alias('CreatedOnGreater')]
        [datetime] $CreatedAfter,

        [Parameter()]
        [Alias('CreatedOnLess')]
        [datetime] $CreatedBefore,

        [Parameter()]
        [ValidateSet('CodeSigning', 'Device', 'Server', 'User')]
        [String[]] $CertificateType,

        [Parameter()]
        [TppManagementType[]] $ManagementType,

        [Parameter()]
        [Switch] $PendingWorkflow,

        [Parameter()]
        [TppCertificateStage[]] $Stage,

        [Parameter()]
        [Alias('StageGreater')]
        [TppCertificateStage] $StageGreaterThan,

        [Parameter()]
        [Alias('StageLess')]
        [TppCertificateStage] $StageLessThan,

        [Parameter()]
        [Switch] $ValidationEnabled,

        [Parameter()]
        [ValidateSet('Blank', 'Success', 'Failure')]
        [String[]] $ValidationState,

        [Parameter()]
        [Switch] $CountOnly,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('TPP')

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Get'
            UriLeaf       = 'certificates/'
            Body          = @{
                Limit = $First
            }
        }

        if ( $CountOnly.IsPresent ) {
            $params.Method = 'Head'
            $params['FullResponse'] = $true
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
                $params.Body.Add( 'CertificateType', $CertificateType  -join ',' )
            }
            'Offset' {
                $params.Body.Add( 'Offset', $Offset )
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

    process {

        if ( $PSBoundParameters.ContainsKey('Path') ) {
            $thisPath = $Path
        }
        elseif ( $PSBoundParameters.ContainsKey('Guid') ) {
            # guid provided, get path
            $thisPath = $Guid | ConvertTo-TppPath -VenafiSession $VenafiSession
        }

        if ( $thisPath ) {
            if ( $Recursive.IsPresent ) {
                $params.Body.ParentDnRecursive = $thisPath
            }
            else {
                $params.Body.ParentDn = $thisPath
            }
        }

        $response = Invoke-TppRestMethod @params

        if ( $CountOnly.IsPresent ) {
            $response.Headers.'X-Record-Count'
        }
        else {
            $response.Certificates.ForEach{
                [TppObject] @{
                    Name     = $_.Name
                    TypeName = $_.SchemaClass
                    Path     = $_.DN
                    Guid     = [guid] $_.Guid
                }
            }
        }
    }
}