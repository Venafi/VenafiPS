# Force TLS 1.2 if currently set lower
if ([Net.ServicePointManager]::SecurityProtocol.value__ -lt 3072) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

# the new version will be replaced below during deployment
$script:ModuleVersion = '((NEW_VERSION))'

$script:VcRegions = @{
    'us' = 'https://api.venafi.cloud'
    'eu' = 'https://api.venafi.eu'
}
$Script:VenafiSession = $null
$script:ThreadJobAvailable = ($null -ne (Get-Module -Name Microsoft.PowerShell.ThreadJob -ListAvailable))
$script:DevMode = $script:ModuleVersion -match 'NEW_VERSION'
$script:ParallelImportPath = $PSCommandPath

Export-ModuleMember -Alias * -Variable VenafiSession -Function *

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
                $script:vcApplication = Get-VcData -Type Application | Sort-Object -Property name
                # $script:vcApplication = Get-VcApplication -All | Sort-Object -Property name
            }
            $script:vcApplication | Where-Object { $_.name -like "$wordToComplete*" } | ForEach-Object { "'$($_.name)'" }
        }

        'MachineType' {
            if ( -not $script:vcMachineType ) {
                $script:vcMachineType = Invoke-VenafiRestMethod -UriLeaf 'plugins?pluginType=MACHINE' |
                Select-Object -ExpandProperty machineTypes |
                Select-Object -Property @{'n' = 'machineTypeId'; 'e' = { $_.Id } }, * -ExcludeProperty id |
                Sort-Object -Property machineType
            }
            $script:vcMachineType | Where-Object { $_.name -like "$wordToComplete*" } | ForEach-Object { "'$($_.machineType)'" }
        }

        'IssuingTemplate' {
            if ( -not $script:vcIssuingTemplate ) {
                $script:vcIssuingTemplate = Get-VcIssuingTemplate -All | Sort-Object -Property name
            }
            $script:vcIssuingTemplate | Where-Object { $_.name -like "$wordToComplete*" } | ForEach-Object { "'$($_.name)'" }
        }

        'VSatellite' {
            if ( -not $script:vcVSatellite ) {
                $script:vcVSatellite = Get-VcSatellite -All | Sort-Object -Property name
            }
            $script:vcVSatellite | Where-Object { $_.name -like "$wordToComplete*" } | ForEach-Object { "'$($_.name)'" }
        }

        'Certificate' {
            # there might be a ton of certs so ensure they provide at least 3 characters
            if ( $wordToComplete.Length -ge 3 ) {
                Find-VcCertificate -Name $wordToComplete | ForEach-Object { "'$($_.certificateName)'" }
            }
        }
    }
}

