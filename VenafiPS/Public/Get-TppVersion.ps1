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
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppVersion.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-SystemStatusVersion.php

#>
function Get-TppVersion {

    [CmdletBinding()]
    [OutputType([System.Version])]

    param (
        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    $VenafiSession.Validate('TPP')

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
