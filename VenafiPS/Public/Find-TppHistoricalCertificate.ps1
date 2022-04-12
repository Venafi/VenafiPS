
<#
.SYNOPSIS
Find active/valid historical certificates in TPP

.DESCRIPTION
Find active/valid historical certificates in TPP.
Create a new session with New-VenafiSession before executing this script.

.PARAMETER Path
Path to start the search for certificates

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
None

.OUTPUTS
PSCustomObject with the following properties:
    Path - path to current cert
    ActiveHistory - list of valid historical certs.  Properties VaultId, Serial, and ValidTo

.EXAMPLE
$certs = & Get-TppActiveHistoricalCertificate.ps1 -Path '\ved\policy\mycerts'
Find all active historical certs starting at the path provided and searching recursively

#>

function Find-TppHistoricalCertificate {

    [CmdletBinding()]

    param (
        [Parameter()]
        [String] $Path = '\ved\policy',

        [Parameter()]
        [switch] $Recursive,

        [Parameter(Mandatory)]
        [hashtable] $Attribute,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP' -AuthType 'Token'

    $findParams = @{
        Path              = $Path
        First             = 5000
        IncludeTotalCount = $true
        VenafiSession     = $VenafiSession
    }

    if ( $Recursive ) {
        $findParams.Add('Recursive', $true)
    }

    $activeVaultId = Find-TppVaultId -Attribute @{'ValidTo' = (get-date) }
    $owners = $activeVaultId | foreach-object { Invoke-VenafiRestMethod -urileaf "secretstore/ownerlookup" -body @{'Namespace' = 'config'; 'VaultID' = $_ } -method post -Verbose }
    # $owners.owners | select -Unique

    $certs = Find-VenafiCertificate @findParams

    $sbGeneric = {

        $thisCert = $_

        $thisDetailedCert = Get-VenafiCertificate -Path $thisCert.Path -IncludePreviousVersions -VenafiSession $VenafiSession

        if ( $thisDetailedCert.PreviousVersions.Count -gt 0 ) {
            $historical = foreach ($prev in $thisDetailedCert.PreviousVersions) {

                $Attribute.GetEnumerator() | ForEach-Object {

                    switch ($_.Value.GetType().Name) {
                        'DateTime' {
                            if ( $prev.CertificateDetails.($_.Key) -gt $_.Value) {
                                $aMatch = $true
                            }
                        }

                        'String' {
                            $newOperand.Add('value', $thisItem[2])
                        }

                        Default {
                            # we have a list
                            $newOperand.Add('values', $thisItem[2])
                        }
                    }
                }

                if ( $aMatch ) {
                    [pscustomobject]@{
                        VaultId = $prev.VaultId
                        Serial  = $prev.CertificateDetails.Serial
                        ValidTo = $prev.CertificateDetails.ValidTo
                    }
                }
            }

            if ( $historical ) {
                [pscustomobject]@{
                    Path       = $thisDetailedCert.Path
                    Historical = $historical
                }
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
            # Import-Module VenafiPS
            import-module /Users/greg.brownstein/code/VenafiPS/VenafiPS/VenafiPS.psd1 -force
            $VenafiSession = New-VenafiSession -Server ($using:VenafiSession).Server -AccessToken ($using:VenafiSession).Token.AccessToken -PassThru

            Invoke-Expression $using:sbGenericString
        }
    }
}