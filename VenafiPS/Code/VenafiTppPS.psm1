<#
.SYNOPSIS
PowerShell module to access the features of Venafi Trust Protection Platform REST API

.DESCRIPTION
Author: Greg Brownstein
#>

$folders = @('Enum', 'Classes', 'Public', 'Private')

foreach ( $folder in $folders) {

    $files = Get-ChildItem -Path "$PSScriptRoot\$folder\*.ps1" -Recurse

    Foreach ( $thisFile in $files ) {
        Try {
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

$Script:TppSupportedVersion = ConvertFrom-Json (Get-Content "$PSScriptRoot\Config\SupportedVersion.json" -Raw)
Export-ModuleMember -Variable TppSupportedVersion

$Script:TppSession = New-Object 'TppSession'
Export-ModuleMember -Variable TppSession

$aliases = @{
    'ConvertTo-TppDN'        = 'ConvertTo-TppPath'
    'Get-TppWorkflowDetail'  = 'Get-TppWorkflowTicket'
    'Get-TppIdentity'        = 'Find-TppIdentity'
    'Restore-TppCertificate' = 'Invoke-TppCertificateRenewal'
    'Get-TppLog'             = 'Read-TppLog'
    'fto'                    = 'Find-TppObject'
    'ftc'                    = 'Find-TppCertificate'
    'itcr'                   = 'Invoke-TppCertificateRenewal'
    'New-TppSession'         = 'New-VenafiSession'
}
$aliases.GetEnumerator() | ForEach-Object {
    Set-Alias -Name $_.Key -Value $_.Value
}
Export-ModuleMember -Alias *

# Force TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
