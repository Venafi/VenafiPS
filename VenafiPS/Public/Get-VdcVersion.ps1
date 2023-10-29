function Get-VdcVersion {
    <#
    .SYNOPSIS
    Get the TPP version

    .DESCRIPTION
    Returns the TPP version

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token can also be provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    none

    .OUTPUTS
    Version

    .EXAMPLE
    Get-VdcVersion
    Get the version

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Get-VdcVersion/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VdcVersion.ps1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-SystemStatusVersion.php

    #>

    [CmdletBinding()]
    [Alias('Get-TppVersion')]
    [OutputType([System.Version])]

    param (
        [Parameter()]
        [psobject] $VenafiSession
    )

    Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

    $params = @{

        Method        = 'Get'
        UriLeaf       = 'SystemStatus/Version'
    }

    try {
        [Version]((Invoke-VenafiRestMethod @params).Version)
    }
    catch {
        Throw ("Getting the version failed with the following error: {0}.  This feature was introduced in v18.3." -f $_)
    }
}
