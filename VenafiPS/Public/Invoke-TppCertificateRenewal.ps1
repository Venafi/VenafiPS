<#
.SYNOPSIS
Renew a certificate

.DESCRIPTION
Requests renewal for an existing certificate. This call marks a certificate for
immediate renewal. The certificate must not be in error, already being processed, or
configured for Monitoring in order for it be renewable. You must have Write access
to the certificate object being renewed.

.PARAMETER Path
Path to the certificate to renew

.PARAMETER Csr
Optional PKCS#10 Certificate Signing Request (CSR).

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.
The value defaults to the script session object $VenafiSession.

.INPUTS
Path

.OUTPUTS
PSCustomObject with the following properties:
    Path - Certificate path
    Success - A value of true indicates that the renewal request was successfully submitted and
    granted.
    Error - Indicates any errors that occurred. Not returned when successful

.EXAMPLE
Invoke-TppCertificateRenewal -Path '\VED\Policy\My folder\app.mycompany.com'

.EXAMPLE
Invoke-TppCertificateRenewal -Path '\VED\Policy\My folder\app.mycompany.com' -Csr '-----BEGIN CERTIFICATE REQUEST-----\nMIIDJDCCAgwCAQAw...-----END CERTIFICATE REQUEST-----'
Renew certificate using a CSR

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Invoke-TppCertificateRenewal/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Invoke-TppCertificateRenewal.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-renew.php

#>
function Invoke-TppCertificateRenewal {

    [CmdletBinding(SupportsShouldProcess)]
    [Alias('itcr')]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('DN', 'CertificateDN')]
        [String] $Path,

        [Parameter()]
        [string] $Csr,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriLeaf       = 'certificates/renew'
            Body          = @{
                CertificateDN = ''
            }
        }
    }

    process {

        if ( $PSCmdlet.ShouldProcess($Path, 'Renew certificate') ) {

            write-verbose "Renewing $Path..."

            $params.Body.CertificateDN = $Path

            if ( $Csr ) {
                $params.Body.PKCS10 = $Csr -replace "`n|`r", ""
            }

            $response = Invoke-VenafiRestMethod @params

            $response | Add-Member @{'Path' = $Path } -PassThru
        }
    }
}
