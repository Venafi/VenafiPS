<#
.SYNOPSIS
Get the TPP version

.DESCRIPTION
Returns the TPP version

.PARAMETER TppSession
Session object created from New-TppSession method.  The value defaults to the script session object $TppSession.

.INPUTS
none

.OUTPUTS
Version

.EXAMPLE
Get-TppVersion
Get the version

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppVersion/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Get-TppVersion.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-SystemStatusVersion.php?tocpath=Web%20SDK%7CSystemStatus%20programming%20interface%7C_____9

#>
function Get-TppVersion {

    [CmdletBinding()]

    param (
        [Parameter()]
        [TppSession] $TppSession = $Script:TppSession
    )

    $TppSession.Validate()

    $params = @{
        TppSession = $TppSession
        Method     = 'Get'
        UriLeaf    = 'SystemStatus/Version'
    }

    try {
        $ver = Invoke-TppRestMethod @params
        [version] $ver.Version
    }
    catch {
        Throw ("Getting the version failed with the following error: {0}.  This feature was introduced in v18.3." -f $_)
    }
}