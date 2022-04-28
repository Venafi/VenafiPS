
<#
.SYNOPSIS
Find historical certificates in TPP

.DESCRIPTION
Certificates in the secret store matching the key/value provided will be found and their details returned with their associated 'current' certificate.
As this function may return details on many certificates, optional parallel processing has been implemented.
Be sure to use PowerShell Core, v7 or greater, to take advantage.

.PARAMETER Path
Starting path to associated current certificates to limit the search

.PARAMETER Attribute
Name and value to search.
See https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Secretstore-lookupbyassociation.php for more details.
Note, ValidFrom will perform a greater than or equal comparison and ValidTo will perform a less than or equal comparison.
Currently, one 1 name/value pair can be used.

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TppServer must also be set.

.INPUTS
None

.OUTPUTS
PSCustomObject with the following properties:
    Name
    TypeName
    Path
    History

.EXAMPLE
Get-TppHistoricalCertificate -Attribute @{'ValidTo' = (Get-Date)}
Find historical certificates that are still active

.EXAMPLE
Get-TppHistoricalCertificate -Attribute @{'ValidTo' = (Get-Date)} -Path '\ved\policy\certs'
Find historical certificates that are still active and the current certificate starts with a specific path

#>

function Find-TppHistoricalCertificate {

    [CmdletBinding()]

    param (
        [Parameter()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            }
        )]
        [string] $Path = '\VED\Policy',

        [Parameter(Mandatory)]
        [hashtable] $Attribute,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP' -AuthType 'Token'

    $activeVaultId = Find-TppVaultId -Attribute $Attribute -VenafiSession $VenafiSession
    if ( -not $activeVaultId ) {
        return
    }

    Write-Warning ('Found {0} matching vault items' -f $activeVaultId.Count)

    $owners = if ($PSVersionTable.PSVersion.Major -lt 6) {
        $activeVaultId | ForEach-Object {
            Invoke-VenafiRestMethod -UriLeaf "secretstore/ownerlookup" -Body @{'Namespace' = 'config'; 'VaultID' = $_ } -Method Post -VenafiSession $VenafiSession
        }
    }
    else {
        $activeVaultId | ForEach-Object -ThrottleLimit 100 -Parallel {
            Import-Module VenafiPS
            New-VenafiSession -Server ($using:VenafiSession).Server -AccessToken ($using:VenafiSession).Token.AccessToken
            Invoke-VenafiRestMethod -UriLeaf "secretstore/ownerlookup" -Body @{'Namespace' = 'config'; 'VaultID' = $_ } -Method Post
        }
    }

    # limit current certs to the path provided
    $certs = $owners.owners.where{ $_ -like "$Path*" } | Select-Object -Unique

    Write-Warning ('Getting details on {0} current certificates' -f $certs.Count)

    $sbGeneric = {

        $thisDetailedCert = Get-VenafiCertificate -Path $_ -IncludePreviousVersions -VenafiSession $VenafiSession -ErrorAction SilentlyContinue
        if ( -not $thisDetailedCert -or $thisDetailedCert.TypeName -notlike '*certificate*' ) { return }

        $history = $thisDetailedCert.PreviousVersions | Where-Object { $_.VaultId -in $activeVaultId } | Select-Object -ExpandProperty CertificateDetails
        if ( $history ) {
            $thisDetailedCert | Select-Object Name, TypeName, Path,
            @{
                'n' = 'History'
                'e' = { $history }
            }
        }
    }

    # needed for ps7
    $sbGenericString = $sbGeneric.ToString()

    if ($PSVersionTable.PSVersion.Major -lt 6) {
        $certs | ForEach-Object -Process $sbGeneric
    }
    else {
        $certs | ForEach-Object -ThrottleLimit 100 -Parallel {
            Import-Module VenafiPS
            $VenafiSession = New-VenafiSession -Server ($using:VenafiSession).Server -AccessToken ($using:VenafiSession).Token.AccessToken -PassThru
            $activeVaultId = $using:activeVaultId

            Invoke-Expression $using:sbGenericString
        }
    }
}