<#
.SYNOPSIS
Delete a code sign project

.DESCRIPTION
Delete a code sign project.  You must be a code sign admin or owner of the project.

.PARAMETER Path
Path of the project to delete

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Path

.OUTPUTS
None

.EXAMPLE
Remove-TppCodeSignProject -Path '\ved\code signing\projects\my_project'
Delete a project

.EXAMPLE
$projectObj | Remove-TppCodeSignProject
Remove 1 or more projects.  Get projects with Find-TppCodeSignProject

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppCodeSignProject/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppCodeSignProject.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-DeleteProject.php

#>
function Remove-TppCodeSignProject {

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
        $VenafiSession.Validate('TPP', 'token')

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'Codesign/DeleteProject'
            Body       = @{ }
        }
    }

    process {

        $params.Body.Dn = $Path

        if ( $PSCmdlet.ShouldProcess($Path, 'Remove code sign project') ) {

            $response = Invoke-VenafiRestMethod @params

            if ( -not $response.Success ) {
                Write-Error ('{0} : {1} : {2}' -f $response.Result, [enum]::GetName([TppCodeSignResult], $response.Result), $response.Error)
            }
        }
    }
}
