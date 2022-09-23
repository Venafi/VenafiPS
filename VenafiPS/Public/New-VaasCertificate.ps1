function New-VaasCertificate {
    <#
    .SYNOPSIS
    Create certificate request

    .DESCRIPTION
    Create certificate request

    .PARAMETER Application
    Application name (wildcards supported) or id to associate this certificate.

    .PARAMETER IssuingTemplate
    Issuing template name (wildcards supported) or id to use.
    The template must be available with the selected Application.

    .PARAMETER ServerType
    Server type name (wildcards supported) or id to associate

    .PARAMETER CommonName
    Common name (CN)

    .PARAMETER Organization
    The Organization field for the certificate Subject DN

    .PARAMETER OrganizationalUnit
    One or more departments or divisions within the organization that is responsible for maintaining the certificate

    .PARAMETER City
    The City/Locality field for the certificate Subject DN

    .PARAMETER State
    The State field for the certificate Subject DN

    .PARAMETER Country
    The Country field for the certificate Subject DN

    .PARAMETER SanDns
    One or more subject alternative name dns entries

    .PARAMETER SanIP
    One or more subject alternative name ip address entries

    .PARAMETER SanUri
    One or more subject alternative name uri entries

    .PARAMETER SanEmail
    One or more subject alternative name email entries

    .PARAMETER PassThru
    Return the certificate request.
    If the certificate was successfully issued, it will be returned as the property 'certificate'.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    CommonName

    .OUTPUTS
    pscustomobject, if PassThru is provided

    .EXAMPLE
    New-VaasCertificate -Application 'MyApp' -IssuingTemplate 'MSCA - 1 year' -ServerType 'F5' -CommonName 'app.mycert.com'

    Create certificate

    .EXAMPLE
    New-VaasCertificate -Application 'MyApp' -IssuingTemplate 'MSCA - 1 year' -ServerType 'F5' -CommonName 'app.mycert.com' -SanIP '1.2.3.4'

    Create certificate with optional SAN data

    .EXAMPLE
    New-VaasCertificate -Application 'MyApp' -IssuingTemplate 'MSCA - 1 year' -ServerType 'F5' -CommonName 'app.mycert.com' -ValidUntil (Get-Date).AddMonths(6)

    Create certificate with specific validity

    .EXAMPLE
    New-VaasCertificate -Application 'MyApp' -IssuingTemplate 'MSCA - 1 year' -ServerType 'F5' -CommonName 'app.mycert.com'

    Create certificate and return the created object

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/New-VaasCertificate/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-VaasCertificate.ps1

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Certificate%20Request/certificaterequests_create

    #>

    [CmdletBinding(SupportsShouldProcess)]

    param (

        [Parameter(Mandatory)]
        [String] $Application,

        [Parameter(Mandatory)]
        [String] $IssuingTemplate,

        [Parameter(Mandatory)]
        [String] $ServerType,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $CommonName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String] $Organization,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String[]] $OrganizationalUnit,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String] $City,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String] $State,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String] $Country,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String[]] $SanDns,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String[]] $SanIP,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String[]] $SanUri,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String[]] $SanEmail,

        [Parameter()]
        [DateTime] $ValidUntil = (Get-Date).AddYears(1),

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        # validation
        $allApps = Get-VaasApplication -All
        $allServerTypes = Invoke-VenafiRestMethod -UriRoot 'outagedetection/v1' -UriLeaf 'applicationservertypes' -VenafiSession $VenafiSession | Select-Object -ExpandProperty applicationservertypes

        $thisApp = $allApps | Where-Object { $_.Name -like $Application -or $_.applicationId -eq $Application }
        switch (@($thisApp).Count) {
            0 {
                throw 'Application not found'
            }

            1 {
                Write-Verbose ('Found application {0}, ID: {1}' -f $thisApp.name, $thisApp.applicationId)
                $thisAppID = $thisApp.applicationId
            }

            Default {
                throw "More than 1 application found that matches $Application"
            }
        }

        $thisTemplate = $thisApp.certificateIssuingTemplate | Where-Object { $_.Name -like $IssuingTemplate -or $_.id -eq $IssuingTemplate }
        switch (@($thisTemplate).Count) {
            0 {
                throw 'Issuing template not found or not valid for this application'
            }

            1 {
                Write-Verbose ('Found template {0}, ID: {1}' -f $thisTemplate.name, $thisTemplate.id)
                $thisTemplateID = $thisTemplate.id
            }

            Default {
                throw "More than 1 issuing template found that matches $IssuingTemplate"
            }
        }

        $thisServerType = $allServerTypes | Where-Object { $_.applicationServerType -like $ServerType -or $_.id -eq $ServerType }
        switch (@($thisServerType).Count) {
            0 {
                throw 'Server type not found'
            }

            1 {
                Write-Verbose ('Found server type {0}, ID: {1}' -f $thisServerType.applicationServerType, $thisServerType.id)
                $thisServerTypeID = $thisServerType.id
            }

            Default {
                throw "More than 1 server type found that matches $ServerType"
            }
        }

        $ApproxDaysPerMonth = 30.4375
        $ApproxDaysPerYear = 365.25

        # Calculate the span in days
        [int]$iDays = ($ValidUntil - [DateTime]::Now).Days

        # Calculate years as an integer division
        [int]$iYears = [math]::floor($iDays / $ApproxDaysPerYear)

        # Decrease remaing days
        $iDays -= [int]($iYears * $ApproxDaysPerYear)

        # Calculate months as an integer division
        [int]$iMonths = [math]::floor($iDays / $ApproxDaysPerMonth)

        # Decrease remaing days
        $iDays -= [int]($iMonths * $ApproxDaysPerMonth)

        $validity = 'P'
        if ( $iYears ) { $validity += '{0}Y' -f $iYears }
        if ( $iMonths ) { $validity += '{0}M' -f $iMonths }
        if ( $iDays ) { $validity += '{0}D' -f $iDays }

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriRoot       = 'outagedetection/v1'
            UriLeaf       = 'certificaterequests'
            Body          = @{
                isVaaSGenerated              = $true
                applicationId                = $thisAppID
                certificateIssuingTemplateId = $thisTemplateID
                applicationServerTypeId      = $thisServerTypeID
                validityPeriod               = $validity
                csrAttributes                = @{}
            }
        }

        if ( $PSBoundParameters.ContainsKey('Organization') ) {
            $params.Body.csrAttributes.organization = $Organization
        }

        if ( $PSBoundParameters.ContainsKey('OrganizationalUnit') ) {
            $params.Body.csrAttributes.organizationalUnits = @($OrganizationalUnit)
        }

        if ( $PSBoundParameters.ContainsKey('City') ) {
            $params.Body.csrAttributes.locality = $City
        }

        if ( $PSBoundParameters.ContainsKey('State') ) {
            $params.Body.csrAttributes.state = $State
        }

        if ( $PSBoundParameters.ContainsKey('Country') ) {
            $params.Body.csrAttributes.country = $Country
        }

        if ( Compare-Object -ReferenceObject $PSBoundParameters.Keys -DifferenceObject 'SanDns|SanEmail|SanIP|SanUri' -IncludeEqual | Where-Object { $_.SideIndicator -eq '==' } ) {
            $params.Body.csrAttributes.subjectAlternativeNamesByType = @{}

            if ( $PSBoundParameters.ContainsKey('SanDns') ) {
                $params.Body.csrAttributes.subjectAlternativeNamesByType.dnsNames = @($SanDns)
            }

            if ( $PSBoundParameters.ContainsKey('SanEmail') ) {
                $params.Body.csrAttributes.subjectAlternativeNamesByType.rfc822Names = @($SanEmail)
            }

            if ( $PSBoundParameters.ContainsKey('SanIP') ) {
                $params.Body.csrAttributes.subjectAlternativeNamesByType.ipAddresses = @($SanIP)
            }

            if ( $PSBoundParameters.ContainsKey('SanUri') ) {
                $params.Body.csrAttributes.subjectAlternativeNamesByType.uniformResourceIdentifiers = @($SanUri)
            }
        }
    }

    process {

        $params.Body.csrAttributes.commonName = $CommonName

        if ( $PSCmdlet.ShouldProcess("$CommonName", 'New certificate request') ) {

            try {
                $response = Invoke-VenafiRestMethod @params

                if ( $PassThru ) {
                    $certRequest = $response | Select-Object -ExpandProperty certificateRequests

                    if ( $certRequest.certificateIds ) {
                        $actualCert = Get-VenafiCertificate -CertificateId $certRequest.certificateIds[0]
                        $certRequest | Add-Member @{ 'certificate' = $actualCert }
                    }

                    $certRequest
                }
            } catch {
                Write-Error $_
                continue
            }
        }
    }
}
