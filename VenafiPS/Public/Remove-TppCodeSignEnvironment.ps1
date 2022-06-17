<#
.SYNOPSIS
Delete a code sign certificate environment

.DESCRIPTION
Delete a code sign certificate environment and related objects such as keys and certificates. You must be a code sign admin or owner of the project.

.PARAMETER Path
Path of the environment to delete

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
Path

.OUTPUTS
None

.EXAMPLE
Remove-TppCodeSignEnvironment -Path '\ved\code signing\projects\my_project\dev'
Delete an environment

.EXAMPLE
$envObj | Remove-TppCodeSignEnvironment
Remove 1 or more environments.  Get environments with Find-TppCodeSignEnvironment

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppCodeSignEnvironment/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppCodeSignEnvironment.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-DeleteEnvironment.php

#>
function Remove-TppCodeSignEnvironment {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                } else {
                    throw "'$_' is not a valid path"
                }
            })]
        [String] $Path,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP' -AuthType 'token'

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'Codesign/DeleteEnvironment'
            Body       = @{ }
        }
    }

    process {

        $params.Body.Dn = $Path

        if ( $PSCmdlet.ShouldProcess($Path, 'Remove code sign certificate environment') ) {

            $response = Invoke-VenafiRestMethod @params

            if ( -not $response.Success ) {
                Write-Error ('{0} : {1} : {2}' -f $response.Result, [enum]::GetName([TppCodeSignResult], $response.Result), $response.Error)
            }
        }
    }
}
