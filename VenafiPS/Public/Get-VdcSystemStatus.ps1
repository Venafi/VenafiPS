function Get-VdcSystemStatus {
    <#
    .SYNOPSIS
    Get the TPP system status

    .DESCRIPTION
    Returns service module statuses for Trust Protection Platform, Log Server, and Trust Protection Platform services that run on Microsoft Internet Information Services (IIS)

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    none

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-VdcSystemStatus
    Get the status

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Get-VdcSystemStatus/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VdcSystemStatus.ps1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-SystemStatus.php

    #>
    [CmdletBinding()]
    [Alias('Get-TppSystemStatus')]

    param (
        [Parameter()]
        [psobject] $VenafiSession
    )

    Write-Warning "Possible bug with Venafi TPP API causing this to fail"

    Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

    $params = @{
        VenafiSession = $VenafiSession
        Method     = 'Get'
        UriLeaf    = 'SystemStatus/'
    }

    try {
        Invoke-VenafiRestMethod @params
    }
    catch {
        Throw ("Getting the system status failed with the following error: {0}.  Ensure you have read rights to the engine root." -f $_)
    }
}