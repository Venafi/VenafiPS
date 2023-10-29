function Import-VcCertificate {
    <#
    .SYNOPSIS
    Import one or more certificates

    .DESCRIPTION
    Import one or more certificates.
    The blocklist will be overridden.

    .PARAMETER CertificatePath
    Path to a certificate file.  Provide either this or CertificateData.

    .PARAMETER CertificateData
    Contents of a certificate to import.  Provide either this or CertificatePath.

    .PARAMETER Application
    Application name (wildcards supported) or id to associate this certificate.

    .PARAMETER PassThru
    Return imported certificate details

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .EXAMPLE
    Import-VcCertificate -CertificatePath c:\www.VenafiPS.com.cer

    Import a certificate

    .EXAMPLE
    Import-VcCertificate -CertificatePath c:\www.VenafiPS.com.cer -Application MyApp

    Import a certificate and assign an application

    .EXAMPLE
    Import-VcCertificate -CertificatePath (gci c:\certs).FullName

    Import multiple certificates

    .EXAMPLE
    Export-VdcCertificate -CertificateId '\ved\policy\my.cert.com' -Format Base64 | Import-VcCertificate -VenafiSession $vaas_key

    Export from TPP and import into VaaS.
    As $VenafiSession can only point to one platform at a time, in this case TPP, the session needs to be overridden for the import.

    .EXAMPLE
    Find-VdcCertificate -Path '\ved\policy\certs' -Recursive | Export-VdcCertificate -Format Base64 | Import-VcCertificate -VenafiSession $vaas_key

    Bulk export from TPP and import into VaaS.
    As $VenafiSession can only point to one platform at a time, in this case TPP, the session needs to be overridden for the import.

    .INPUTS
    CertificatePath, CertificateData

    .OUTPUTS
    PSCustomObject, if PassThru provided

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Certificates/certificateimports_create
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByFile')]
    [Alias('Import-VaasCertificate')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ByFile', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-Path ) {
                    $true
                } else {
                    throw "'$_' is not a valid path"
                }
            })]
        [Alias('FullName')]
        [String[]] $CertificatePath,

        [Parameter(Mandatory, ParameterSetName = 'ByData', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String[]] $CertificateData,

        [Parameter()]
        [String[]] $Application,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        $params = @{

            Method        = 'Post'
            UriRoot       = 'outagedetection/v1'
            UriLeaf       = 'certificates'
            Body          = @{
                'overrideBlocklist' = 'true'
            }
        }

        if ( $PSBoundParameters.ContainsKey('Application') ) {
            $allApps = Get-VcApplication -All
            $appsForImport = foreach ($thisApplication in $Application) {
                $appFound = $allApps | Where-Object { $_.Name -like $Application -or $_.applicationId -eq $Application }
                switch (@($appFound).Count) {
                    0 {
                        throw ('Application not found.  Valid applications are {0}.' -f ($allApps.name -join ', '))
                    }

                    1 {
                        Write-Verbose ('Found application {0}, ID: {1}' -f $appFound.name, $appFound.applicationId)
                        $appFound.applicationId
                    }

                    Default {
                        throw ('More than 1 application found that matches {0}: {1}' -f $Application, ($thisApp.name -join ', '))
                    }
                }
            }
        }

        $allCerts = [System.Collections.Generic.List[object]]::new()
    }

    process {

        if ( $PSCmdlet.ParameterSetName -like 'ByFile*' ) {
            foreach ($thisCertPath in $CertificatePath) {

                if ($PSVersionTable.PSVersion.Major -lt 6) {
                    $cert = Get-Content $thisCertPath -Encoding Byte
                } else {
                    $cert = Get-Content $thisCertPath -AsByteStream
                }

                $newCert = @{
                    'certificate' = [System.Convert]::ToBase64String($cert)
                }
                if ( $appsForImport ) {
                    $newCert.applicationIds = @($appsForImport)
                }
                $allCerts.Add($newCert)
            }
        } else {
            foreach ($thisCertData in $CertificateData) {
                $newCert = @{
                    'certificate' = $thisCertData -replace "`r|`n|-----BEGIN CERTIFICATE-----|-----END CERTIFICATE-----"
                }
                if ( $appsForImport ) {
                    $newCert.applicationIds = @($appsForImport)
                }
                $allCerts.Add($newCert)
            }
        }

    }

    end {
        $params.Body.certificates = $allCerts

        $response = Invoke-VenafiRestMethod @params

        Write-Verbose $response.statistics

        if ( $PassThru ) {
            $response.certificateInformations | Get-VcCertificate
        }
    }
}
