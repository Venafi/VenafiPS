<#
.SYNOPSIS
Remove certificate associations

.DESCRIPTION
Dissociates one or more Application objects from an existing certificate.
Optionally, you can remove the application objects and corresponding orphaned device objects that no longer have any applications

.PARAMETER InputObject
TppObject which represents a unique object

.PARAMETER Path
Path to the certificate

.PARAMETER ApplicationPath
List of application object paths to dissociate

.PARAMETER OrphanCleanup
Delete the Application object after dissociating it. Only delete the corresponding Device DN when it has no child objects.
Otherwise retain the Device DN and its children.

.PARAMETER All
Remove all associated application objects

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
Remove-TppCertificateAssociation -Path '\ved\policy\my cert' -ApplicationPath '\ved\policy\my capi'
Remove a single application object association

.EXAMPLE
Remove-TppCertificateAssociation -Path '\ved\policy\my cert' -ApplicationPath '\ved\policy\my capi' -OrphanCleanup
Disassociate and delete the application object

.EXAMPLE
Remove-TppCertificateAssociation -Path '\ved\policy\my cert' -RemoveAll
Remove all certificate associations

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppCertificateAssociation/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppCertificateAssociation.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Dissociate.php

.NOTES
You must have:
- Write permission to the Certificate object.
- Write or Associate permission to Application objects that are associated with the certificate
- Delete permission to Application and device objects when specifying -OrphanCleanup

#>
function Remove-TppCertificateAssociation {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'RemoveOneByObject', ValueFromPipeline)]
        [Parameter(Mandatory, ParameterSetName = 'RemoveAllByObject', ValueFromPipeline)]
        [TppObject] $InputObject,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'RemoveOneByPath')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'RemoveAllByPath')]
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

        [Parameter(Mandatory, ParameterSetName = 'RemoveOneByObject')]
        [Parameter(Mandatory, ParameterSetName = 'RemoveOneByPath')]
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
        [switch] $OrphanCleanup,

        [Parameter(Mandatory, ParameterSetName = 'RemoveAllByObject')]
        [Parameter(Mandatory, ParameterSetName = 'RemoveAllByPath')]
        [Alias('RemoveAll')]
        [switch] $All,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'Certificates/Dissociate'
            Body       = @{ }
        }
    }

    process {

        if ( $PSBoundParameters.ContainsKey('InputObject') ) {
            $path = $InputObject.Path
        }

        # foreach ( $Path in $Path ) {
        $shouldProcessAction = "Remove associations"

        if ( -not ($Path | Test-TppObject -ExistOnly -VenafiSession $VenafiSession) ) {
            Write-Error ("Certificate path {0} does not exist" -f $Path)
            Continue
        }

        $params.Body = @{
            'CertificateDN' = $Path
        }

        if ( $PSBoundParameters.ContainsKey('OrphanCleanup') ) {
            $params.Body.DeleteOrphans = $true
            $shouldProcessAction += ' AND ORPHANS'
        }

        Switch -Wildcard ($PsCmdlet.ParameterSetName)	{
            'RemoveOne*' {
                $params.Body.ApplicationDN = @($ApplicationPath)
            }

            'RemoveAll*' {
                $associatedApps = $Path |
                Get-TppAttribute -Attribute "Consumers" -EffectivePolicy -VenafiSession $VenafiSession |
                Select-Object -ExpandProperty Value

                if ( $associatedApps ) {
                    $params.Body.ApplicationDN = @($associatedApps)
                } else {
                    # no associations to process, no need to continue
                    Write-Warning "No associations for path '$Path'"
                    Return
                }
            }
        }

        try {
            if ( $PSCmdlet.ShouldProcess($Path, $shouldProcessAction) ) {
                $null = Invoke-VenafiRestMethod @params
            }
        } catch {
            $myError = $_.ToString() | ConvertFrom-Json
            Write-Error ('Error removing associations from certificate {0}: {1}' -f $Path, $myError.Error)
        }
    }
}
