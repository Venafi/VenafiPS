<#
.SYNOPSIS
Get CodeSign Protect project settings

.DESCRIPTION
Get CodeSign Protect project settings.  Must have token with scope codesign:manage.

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
None

.OUTPUTS
PSCustomObject with the following properties:
    ApprovedKeyStorageLocations
    AvailableKeyStorageLocations
    DefaultCAContainer
    DefaultCertificateContainer
    DefaultCredentialContainer
    KeyUseTimeout
    ProjectDescriptionTooltip
    RequestInProgressMessage

.EXAMPLE
Get-TppCodeSignConfig
Get settings

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppCodeSignConfig/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppCodeSignConfig.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-GET-Codesign-GetGlobalConfiguration.php

#>
function Get-TppCodeSignConfig {

    [CmdletBinding()]

    param (
        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP' -AuthType 'token'

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Get'
            UriLeaf    = 'Codesign/GetGlobalConfiguration'
        }
    }

    process {

        $response = Invoke-VenafiRestMethod @params

        if ( $response.Success ) {
            $response.GlobalConfiguration
        } else {
            Write-Error ('{0} : {1} : {2}' -f $response.Result, [enum]::GetName([TppCodeSignResult], $response.Result), $response.Error)
        }
    }
}