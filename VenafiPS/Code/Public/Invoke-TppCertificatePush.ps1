<#
.SYNOPSIS
Push a certificate to an application

.DESCRIPTION
Push a certificate to one or more applications, or all associated
This will only be successful if the certificate management type is Provisioning and is not disabled, in error, or a push is already in process.

.PARAMETER CertificatePath
Path to the certificate.

.PARAMETER ApplicationPath
List of application object paths to push to.
If not provided, all associated applications will be pushed.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Path

.OUTPUTS
None

.EXAMPLE
$cert | Invoke-TppCertificatePush
Push certificate to all associated applications, certificate object piped

.EXAMPLE
Invoke-TppCertificatePush -CertificatePath '\ved\policy\my cert' -ApplicationPath '\ved\policy\my capi'
Push to a specific application associated with a certificate

.EXAMPLE
Invoke-TppCertificatePush -Path '\ved\policy\my cert'
Push certificate to all associated applications

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Invoke-TppCertificatePush/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Invoke-TppCertificatePush.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Push.php?tocpath=Web%20SDK%7CCertificates%20programming%20interface%7C_____15

#>
function Invoke-TppCertificatePush {

    [CmdletBinding()]
    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                } else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('DN', 'CertificateDN')]
        [String] $CertificatePath,

        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                } else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [String[]] $ApplicationPath,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate()

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'Certificates/Push'
            Body       = @{
                CertificateDN = ''
            }
        }

        if ( $PSBoundParameters.ContainsKey('ApplicationPath') ) {
            $params.Body.ApplicationDN = @($ApplicationPath)
        } else {
            $params.Body.PushToAll = 'true'
        }

    }

    process {
        $params.Body.CertificateDN = $CertificatePath
        $null = Invoke-TppRestMethod @params
    }
}
