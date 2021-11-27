<#
.SYNOPSIS
Remove a certificate

.DESCRIPTION
Removes a Certificate object, all associated objects including pending workflow tickets, and the corresponding Secret Store vault information.
All associations must be removed for the certificate to be removed.
You must either be a Master Admin or have Delete permission to the Certificate object
and to the Application and Device objects if they are to be deleted automatically with -Force

.PARAMETER InputObject
TppObject which represents a unique object

.PARAMETER Path
Path to the certificate to remove

.PARAMETER Force
Provide this switch to force all associations to be removed prior to certificate removal

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
Remove a certificate

.EXAMPLE
Remove-TppCertificate -Path '\ved\policy\my cert' -force
Remove a certificate and automatically remove all associations

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppCertificate/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Public/Remove-TppCertificate.ps1

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
        [switch] $Force,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate() | Out-Null

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Delete'
            UriLeaf    = 'placeholder'
        }
    }

    process {

        # if ( $PSBoundParameters.ContainsKey('InputObject') ) {
        #     $path = $InputObject.Path
        #     $guid = $InputObject.Guid
        # } else {
        #     $guid = $Path | ConvertTo-TppGuid -VenafiSession $VenafiSession
        # }

        # ensure either there are no associations or the force flag was provided
        $associatedApps = $Path |
        Get-TppAttribute -Attribute "Consumers" -Effective -VenafiSession $VenafiSession |
        Select-Object -ExpandProperty Value

        if ( $associatedApps ) {
            if ( $Force ) {
                $params.Body = @{'ApplicationDN' = @($associatedApps) }
            } else {
                Write-Error ("Path '{0}' has associations and cannot be removed.  Provide -Force to override." -f $Path)
                Return
            }
        }

        $guid = $Path | ConvertTo-TppGuid -VenafiSession $VenafiSession
        $params.UriLeaf = "Certificates/$guid"

        if ( $PSCmdlet.ShouldProcess($Path, 'Remove certificate and all associations') ) {
            Remove-TppCertificateAssociation -Path $Path -All -VenafiSession $VenafiSession -Confirm:$false
            Invoke-TppRestMethod @params | Out-Null
        }
    }
}
