<#
.SYNOPSIS
Get the TPP version

.DESCRIPTION
Returns the TPP version

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

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
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Public/Get-TppVersion.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-SystemStatusVersion.php?tocpath=Web%20SDK%7CSystemStatus%20programming%20interface%7C_____9

#>
function Get-TppVersion {

    [CmdletBinding()]

    param (
        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    $VenafiSession.Validate() | Out-Null

    $params = @{
        VenafiSession = $VenafiSession
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