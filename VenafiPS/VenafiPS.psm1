<#
.SYNOPSIS
PowerShell module to access the features of Venafi Trust Protection Platform REST API

.DESCRIPTION
Author: Greg Brownstein
#>

# Force TLS 1.2 if currently set lower
if ([Net.ServicePointManager]::SecurityProtocol.value__ -lt 3072) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

$folders = @('Enum', 'Classes', 'Public', 'Private')

foreach ( $folder in $folders) {

    $files = Get-ChildItem -Path "$PSScriptRoot\$folder\*.ps1" -Recurse

    Foreach ( $thisFile in $files ) {
        Try {
            Write-Verbose ('dot sourcing {0}' -f $thisFile.FullName)
            . $thisFile.fullname
            if ( $folder -eq 'Public' ) {
                Export-ModuleMember -Function $thisFile.Basename
            }
        } Catch {
            Write-Error ("Failed to import function {0}: {1}" -f $thisFile.fullname, $folder)
        }
    }
}

$script:CloudUrl = 'https://api.venafi.cloud'
$script:ModuleVersion = '((NEW_VERSION))'
$script:functionConfig = ConvertFrom-Json (Get-Content "$PSScriptRoot/config/functions.json" -Raw)

$Script:VenafiSession = $null
Export-ModuleMember -Variable VenafiSession

Export-ModuleMember -Alias * -Variable VenafiSession

# vaas fields to ensure the values are upper case
$script:vaasValuesToUpper = 'certificateStatus', 'signatureAlgorithm', 'signatureHashAlgorithm', 'encryptionType', 'versionType', 'certificateSource', 'deploymentStatus'
# vaas fields proper case
$script:vaasFields = @(
    'certificateId',
    'applicationIds',
    'companyId',
    'managedCertificateId',
    'fingerprint',
    'certificateName',
    'issuerCertificateIds',
    'certificateStatus',
    'statusModificationUserId',
    'modificationDate',
    'statusModificationDate',
    'validityStart',
    'validityEnd',
    'selfSigned',
    'signatureAlgorithm',
    'signatureHashAlgorithm',
    'encryptionType',
    'keyCurve',
    'subjectKeyIdentifierHash',
    'authorityKeyIdentifierHash',
    'serialNumber',
    'subjectDN',
    'subjectCN',
    'subjectO',
    'subjectST',
    'subjectC',
    'subjectAlternativeNamesByType',
    'subjectAlternativeNameDns',
    'issuerDN',
    'issuerCN',
    'issuerST',
    'issuerL',
    'issuerC',
    'keyUsage',
    'extendedKeyUsage',
    'ocspNoCheck',
    'versionType',
    'activityDate',
    'activityType',
    'activityName',
    'criticality'
)
