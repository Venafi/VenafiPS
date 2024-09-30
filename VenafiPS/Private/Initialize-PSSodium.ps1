function Initialize-PSSodium {
    [CmdletBinding()]
    param (

    )

    # Check if the module is already loaded
    if ( Get-Module PSSodium ) {
        return
    }

    # Check if the module is installed
    if ( -not (Get-Module PSSodium -ListAvailable) ) {
        throw 'The PSSodium module is not installed.  Run `Install-Module -Name PSSodium` to install.'
    }

    try {
        Import-Module PSSodium -Force
    }
    catch {
        throw "Sodium encryption could not be loaded.  Ensure you are running PowerShell v7+ and if on Windows, install the latest Visual C++ Runtime.  $_"
    }
}