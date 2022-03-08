<#
.SYNOPSIS
Add certificate association

.DESCRIPTION
Associates one or more Application objects to an existing certificate.
Optionally, you can push the certificate once the association is complete.

.PARAMETER InputObject
TppObject which represents a certificate

.PARAMETER CertificatePath
Path to the certificate.  Required if InputObject not provided.

.PARAMETER ApplicationPath
List of application object paths to associate

.PARAMETER PushCertificate
Push the certificate after associating it to the Application objects.
This will only be successful if the certificate management type is Provisioning and is not disabled, in error, or a push is already in process.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
InputObject, Path

.OUTPUTS
None

.EXAMPLE
Add-TppCertificateAssociation -CertificatePath '\ved\policy\my cert' -ApplicationPath '\ved\policy\my capi'
Add a single application object association

.EXAMPLE
Add-TppCertificateAssociation -Path '\ved\policy\my cert' -ApplicationPath '\ved\policy\my capi' -PushCertificate
Add the association and push the certificate

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Add-TppCertificateAssociation/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Add-TppCertificateAssociation.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/API_Reference/r-SDK-POST-Certificates-Associate.php

.NOTES
You must have:
- Write permission to the Certificate object.
- Write or Associate and Delete permission to Application objects that are associated with the certificate

#>
function Add-TppCertificateAssociation {

    [CmdletBinding(SupportsShouldProcess)]
    param (

        [Parameter(Mandatory, ParameterSetName = 'AddByObject', ValueFromPipeline)]
        [TppObject] $InputObject,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'AddByPath')]
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
        [Alias('ProvisionCertificate')]
        [switch] $PushCertificate,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('TPP')

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'Certificates/Associate'
            Body       = @{
                CertificateDN = ''
                ApplicationDN = ''
            }
        }

        if ( $PSBoundParameters.ContainsKey('PushCertificate') ) {
            $params.Body.Add('PushToNew', 'true')
        }
    }

    process {

        if ( $PSBoundParameters.ContainsKey('InputObject') ) {
            $CertificatePath = $InputObject.Path
        }

        $params.Body.CertificateDN = $CertificatePath
        $params.Body.ApplicationDN = @($ApplicationPath)

        if ( $PSCmdlet.ShouldProcess($CertificatePath, 'Add association') ) {
            $null = Invoke-VenafiRestMethod @params
        }
    }
}
