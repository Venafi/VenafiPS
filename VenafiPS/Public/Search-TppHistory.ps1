function Search-TppHistory {

    <#
    .SYNOPSIS
    Search TPP history for items with specific attributes

    .DESCRIPTION
    Items in the secret store matching the key/value provided will be found and their details returned with their associated 'current' item.
    As this function may return details on many items, optional parallel processing has been implemented.
    Be sure to use PowerShell Core, v7 or greater, to take advantage.

    .PARAMETER Path
    Starting path to associated current items to limit the search.
    The default is \VED\Policy.

    .PARAMETER Attribute
    Name and value to search.
    See https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Secretstore-lookupbyassociation.php for more details.
    Note, ValidFrom will perform a greater than or equal comparison and ValidTo will perform a less than or equal comparison.
    Currently, one 1 name/value pair can be used.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    None

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Search-TppHistory -Attribute @{'ValidTo' = (Get-Date)}

    Name     : test.gdb.com
    TypeName : X509 Server Certificate
    Path     : \VED\Policy\Certificates\test.gdb.com
    History  : {@{AIACAIssuerURL=System.Object[]; AIAKeyIdentifier=F2E970BA11A64D616E78592911D7CC; C=US;
               CDPURI=0::False; EnhancedKeyUsage=Server Authentication(1.3.6.1.5.5.7.3.1).........}}

    Find historical items that are still active

    .EXAMPLE
    Search-TppHistory -Attribute @{'ValidTo' = (Get-Date)} -Path '\ved\policy\certs'

    Find historical items that are still active and the current item starts with a specific path

    #>

    [CmdletBinding()]

    param (
        [Parameter()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                } else {
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

    # we have vault ids, now get path to current item
    $owners = if ($PSVersionTable.PSVersion.Major -lt 6) {
        $activeVaultId | ForEach-Object {
            Invoke-VenafiRestMethod -UriLeaf "secretstore/ownerlookup" -Body @{'Namespace' = 'config'; 'VaultID' = $_ } -Method Post -VenafiSession $VenafiSession
        }
    } else {
        $activeVaultId | ForEach-Object -ThrottleLimit 100 -Parallel {
            Import-Module VenafiPS
            New-VenafiSession -Server ($using:VenafiSession).Server -AccessToken ($using:VenafiSession).Token.AccessToken
            Invoke-VenafiRestMethod -UriLeaf "secretstore/ownerlookup" -Body @{'Namespace' = 'config'; 'VaultID' = $_ } -Method Post
        }
    }

    # limit current certs to the path provided
    $certs = $owners.owners.where{ $_ -like "$Path*" } | Select-Object -Unique

    Write-Warning ('Getting details on {0} current items' -f $certs.Count)

    # scriptblock which will be used for PS v5 and core
    $sbGeneric = {

        $thisDetailedCert = Get-VenafiCertificate -Path $_ -IncludePreviousVersions -VenafiSession $VenafiSession -ErrorAction SilentlyContinue
        if ( -not $thisDetailedCert ) { return }

        $history = $thisDetailedCert.PreviousVersions | Where-Object { $_.VaultId -in $activeVaultId } | Select-Object -ExpandProperty CertificateDetails
        if ( $history ) {
            $thisDetailedCert | Select-Object Name, TypeName, Path,
            @{
                'n' = 'History'
                'e' = { $history }
            }
        }
    }

    # needed for parallel in ps7
    $sbGenericString = $sbGeneric.ToString()

    if ($PSVersionTable.PSVersion.Major -lt 6) {
        $certs | ForEach-Object -Process $sbGeneric
    } else {
        $certs | ForEach-Object -ThrottleLimit 100 -Parallel {
            Import-Module VenafiPS
            $VenafiSession = New-VenafiSession -Server ($using:VenafiSession).Server -AccessToken ($using:VenafiSession).Token.AccessToken -PassThru
            $activeVaultId = $using:activeVaultId

            Invoke-Expression $using:sbGenericString
        }
    }
}