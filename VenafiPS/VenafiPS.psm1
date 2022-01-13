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
$script:ModuleVersion = '4.0.1'

$Script:VenafiSession = New-Object 'VenafiSession'
Export-ModuleMember -Variable VenafiSession

$aliases = @{
    'ConvertTo-TppDN'          = 'ConvertTo-TppPath'
    'Get-TppWorkflowDetail'    = 'Get-TppWorkflowTicket'
    'Get-TppIdentity'          = 'Find-TppIdentity'
    'Restore-TppCertificate'   = 'Invoke-TppCertificateRenewal'
    'Get-TppLog'               = 'Read-TppLog'
    'fto'                      = 'Find-TppObject'
    'ftc'                      = 'Find-TppCertificate'
    'itcr'                     = 'Invoke-TppCertificateRenewal'
    'New-TppSession'           = 'New-VenafiSession'
    'Invoke-TppRestMethod'     = 'Invoke-VenafiRestMethod'
    'Get-TppCertificate'       = 'Export-VenafiCertificate'
    'Get-TppCertificateDetail' = 'Get-VenafiCertificate'
}
$aliases.GetEnumerator() | ForEach-Object {
    Set-Alias -Name $_.Key -Value $_.Value
}
Export-ModuleMember -Alias *

# Force TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

