<#
.SYNOPSIS
Get CodeSign Protect project settings

.DESCRIPTION
Get CodeSign Protect project settings.  Must have token with scope codesign:manage.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

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
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Get-TppCodeSignConfig.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/CodeSignSDK/r-SDKc-GET-Codesign-GetGlobalConfiguration.php?tocpath=CodeSign%20Protect%20Admin%20REST%C2%A0API%7CGlobalConfiguration%7C_____1

#>
function Get-TppCodeSignConfig {

    [CmdletBinding()]

    param (
        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('token') | Out-Null

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Get'
            UriLeaf    = 'Codesign/GetGlobalConfiguration'
        }
    }

    process {

        $response = Invoke-TppRestMethod @params

        if ( $response.Success ) {
            $response.GlobalConfiguration
        } else {
            Write-Error ('{0} : {1} : {2}' -f $response.Result, [enum]::GetName([TppCodeSignResult], $response.Result), $response.Error)
        }
    }
}