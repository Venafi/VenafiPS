<#
.SYNOPSIS
Get the TPP system status

.DESCRIPTION
Returns service module statuses for Trust Protection Platform, Log Server, and Trust Protection Platform services that run on Microsoft Internet Information Services (IIS)

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
none

.OUTPUTS
PSCustomObject

.EXAMPLE
Get-TppSystemStatus
Get the status

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppSystemStatus/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Get-TppSystemStatus.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-SystemStatus.php?tocpath=Web%20SDK%7CSystemStatus%20programming%20interface%7C_____3

#>
function Get-TppSystemStatus {
    [CmdletBinding()]
    param (
        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    Write-Warning "Possible bug with Venafi TPP API causing this to fail"

    $VenafiSession.Validate() | Out-Null

    $params = @{
        VenafiSession = $VenafiSession
        Method     = 'Get'
        UriLeaf    = 'SystemStatus/'
    }

    try {
        Invoke-TppRestMethod @params
    }
    catch {
        Throw ("Getting the system status failed with the following error: {0}.  Ensure you have read rights to the engine root." -f $_)
    }
}