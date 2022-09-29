function New-VaasCertificate {
    <#
    .SYNOPSIS
    Create certificate request

    .DESCRIPTION
    Create certificate request from automated secure keypair details or CSR

    .PARAMETER Application
    Application name (wildcards supported) or id to associate this certificate.

    .PARAMETER IssuingTemplate
    Issuing template name (wildcards supported) or id to use.
    The template must be available with the selected Application.

    .PARAMETER ServerType
    Server type name (wildcards supported) or id to associate

    .PARAMETER Csr
    CSR in PKCS#10 format which conforms to the rules of the issuing template

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

    .PARAMETER ValidUntil
    Date at which the certificate becomes invalid.
    Days and hours are supported, not minutes.

    .PARAMETER PassThru
    Return the certificate request.
    If the certificate was successfully issued, it will be returned as the property 'certificate'.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided directly.

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
    New-VaasCertificate -Application 'MyApp' -IssuingTemplate 'MSCA - 1 year' -ServerType 'F5' -CommonName 'app.mycert.com' -PassThru

    Create certificate and return the created object

    .EXAMPLE
    New-VaasCertificate -Application 'MyApp' -IssuingTemplate 'MSCA - 1 year' -ServerType 'F5' -Csr "-----BEGIN CERTIFICATE REQUEST-----\nMIICYzCCAUsCAQAwHj....BoiNIqtVQxFsfT+\n-----END CERTIFICATE REQUEST-----\n"

    Create certificate with a CSR

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/New-VaasCertificate/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-VaasCertificate.ps1

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Certificate%20Request/certificaterequests_create

    #>

    [CmdletBinding(DefaultParameterSetName = 'Ask', SupportsShouldProcess)]

    param (

        [Parameter(Mandatory)]
        [String] $Application,

        [Parameter(Mandatory)]
        [String] $IssuingTemplate,

        [Parameter(Mandatory)]
        [String] $ServerType,

        [Parameter(ParameterSetName = 'Csr', Mandatory)]
        [string] $Csr,

        [Parameter(ParameterSetName = 'Ask', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $CommonName,

        [Parameter(ParameterSetName = 'Ask')]
        [ValidateNotNullOrEmpty()]
        [String] $Organization,

        [Parameter(ParameterSetName = 'Ask')]
        [ValidateNotNullOrEmpty()]
        [String[]] $OrganizationalUnit,

        [Parameter(ParameterSetName = 'Ask')]
        [ValidateNotNullOrEmpty()]
        [String] $City,

        [Parameter(ParameterSetName = 'Ask')]
        [ValidateNotNullOrEmpty()]
        [String] $State,

        [Parameter(ParameterSetName = 'Ask')]
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
        [ValidateScript(
            {
                $span = $_ - (Get-Date)
                if ( $span.Days -ge 0 -or $span.Hours -ge 0 ) {
                    $true
                } else {
                    throw 'ValidUntil must be a date in the future'
                }
            }
        )]
        [DateTime] $ValidUntil = (Get-Date).AddYears(1),

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        # validation
        $allApps = Get-VaasApplication -All -VenafiSession $VenafiSession
        $allServerTypes = Invoke-VenafiRestMethod -UriRoot 'outagedetection/v1' -UriLeaf 'applicationservertypes' -VenafiSession $VenafiSession | Select-Object -ExpandProperty applicationservertypes

        $thisApp = $allApps | Where-Object { $_.Name -like $Application -or $_.applicationId -eq $Application }
        switch (@($thisApp).Count) {
            0 {
                throw ('Application not found.  Valid applications are {0}.' -f ($allApps.name -join ', '))
            }

            1 {
                Write-Verbose ('Found application {0}, ID: {1}' -f $thisApp.name, $thisApp.applicationId)
                $thisAppID = $thisApp.applicationId
            }

            Default {
                throw ('More than 1 application found that matches {0}: {1}' -f $Application, ($thisApp.name -join ', '))
            }
        }

        $thisTemplate = $thisApp.certificateIssuingTemplate | Where-Object { $_.Name -like $IssuingTemplate -or $_.id -eq $IssuingTemplate }
        switch (@($thisTemplate).Count) {
            0 {
                throw ('Issuing template not found or not valid for this application.  Valid templates are {0}.' -f ($thisApp.certificateIssuingTemplate.name -join ', '))
            }

            1 {
                Write-Verbose ('Found template {0}, ID: {1}' -f $thisTemplate.name, $thisTemplate.id)
                $thisTemplateID = $thisTemplate.id
            }

            Default {
                throw ('More than 1 issuing template found that matches {0}: {1}' -f $IssuingTemplate, ($thisTemplate.name -join ', '))
            }
        }

        $thisServerType = $allServerTypes | Where-Object { $_.applicationServerType -like $ServerType -or $_.id -eq $ServerType }
        switch (@($thisServerType).Count) {
            0 {
                throw ('Server type not found.  Valid types are {0}' -f ($allServerTypes.name -join ', '))
            }

            1 {
                Write-Verbose ('Found server type {0}, ID: {1}' -f $thisServerType.applicationServerType, $thisServerType.id)
                $thisServerTypeID = $thisServerType.id
            }

            Default {
                throw ('More than 1 server type found that matches {0}: {1}' -f $ServerType, ($thisServerType.name -join ', '))
            }
        }

        $span = New-TimeSpan -Start (Get-Date) -End $ValidUntil
        $validity = 'P{0}DT{1}H' -f $span.Days, $span.Hours

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
            }
        }

        if ( $PSCmdlet.ParameterSetName -eq 'Ask' ) {
            $params.Body.csrAttributes = @{}
        } else {
            $params.Body.certificateSigningRequest = $Csr
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

        if ( $PSCmdlet.ParameterSetName -eq 'Ask' ) {
            $params.Body.csrAttributes.commonName = $CommonName
            $target = $CommonName
        } else {
            $target = 'CSR'
        }

        if ( $PSCmdlet.ShouldProcess("$target", 'New certificate request') ) {

            try {
                $response = Invoke-VenafiRestMethod @params

                if ( $PassThru ) {
                    $certRequest = $response | Select-Object -ExpandProperty certificateRequests

                    if ( $certRequest.certificateIds ) {
                        $actualCert = Get-VenafiCertificate -CertificateId $certRequest.certificateIds[0]
                        $certRequest | Add-Member @{ 'certificate' = $actualCert }
                    }

                    $certRequest | Select-Object @{'n' = 'certificateRequestId'; 'e' = { $_.id } }, *, @{'n' = 'certificateId'; 'e' = { $_.certificateIds } } -ExcludeProperty id, certificateIds
                }
            } catch {
                Write-Error $_
                continue
            }
        }
    }
}
