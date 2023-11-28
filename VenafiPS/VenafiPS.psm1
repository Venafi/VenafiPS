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
$publicFunction = @()

foreach ( $folder in $folders) {

    $files = Get-ChildItem -Path "$PSScriptRoot\$folder\*.ps1" -Recurse

    Foreach ( $thisFile in $files ) {
        Try {
            Write-Verbose ('dot sourcing {0}' -f $thisFile.FullName)
            . $thisFile.fullname
            if ( $folder -eq 'Public' ) {
                Export-ModuleMember -Function $thisFile.Basename
                $publicFunction += $thisFile.BaseName
            }
        }
        Catch {
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

$vcGenericArgCompleterSb = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $objectType = $parameterName
    if ( $parameterName -eq 'ID' ) {
        # figure out object type based on function name since 'ID' is used in many functions

    }

    switch ($objectType) {
        'Application' {
            if ( -not $script:vcApplication ) {
                $script:vcApplication = Get-VcApplication -All | Sort-Object -Property name
            }
            $script:vcApplication | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object { "'$($_.name)'" }
        }

        'MachineType' {
            if ( -not $script:vcMachineType ) {
                $script:vcMachineType = Invoke-VenafiRestMethod -UriLeaf 'machinetypes' |
                Select-Object -ExpandProperty machineTypes |
                Select-Object -Property @{'n' = 'machineTypeId'; 'e' = { $_.Id } }, * -ExcludeProperty id |
                Sort-Object -Property machineType
            }
            $script:vcMachineType | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object { "'$($_.machineType)'" }
        }

        'IssuingTemplate' {
            if ( -not $script:vcIssuingTemplate ) {
                $script:vcIssuingTemplate = Get-VcIssuingTemplate -All | Sort-Object -Property name
            }
            $script:vcIssuingTemplate | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object { "'$($_.name)'" }
        }

        'VSatellite' {
            if ( -not $script:vcVSatellite ) {
                $script:vcVSatellite = Get-VcSatellite -All | Sort-Object -Property name
            }
            $script:vcVSatellite | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object { "'$($_.name)'" }
        }

        'Certificate' {
            # there might be a ton of certs so ensure they provide at least 3 characters
            if ( $wordToComplete.Length -ge 3 ) {
                Find-VcCertificate -Name $wordToComplete | ForEach-Object { "'$($_.certificateName)'" }
            }
        }
    }
}

# 'Application', 'MachineType', 'IssuingTemplate', 'VSatellite', 'CertificateID' | ForEach-Object {
'Application', 'MachineType', 'VSatellite', 'Certificate' | ForEach-Object {
    Register-ArgumentCompleter -CommandName ($publicFunction | Where-Object { $_ -like '*-Vc*' }) -ParameterName $_ -ScriptBlock $vcGenericArgCompleterSb
}

$vdcPathArgCompleterSb = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    if ( -not $wordToComplete ) {
        # if no word provided, default to \ved\policy
        $wordToComplete = '\VED\Policy\'
    }

    # if the path starts with ' or ", that will come along for the ride so ensure we trim that first
    $fullWord = $wordToComplete.Trim("`"'") | ConvertTo-VdcFullPath
    $leaf = $fullWord.Split('\')[-1]
    $parent = $fullWord.Substring(0, $fullWord.LastIndexOf("\$leaf"))

    # get items in parent folder
    $objs = Find-VdcObject -Path $parent
    $objs | Where-Object { $_.name -like "$leaf*" } | ForEach-Object {
        if ( $_.TypeName -eq 'Policy' ) {
            "'$($_.Path)\"
        }
        else {
            "'$($_.Path)"
        }
    }
}
Register-ArgumentCompleter -CommandName ($publicFunction | Where-Object { $_ -like '*-Vdc*' }) -ParameterName 'Path' -ScriptBlock $vdcPathArgCompleterSb