'Application', 'MachineType', 'VSatellite', 'Certificate' | ForEach-Object {
    Register-ArgumentCompleter -CommandName '*-Vc*' -ParameterName $_ -ScriptBlock $vcGenericArgCompleterSb
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
Register-ArgumentCompleter -CommandName '*-Vdc*' -ParameterName 'Path' -ScriptBlock $vdcPathArgCompleterSb

$script:functionConfig = @{
    'Add-VdcAdaptableHash'             = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'restricted=manage,delete'
    }
    'Add-VdcCertificateAssociation'    = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'certificate=manage'
    }
    'Add-VdcEngineFolder'              = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage'
    }
    'Add-VdcTeamMember'                = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage'
    }
    'Add-VdcTeamOwner'                 = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage'
    }
    'Convert-VdcObject'                = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage'
    }
    'ConvertTo-VdcGuid'                = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'any scope'
    }
    'ConvertTo-VdcPath'                = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'any scope'
    }
    'Export-VdcCertificate'            = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'certificate=manage'
    }
    'Find-VdcClient'                   = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'agent=$null'
    }
    'Find-VdcEngine'                   = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=$null'
    }
    'Find-VdcIdentity'                 = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=$null'
    }
    'Find-VdcObject'                   = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=$null'
    }
    'Find-VdcVaultId'                  = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'restricted=$null'
    }
    'Find-VcObject'                    = @{
        'TppVersion'    = ''
        'TppTokenScope' = ''
    }
    'Find-VdcCertificate'              = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'certificate=$null'
    }
    'Get-VdcAttribute'                 = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=$null'
    }
    'Get-VdcClassAttribute'            = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'any scope'
    }
    'Get-VdcCredential'                = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'security=manage'
    }
    'Get-VdcCustomField'               = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'any scope'
    }
    'Get-VdcEngineFolder'              = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage'
    }
    'Get-VdcIdentityAttribute'         = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=$null'
    }
    'Get-VdcObject'                    = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'any scope'
    }
    'Get-VdcPermission'                = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'security=$null'
    }
    'Get-VdcSystemStatus'              = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'any scope'
    }
    'Get-VdcVersion'                   = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'any scope'
    }
    'Get-VdcWorkflowTicket'            = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'any scope'
    }
    'Get-VdcCertificate'               = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'certificate=$null'
    }
    'Get-VdcIdentity'                  = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=$null'
    }
    'Get-VdcTeam'                      = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage'
    }
    'Import-VdcCertificate'            = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'certificate=discover'
    }
    'Import-VcCertificate'             = @{
        'TppVersion'    = ''
        'TppTokenScope' = ''
    }
    'Invoke-VdcCertificateAction'      = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'certificate=manage for Reset, Renew, Push, and Validate.  certificate=revoke for Revoke.  certificate=delete for Delete.'
    }
    'Move-VdcObject'                   = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage'
    }
    'New-VdcCapiApplication'           = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage'
    }
    'New-VdcCertificate'               = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'certificate=manage'
    }
    'New-VdcCustomField'               = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage'
    }
    'New-VdcDevice'                    = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage'
    }
    'New-VdcObject'                    = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage.  If a certificate is provided as an attribute, certificate=manage as well.'
    }
    'New-VdcPolicy'                    = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage'
    }
    'New-VdcToken'                     = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'any scope'
    }
    'New-VcCertificate'                = @{
        'TppVersion'    = ''
        'TppTokenScope' = ''
    }
    'New-VcConnector'                  = @{
        'TppVersion'    = ''
        'TppTokenScope' = ''
    }
    'New-VenafiSession'                = @{
        'TppVersion'    = ''
        'TppTokenScope' = ''
    }
    'New-VenafiTeam'                   = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage'
    }
    'Read-VenafiLog'                   = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'any scope'
    }
    'Remove-VdcCertificate'            = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'certificate=delete.  If using KeepAssociatedApps, configuration=$null,certificate=manage as well.'
    }
    'Remove-VdcCertificateAssociation' = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'certificate=manage.  If using -All, configuration=$null as well.'
    }
    'Remove-VdcClient'                 = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'agent=delete'
    }
    'Remove-VdcEngineFolder'           = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=delete'
    }
    'Remove-VdcObject'                 = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=delete'
    }
    'Remove-VdcPermission'             = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'security=delete'
    }
    'Remove-VenafiTeam'                = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=delete'
    }
    'Remove-VenafiTeamMember'          = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage'
    }
    'Remove-VenafiTeamOwner'           = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage'
    }
    'Rename-VdcObject'                 = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage'
    }
    'Revoke-VdcCertificate'            = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'certificate=revoke'
    }
    'Revoke-VdcGrant'                  = @{
        'TppVersion'    = '22.3'
        'TppTokenScope' = 'admin=delete'
    }
    'Revoke-VdcToken'                  = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'any scope'
    }
    'Search-VdcHistory'                = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'restricted=$null, certificate=$null'
    }
    'Set-VdcAttribute'                 = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=manage'
    }
    'Set-VdcCredential'                = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'security=manage'
    }
    'Set-VdcPermission'                = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'security=manage'
    }
    'Set-VdcWorkflowTicketStatus'      = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'approve with any scope'
    }
    'Test-VdcIdentity'                 = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=$null'
    }
    'Test-VdcObject'                   = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'configuration=$null'
    }
    'Test-VdcToken'                    = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'any scope'
    }
    'Write-VdcLog'                     = @{
        'TppVersion'    = ''
        'TppTokenScope' = 'any scope'
    }
}

# ModuleVersion will get updated during the build and this will not run
# this is only needed during development since all files will be merged into one psm1
if ( $script:DevMode ) {
    $folders = @('Enum', 'Classes', 'Public', 'Private')
    $publicFunction = @()

    foreach ( $folder in $folders) {

        $files = Get-ChildItem -Path "$PSScriptRoot\$folder\*.ps1" -Recurse

        Foreach ( $thisFile in $files ) {
            Try {
                Write-Verbose ('dot sourcing {0}' -f $thisFile.FullName)
                . $thisFile.fullname
                # if ( $folder -eq 'Public' ) {
                Export-ModuleMember -Function $thisFile.Basename
                $publicFunction += $thisFile.BaseName
                # }
            }
            Catch {
                Write-Error ("Failed to import function {0}: {1}" -f $thisFile.fullname, $folder)
            }
        }
    }
}

