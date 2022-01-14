<#
.SYNOPSIS
Renew a certificate

.DESCRIPTION
Requests renewal for an existing certificate. This call marks a certificate for
immediate renewal. The certificate must not be in error, already being processed, or
configured for Monitoring in order for it be renewable. You must have Write access
to the certificate object being renewed.

.PARAMETER InputObject
TppObject which represents a unique object

.PARAMETER Path
Path to the certificate to remove

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
InputObject or Path

.OUTPUTS
PSCustomObject with the following properties:
    Path - Certificate path
    Success - A value of true indicates that the renewal request was successfully submitted and
    granted.
    Error - Indicates any errors that occurred. Not returned when successful

.EXAMPLE
Invoke-TppCertificateRenewal -Path '\VED\Policy\My folder\app.mycompany.com'

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
        [Parameter(Mandatory, ParameterSetName = 'ByObject', ValueFromPipeline)]
        [TppObject] $InputObject,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'ByPath')]
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
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate() | Out-Null

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'certificates/renew'
            Body       = @{
                CertificateDN = ''
            }
        }
    }

    process {

        if ( $PSBoundParameters.ContainsKey('InputObject') ) {
            $path = $InputObject.Path
        }

        if ( $PSCmdlet.ShouldProcess($Path, 'Renew certificate') ) {

            write-verbose "Renewing $Path..."

            $params.Body.CertificateDN = $Path
            $response = Invoke-TppRestMethod @params

            $response | Add-Member @{'Path' = $Path } -PassThru
        }
    }
}
