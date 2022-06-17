<#
.SYNOPSIS
Set project status

.DESCRIPTION
Set project status

.PARAMETER Path
Path of the project to update

.PARAMETER Status
New project status, must have the appropriate perms.  Status can be Disabled, Enabled, Draft, or Pending.

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
Set-TppCodeSignProject -Path '\ved\code signing\projects\my_project' -Status Pending
Update project status

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppCodeSignProjectStatus/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Set-TppCodeSignProjectStatus.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-UpdateProjectStatus.php

#>
function Set-TppCodeSignProjectStatus {

    [CmdletBinding(SupportsShouldProcess)]
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

        [Parameter(Mandatory)]
        [TppCodeSignProjectStatus] $Status,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP' -AuthType 'token'

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'Codesign/UpdateProjectStatus'
            Body       = @{
                'ProjectStatus' = $Status
            }
        }
    }

    process {

        $params.Body.Dn = $Path

        if ( $PSCmdlet.ShouldProcess($Path, "Set project status to $Status") ) {
            $response = Invoke-VenafiRestMethod @params

            if ( -not $response.Success ) {
                Write-Error ('{0} : {1} : {2}' -f $response.Result, [enum]::GetName([TppCodeSignResult], $response.Result), $response.Error)
            }
        }
    }
}
