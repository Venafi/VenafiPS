<#
.SYNOPSIS
    Validate module files
.DESCRIPTION
    Validate all module files against the cryptographic hash created when the module was published.
    A file containing all hashes will be downloaded from the GitHub release and compared to the module files currently in use.
.EXAMPLE
    Test-ModuleHash
.INPUTS
    None
.OUTPUTS
    Boolean
#>
function Test-ModuleHash {

    [CmdletBinding()]
    [OutputType([Boolean])]

    param (

    )

    try {
        Invoke-webrequest -Uri "https://github.com/Venafi/VenafiPS/releases/download/v$ModuleVersion/hash.json" -OutFile ('{0}/hash.json' -f $env:TEMP) -UseBasicParsing
        $json = (Get-Content -Path ('{0}/hash.json' -f $env:TEMP) -Raw) | ConvertFrom-Json
    }
    catch {
        Write-Error "Unable to download and process hash.json, $_"
        return $false
    }

    $hashFailed = $json | ForEach-Object {
        Write-Verbose ('Checking {0}' -f $_.File)
        $thisHash = Get-ChildItem -Path ('{0}/../{1}' -f $PSScriptRoot, $_.File) | Get-FileHash -Algorithm SHA256
        if ( $thisHash.Hash -ne $_.Hash ) {
            $thisHash.Path
        }
    }

    if ( $hashFailed ) {
        Write-Error ('hash check failed for the following files: {0}' -f ($hashFailed -join ', '))
    }

    -not $hashFailed
}
