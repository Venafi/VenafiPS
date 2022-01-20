<#
.SYNOPSIS
Remove a certificate

.DESCRIPTION
Removes a Certificate object, all associated objects including pending workflow tickets, and the corresponding Secret Store vault information.
You must either be a Master Admin or have Delete permission to the objects and have certificate:delete token scope.

.PARAMETER InputObject
TppObject which represents a unique object

.PARAMETER Path
Path to the certificate to remove

.PARAMETER KeepAssociatedApps
Provide this switch to remove associations prior to certificate removal

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
InputObject or Path

.OUTPUTS
None

.EXAMPLE
$cert | Remove-TppCertificate
Remove a certificate via pipeline

.EXAMPLE
Remove-TppCertificate -Path '\ved\policy\my cert'
Remove a certificate and any associated app

.EXAMPLE
Remove-TppCertificate -Path '\ved\policy\my cert' -KeepAssociatedApps
Remove a certificate and first remove all associations, keeping the apps

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppCertificate/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppCertificate.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-DELETE-Certificates-Guid.php

#>
function Remove-TppCertificate {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
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
        [String] $Path,

        [Parameter()]
        [switch] $KeepAssociatedApps,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('TPP')

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Delete'
            UriLeaf    = 'placeholder'
        }
    }

    process {
        $guid = $Path | ConvertTo-TppGuid -VenafiSession $VenafiSession
        $params.UriLeaf = "Certificates/$guid"

        if ( $PSCmdlet.ShouldProcess($Path, 'Remove certificate and all associations') ) {
            if ($KeepAssociatedApps) {
                $associatedApps = $Path | Get-TppAttribute -Attribute "Consumers" -Effective -VenafiSession $VenafiSession | Select-Object -ExpandProperty Value
                if ( $associatedApps ) {
                    Remove-TppCertificateAssociation -Path $Path -ApplicationPath $associatedApps -VenafiSession $VenafiSession -Confirm:$false
                }
            }

            Invoke-VenafiRestMethod @params | Out-Null
        }
    }
}
