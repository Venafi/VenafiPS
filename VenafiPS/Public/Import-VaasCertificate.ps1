function Import-VaasCertificate {
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
    Application to assign to this certificate

    .PARAMETER PassThru
    Return imported certificate details

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .EXAMPLE
    Import-VaasCertificate -CertificatePath c:\www.VenafiPS.com.cer

    Import a certificate

    .EXAMPLE
    Import-VaasCertificate -CertificatePath c:\www.VenafiPS.com.cer -Application 'a2f83b26-c712-4f46-be41-2e1fb901f20c'

    Import a certificate and assign an application

    .EXAMPLE
    Import-VaasCertificate -CertificatePath (gci c:\certs).FullName

    Import multiple certificates

    .EXAMPLE
    Export-VenafiCertificate -CertificateId '\ved\policy\my.cert.com' -Format Base64 | Import-VaasCertificate -VenafiSession $vaas_key

    Export from TPP and import into VaaS.
    As $VenafiSession can only point to one platform at a time, in this case TPP, the session needs to be overridden for the import.

    .EXAMPLE
    Find-TppCertificate -Path '\ved\policy\certs' -Recursive | Export-VenafiCertificate -Format Base64 | Import-VaasCertificate -VenafiSession $vaas_key

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
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriRoot       = 'outagedetection/v1'
            UriLeaf       = 'certificates'
            Body          = @{
                'overrideBlocklist' = 'true'
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
                $allCerts.Add(
                    @{
                        'certificate'    = [System.Convert]::ToBase64String($cert)
                        'applicationIds' = $Application
                    }
                )
            }
        } else {
            foreach ($thisCertData in $CertificateData) {
                $allCerts.Add(
                    @{
                        'certificate'    = $thisCertData
                        'applicationIds' = $Application
                    }
                )
            }
        }

    }

    end {
        $params.Body.certificates = $allCerts

        $response = Invoke-VenafiRestMethod @params

        Write-Verbose $response.statistics

        if ( $PassThru ) {
            $response.certificateInformations
        }
    }
}
