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
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Remove-TppCertificate.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-DELETE-Certificates-Guid.php?tocpath=Web%20SDK%7CCertificates%20programming%20interface%7C_____9

#>
function Remove-TppCertificate {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'ByObject', ValueFromPipeline)]
        [TppObject] $InputObject,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'ByPath')]
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

        if ( $PSBoundParameters.ContainsKey('InputObject') ) {
            $path = $InputObject.Path
            $guid = $InputObject.Guid
        } else {
            $guid = $Path | ConvertTo-TppGuid -VenafiSession $VenafiSession
        }

        # ensure either there are no associations or the force flag was provided
        $associatedApps = $Guid |
        Get-TppAttribute -Attribute "Consumers" -EffectivePolicy -VenafiSession $VenafiSession |
        Select-Object -ExpandProperty Value

        if ( $associatedApps ) {
            if ( $Force ) {
                $params.Body = @{'ApplicationDN' = @($associatedApps) }
            } else {
                Write-Error ("Path '{0}' has associations and cannot be removed.  Provide -Force to override." -f $Path)
                Return
            }
        }

        $params.UriLeaf = "Certificates/$Guid"

        if ( $PSCmdlet.ShouldProcess($Path, 'Remove certificate and all associations') ) {
            Remove-TppCertificateAssociation -Path $Path -All -VenafiSession $VenafiSession
            Invoke-TppRestMethod @params
        }
    }
}
