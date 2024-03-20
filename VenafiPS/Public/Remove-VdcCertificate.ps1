function Remove-VdcCertificate {
    <#
    .SYNOPSIS
    Remove a certificate

    .DESCRIPTION
    Removes a Certificate object, all associated objects including pending workflow tickets, and the corresponding Secret Store vault information.
    You must either be a Master Admin or have Delete permission to the objects and have certificate:delete token scope.
    Run this in parallel with PowerShell v7+ when you have a large number to process.

    .PARAMETER Path
    Path to the certificate to remove

    .PARAMETER KeepAssociatedApps
    Provide this switch to remove associations prior to certificate removal

    .PARAMETER ThrottleLimit
    Limit the number of threads when running in parallel; the default is 100.  Applicable to PS v7+ only.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

    .INPUTS
    Path

    .OUTPUTS
    None

    .EXAMPLE
    $cert | Remove-VdcCertificate
    Remove a certificate via pipeline

    .EXAMPLE
    Remove-VdcCertificate -Path '\ved\policy\my cert'
    Remove a certificate and any associated app

    .EXAMPLE
    Remove-VdcCertificate -Path '\ved\policy\my cert' -KeepAssociatedApps
    Remove a certificate and first remove all associations, keeping the apps

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Remove-VdcCertificate/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-VdcCertificate.ps1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-DELETE-Certificates-Guid.php

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [Alias('Remove-TppCertificate')]

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
        [int32] $ThrottleLimit = 100,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VDC'
        $allCerts = [System.Collections.Generic.List[string]]::new()

        # use in shouldprocess messaging below
        $appsMessage = if ($KeepAssociatedApps) { 'but keep associated apps' } else { 'and associated apps' }
    }

    process {
        if ( $PSCmdlet.ShouldProcess($Path, "Remove certificate $appsMessage") ) {
            $allCerts.Add($Path)
        }
    }

    end {

        Invoke-VenafiParallel -InputObject $allCerts -ScriptBlock {
            $guid = $PSItem | ConvertTo-VdcGuid -ErrorAction SilentlyContinue
            if ( -not $guid ) {
                Write-Error "'$PSItem' is not a valid path"
                return
            }

            if ($using:KeepAssociatedApps) {
                $associatedApps = ($PSItem | Get-VdcAttribute -Attribute "Consumers").Consumers
                if ( $associatedApps ) {
                    Remove-VdcCertificateAssociation -Path $PSItem -ApplicationPath $associatedApps -Confirm:$false
                }
            }

            $null = Invoke-VenafiRestMethod -Method Delete -UriLeaf "Certificates/$guid"
        } -ThrottleLimit $ThrottleLimit -ProgressTitle 'Deleting certificates'
    }
}
