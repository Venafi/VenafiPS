<#
.SYNOPSIS
Remove a certificate

.DESCRIPTION
Removes a Certificate object, all associated objects including pending workflow tickets, and the corresponding Secret Store vault information.
You must either be a Master Admin or have Delete permission to the objects and have certificate:delete token scope.

.PARAMETER Path
Path to the certificate to remove

.PARAMETER KeepAssociatedApps
Provide this switch to remove associations prior to certificate removal

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
Path

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
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('DN', 'CertificateDN')]
        [String] $Path,

        [Parameter()]
        [switch] $KeepAssociatedApps,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Delete'
            UriLeaf       = 'placeholder'
        }

        # use in shouldprocess messaging below
        $appsMessage = if ($KeepAssociatedApps) { 'but keep associated apps' } else { 'and associated apps' }
    }

    process {
        $guid = $Path | ConvertTo-TppGuid -VenafiSession $VenafiSession
        $params.UriLeaf = "Certificates/$guid"

        if ( $PSCmdlet.ShouldProcess($Path, "Remove certificate $appsMessage") ) {
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
