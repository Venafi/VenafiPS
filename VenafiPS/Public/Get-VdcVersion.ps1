function Get-VdcVersion {
    <#
    .SYNOPSIS
    Get the TLSPDC version

    .DESCRIPTION
    Returns the TLSPDC version

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

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

    Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VDC'

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
