function ConvertTo-TppCodeSignEnvironment {
    <#
    .SYNOPSIS
    Convert code sign certificate environment to something powershell friendly

    .DESCRIPTION
    Convert code sign certificate environment to something powershell friendly

    .PARAMETER InputObject
    Code sign certificate environment object

    .INPUTS
    InputObject

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    $envObj | ConvertTo-TppCodeSignEnvironment

    #>

    [CmdletBinding()]

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject] $InputObject
    )

    begin {
    }

    process {
        $InputObject | Select-Object  -Property `
        @{
            n = 'Name'
            e = { ($_.DN).Split('\')[-1] }
        },
        @{
            n = 'Path'
            e = {
                $_.Dn
            }
        },
        @{
            n = 'TypeName'
            e = { $_.Type }
        },
        @{
            n = 'Guid'
            e = { [guid] $_.Guid }
        },
        @{
            n = 'OrganizationalUnit'
            e = { $_.OrganizationalUnit.Value }
        },
        @{
            n = 'IPAddressRestriction'
            e = { $_.IPAddressRestriction.Items }
        },
        @{
            n = 'KeyUseFlowPath'
            e = { $_.KeyUseFlowDN }
        },
        @{
            n = 'TemplatePath'
            e = { $_.TemplateDN }
        },
        @{
            n = 'CertificateAuthorityPath'
            e = { $_.CertificateAuthorityDN.Value }
        },
        @{
            n = 'CertificatePath'
            e = { $_.CertificateDN }
        },
        @{
            n = 'CertificateSubject'
            e = { $_.CertificateSubject.Value }
        },
        @{
            n = 'City'
            e = { $_.City.Value }
        },
        @{
            n = 'KeyAlgorithm'
            e = { $_.KeyAlgorithm.Value }
        },
        @{
            n = 'KeyStorageLocation'
            e = { $_.KeyStorageLocation.Value }
        },
        @{
            n = 'Organization'
            e = { $_.Organization.Value }
        },
        @{
            n = 'OrganizationUnit'
            e = { $_.OrganizationUnit.Value }
        },
        @{
            n = 'SANEmail'
            e = { $_.SANEmail.Value }
        },
        @{
            n = 'State'
            e = { $_.State.Value }
        },
        @{
            n = 'Country'
            e = { $_.Country.Value }
        }, AllowUserKeyImport, Disabled, Id, CertificateStatus, CertificateStatusText, CertificateTemplate, SynchronizeChain

    }
}