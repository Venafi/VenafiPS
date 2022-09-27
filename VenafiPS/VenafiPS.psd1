#
# Module manifest for module 'VenafiPS'
#
# Generated by: Venafi
#
# Generated on: 09/20/2022
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'VenafiPS.psm1'

# Version number of this module.
ModuleVersion = '5.0.0'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = 'a1c0ef7c-8499-4ac4-9659-52ca91258d13'

# Author of this module
Author = 'Venafi'

# Company or vendor of this module
CompanyName = 'Venafi'

# Copyright statement for this module
Copyright = '(c) Venafi. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Automate your Venafi Trust Protection Platform and Venafi as a Service platforms!'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '5.1'

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# ClrVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
ScriptsToProcess = 'Classes\TppObject.ps1', 'Classes\TppPermission.ps1',
               'Classes\VenafiSession.ps1', 'Enum\TppCertificateStage.ps1',
               'Enum\TppCodeSignProjectStatus.ps1', 'Enum\TppCodeSignResult.ps1',
               'Enum\TppConfigResult.ps1', 'Enum\TppEventSeverity.ps1',
               'Enum\TppIdentityType.ps1', 'Enum\TppManagementType.ps1',
               'Enum\TppMetadataResult.ps1', 'Enum\TppWorkflowResult.ps1'

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Add-TppCertificateAssociation', 'Convert-TppObject',
               'ConvertTo-TppGuid', 'ConvertTo-TppPath', 'Export-VenafiCertificate',
               'Find-VenafiCertificate', 'Find-TppClient',
               'Find-TppCodeSignEnvironment', 'Find-TppCodeSignProject',
               'Find-TppCodeSignTemplate', 'Find-TppIdentity', 'Find-TppObject',
               'Find-TppVaultId', 'Get-TppAttribute', 'Get-TppClassAttribute',
               'Get-TppCodeSignConfig', 'Get-TppCodeSignEnvironment',
               'Get-TppCodeSignProject', 'Get-TppCredential', 'Get-TppCustomField',
               'Get-VenafiIdentity', 'Get-TppIdentityAttribute', 'Get-TppObject',
               'Get-TppPermission', 'Get-TppSystemStatus', 'Get-TppVersion',
               'Get-TppWorkflowTicket', 'Get-VaasApplication',
               'Get-VenafiCertificate', 'Import-TppCertificate',
               'Invoke-TppCertificatePush', 'Invoke-TppCertificateRenewal',
               'Invoke-VenafiCertificateAction', 'Invoke-VenafiRestMethod',
               'Move-TppObject', 'New-TppCapiApplication', 'New-TppCertificate',
               'New-TppCodeSignProject', 'New-TppCustomField', 'New-TppDevice',
               'New-TppObject', 'New-TppPolicy', 'New-TppToken', 'New-VenafiSession',
               'Read-VenafiLog', 'Remove-TppCertificate',
               'Remove-TppCertificateAssociation', 'Remove-TppClient',
               'Remove-TppCodeSignEnvironment', 'Remove-TppCodeSignProject',
               'Remove-TppPermission', 'Rename-TppObject', 'Revoke-TppCertificate',
               'Revoke-TppToken', 'Set-TppAttribute', 'Set-TppCodeSignProjectStatus',
               'Set-TppCredential', 'Set-TppPermission',
               'Set-TppWorkflowTicketStatus', 'Test-ModuleHash', 'Test-TppIdentity',
               'Test-TppObject', 'Test-TppToken', 'Write-TppLog', 'Get-VenafiTeam',
               'Remove-VenafiTeam', 'Add-VenafiTeamMember', 'Add-VenafiTeamOwner',
               'Remove-VenafiTeamMember', 'Remove-VenafiTeamOwner', 'New-VenafiTeam',
               'Search-TppHistory', 'Get-VaasIssuingTemplate', 'New-VaasApplication',
               'Import-VaasCertificate', 'Get-VaasConnector', 'Remove-VaasConnector',
               'New-VaasConnector', 'Find-TppEngine', 'Get-TppEngineFolder',
               'Remove-TppEngineFolder', 'Add-TppEngineFolder', 'Revoke-TppGrant', 'New-VaasCertificate'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = 'VenafiSession'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = 'fto', 'itcr', 'Find-TppCertificate', 'Get-TppIdentity', 'Read-TppLog',
               'Invoke-TppRestMethod', 'Get-TppCertificate',
               'Get-TppCertificateDetail', 'Find-VaasCertificate',
               'Export-TppCertificate', 'Export-VaasCertificate'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'Venafi','TPP','TrustProtectionPlatform','API','devsecops','VaaS'

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/Venafi/VenafiPS/blob/main/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/Venafi/VenafiPS'

        # A URL to an icon representing this module.
        IconUri = 'https://raw.githubusercontent.com/Venafi/VenafiPS/main/images/venafi_logo.png'

        # ReleaseNotes of this module
        ReleaseNotes = 'https://github.com/Venafi/VenafiPS/blob/main/CHANGELOG.md'

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# HelpInfo URI of this module
HelpInfoURI = 'http://venafips.readthedocs.io/'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

