function ConvertTo-TppCodeSignProject {
    <#
    .SYNOPSIS
    Convert code sign project to something powershell friendly

    .DESCRIPTION
    Convert code sign project to something powershell friendly

    .PARAMETER InputObject
    Code sign project object

    .INPUTS
    InputObject

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    $envObj | ConvertTo-TppCodeSignProject

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
        $InputObject | Select-Object -Property `
        @{
            n = 'Name'
            e = { ($_.DN).Split('\')[-1] }
        },
        @{
            n = 'Path'
            e = { $_.DN }
        },
        @{
            n = 'TypeName'
            e = { 'Code Signing Project' }
        },
        @{
            n = 'Guid'
            e = { [guid] $_.Guid }
        },
        @{
            n = 'Status'
            e = { [enum]::GetName([TppCodeSignProjectStatus], $_.Status) }
        },
        @{
            n = 'ApplicationPath'
            e = { @($_.ApplicationDNs.Items) }
        },
        @{
            n = 'Application'
            e = { @($_.Applications) }
        },
        @{
            n = 'Auditor'
            e = { @($_.Auditors.Items) }
        },
        @{
            n = 'Collection'
            e = { @($_.Collections) }
        },
        @{
            n = 'KeyUseApprover'
            e = { @($_.KeyUseApprovers.Items) }
        },
        @{
            n = 'KeyUser'
            e = { @($_.KeyUsers.Items) }
        },
        @{
            n = 'Owner'
            e = { @($_.Owners.Items) }
        },
        @{
            n = 'CertificateEnvironment'
            e = { $_.CertificateEnvironments | ConvertTo-TppCodeSignEnvironment }
        }, CreatedOn, Description, Id
    }
}