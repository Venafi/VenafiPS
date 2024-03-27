function Initialize-PSSodium {
    [CmdletBinding()]
    param (

    )

    if ( Get-Module PSSodium ) {
        return
    }

    try {
        Import-Module "$PSScriptRoot/../import/PSSodium/PSSodium.psd1" -Force
    }
    catch {
        throw "Sodium encryption could not be loaded.  Ensure you are running PowerShell v7+ and if on Windows, install the latest Visual C++ Runtime.  $_"
    }
}