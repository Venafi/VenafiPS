<#
.SYNOPSIS
Delete a code sign certificate environment

.DESCRIPTION
Delete a code sign certificate environment and related objects such as keys and certificates. You must be a code sign admin or owner of the project.

.PARAMETER Path
Path of the environment to delete

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

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
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Remove-TppCodeSignEnvironment.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-DeleteEnvironment.php?tocpath=CodeSign%20Protect%20Admin%20REST%C2%A0API%7CProjects%20and%20environments%7C_____6

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
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('token')

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

            $response = Invoke-TppRestMethod @params

            if ( -not $response.Success ) {
                Write-Error ('{0} : {1} : {2}' -f $response.Result, [enum]::GetName([TppCodeSignResult], $response.Result), $response.Error)
            }
        }
    }
}
