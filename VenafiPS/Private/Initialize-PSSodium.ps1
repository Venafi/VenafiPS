function Initialize-PSSodium {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch] $Force
    )

    # Check if the module is already loaded
    if ( Get-Module PSSodium ) {
        return
    }

    # Check if the module is installed
    if ( -not (Get-Module PSSodium -ListAvailable) ) {
        if ( $Force ) {
            Install-Module -Name PSSodium -Force -RequiredVersion '0.4.2'
        }
        else {
            throw 'The PSSodium module is not installed.  Add -Force for the module to be automatically installed or install from the PowerShell Gallery.'
        }
    }

    try {
        Import-Module PSSodium -Force -ErrorAction Stop
    }
    catch {
        throw "Sodium encryption could not be loaded.  Ensure you are running PowerShell v7+ and if on Windows, install the latest Visual C++ Runtime.  $_"
    }
}
