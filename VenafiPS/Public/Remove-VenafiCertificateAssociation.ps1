function Remove-VenafiCertificateAssociation {
    <#
    .SYNOPSIS
    Remove certificate associations

    .DESCRIPTION
    Dissociates one or more Application objects from an existing certificate.
    Optionally, you can remove the application objects and corresponding orphaned device objects that no longer have any applications

    .PARAMETER CertificateID
    TPP Path or VaaS ID to the certificate

    .PARAMETER ApplicationID
    List of applications to dissociate.  Path(s) for TPP, ID or name for TLSPC.

    .PARAMETER OrphanCleanup
    Delete the Application object after dissociating it. Only delete the corresponding Device DN when it has no child objects.
    Otherwise retain the Device DN and its children.
    TPP only.

    .PARAMETER All
    Dissociate from all applications

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    CertificateID

    .OUTPUTS
    None

    .EXAMPLE
    Remove-VenafiCertificateAssociation -CertificateID '\ved\policy\my cert' -ApplicationID '\ved\policy\my capi'

    Remove a single application object association on TPP

    .EXAMPLE
    Remove-VenafiCertificateAssociation -CertificateID '\ved\policy\my cert' -ApplicationID '\ved\policy\my capi' -OrphanCleanup

    Disassociate and delete the application object on TPP

    .EXAMPLE
    Remove-VenafiCertificateAssociation -CertificateID '\ved\policy\my cert' -All

    Remove all certificate associations on TPP

    .EXAMPLE
    Remove-VenafiCertificateAssociation -CertificateID '8e61673c-d4f2-4aba-a321-db82f460145a' -ApplicationID 'MyApp'

    Remove a single application association on VaaS

    .EXAMPLE
    Remove-VenafiCertificateAssociation -CertificateID '8e61673c-d4f2-4aba-a321-db82f460145a' -All

    Remove a single application association on VaaS

    .EXAMPLE
    Find-VenafiCertificate | Remove-VenafiCertificateAssociation -ApplicationID 'BadApp'

    Remove all certificate associations with certain applications

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Remove-VenafiCertificateAssociation/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-VenafiCertificateAssociation.ps1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Dissociate.php

    .NOTES
    For TPP you must have:
    - Write permission to the Certificate object.
    - Write or Associate permission to Application objects that are associated with the certificate
    - Delete permission to Application and device objects when specifying -OrphanCleanup

    #>

    [CmdletBinding(DefaultParameterSetName = 'RemoveOne', SupportsShouldProcess, ConfirmImpact = 'High')]
    [Alias('Remove-TppCertificateAssociation')]

    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('Path')]
        [String] $CertificateID,

        [Parameter(Mandatory, ParameterSetName = 'RemoveOne')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('ApplicationPath')]
        [String[]] $ApplicationID,

        [Parameter()]
        [switch] $OrphanCleanup,

        [Parameter(Mandatory, ParameterSetName = 'RemoveAll')]
        [Alias('RemoveAll')]
        [switch] $All,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        $platform = Test-VenafiSession -VenafiSession $VenafiSession -PassThru

        if ( $platform -eq 'VaaS' ) {

            $newAppID = if ( $All ) {
                Get-VaasApplication -All -VenafiSession $VenafiSession | Select-Object -ExpandProperty applicationId
            }
            else {
                foreach ($id in $ApplicationID) {
                    if ( Test-IsGuide($id) ) {
                        $id
                    }
                    else {
                        Get-VaasApplication -ID $id -VenafiSession $VenafiSession | Select-Object -ExpandProperty applicationId
                    }
                }
            }

            $params = @{
                VenafiSession = $VenafiSession
                Method        = 'Patch'
                UriRoot       = 'outagedetection/v1'
                UriLeaf       = 'applications/certificates'
                Body          = @{
                    action                 = 'DELETE'
                    targetedApplicationIds = @($newAppID)
                }
            }

            $allCerts = [System.Collections.Generic.List[object]]::new()
        }
        else {
            $params = @{
                VenafiSession = $VenafiSession
                Method        = 'Post'
                UriLeaf       = 'Certificates/Dissociate'
                Body          = @{ }
            }
        }
    }

    process {

        if ( $platform -eq 'VaaS' ) {

            $allCerts.Add($CertificateID)
        }
        else {

            # foreach ( $Path in $Path ) {
            $shouldProcessAction = "Remove associations"

            if ( -not ($CertificateID | Test-TppObject -ExistOnly -VenafiSession $VenafiSession) ) {
                Write-Error ("Certificate path {0} does not exist" -f $CertificateID)
                Continue
            }

            $params.Body = @{
                'CertificateDN' = $CertificateID
            }

            if ( $PSBoundParameters.ContainsKey('OrphanCleanup') ) {
                $params.Body.DeleteOrphans = $true
                $shouldProcessAction += ' AND ORPHANS'
            }

            Switch -Wildcard ($PsCmdlet.ParameterSetName)	{
                'RemoveOne*' {
                    $params.Body.ApplicationDN = @($ApplicationID)
                }

                'RemoveAll*' {
                    $associatedApps = $CertificateID |
                    Get-TppAttribute -Attribute "Consumers" -VenafiSession $VenafiSession | Select-Object -ExpandProperty Consumers

                    if ( $associatedApps ) {
                        $params.Body.ApplicationDN = @($associatedApps)
                    }
                    else {
                        # no associations to process, no need to continue
                        Write-Warning "No associations for path '$Path'"
                        Return
                    }
                }
            }

            try {
                if ( $PSCmdlet.ShouldProcess($CertificateID, $shouldProcessAction) ) {
                    $null = Invoke-VenafiRestMethod @params
                }
            }
            catch {
                $myError = $_.ToString() | ConvertFrom-Json
                Write-Error ('Error removing associations from certificate {0}: {1}' -f $Path, $myError.Error)
            }
        }
    }

    end {
        if ( $platform -eq 'VaaS' ) {
            $params.Body.certificateIds = $allCerts

            $null = Invoke-VenafiRestMethod @params
        }
    }
}
