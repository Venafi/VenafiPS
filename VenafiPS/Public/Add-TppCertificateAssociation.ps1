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
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

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
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

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
