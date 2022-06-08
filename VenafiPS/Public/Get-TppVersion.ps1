<#
.SYNOPSIS
Get the TPP version

.DESCRIPTION
Returns the TPP version

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

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
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppVersion.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-SystemStatusVersion.php

#>
function Get-TppVersion {

    [CmdletBinding()]
    [OutputType([System.Version])]

    param (
        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

    $params = @{
        VenafiSession = $VenafiSession
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
