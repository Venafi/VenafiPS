function Set-TppCodeSignProject {
    <#
    .SYNOPSIS
    Update CodeSign Protect project settings

    .DESCRIPTION
    Update CodeSign Protect project settings

    .PARAMETER Path
    Path of the CodeSign Protect project to update

    .PARAMETER Description
    The new CodeSign Protect project description

    .PARAMETER Owner
    The new CodeSign Protect project owners

    .PARAMETER KeyUser
    The new CodeSign Protect project key users

    .PARAMETER Auditor
    The new CodeSign Protect project auditors

    .PARAMETER KeyUseApprover
    The new CodeSign Protect project key use approvers

    .PARAMETER Status
    The new CodeSign Protect project status, must have the appropriate perms.  Status can be Disabled, Enabled, Draft, or Pending.

    .PARAMETER ApplicationPath
    The new CodeSign Protect project application DNs

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TppServer must also be set.

    .INPUTS
    Path

    .OUTPUTS
    None

    .EXAMPLE
    Set-TppCodeSignProject -Path '\ved\code signing\projects\my_project' -Description 'Updated project description' 

    .EXAMPLE
    Set-TppCodeSignProject -Path '\ved\code signing\projects\my_project' -Owner @('local:{704fdf65-9686-4039-8f9c-a6d425919616})'

    .EXAMPLE
    Set-TppCodeSignProject -Path '\ved\code signing\projects\my_project' -Auditor @('local:{eda14ae2-f65f-478e-90c8-4625ca325983}')

    .EXAMPLE
    Set-TppCodeSignProject -Path '\ved\code signing\projects\my_project' -KeyUseApprover @('local:{efb005da-ae16-4e6c-b263-6b928beb9fa3}', 'local:{7b37cda8-5e51-4ef9-9da2-3a5e8764149e}')

    .EXAMPLE
    Set-TppCodeSignProject -Path '\ved\code signing\projects\my_project' -KeyUser @('local:{412fb225-b109-48c9-85d6-3abf45f725dc}')

    .EXAMPLE
    Set-TppCodeSignProject -Path '\ved\code signing\projects\my_project' -Status Pending

    .EXAMPLE
    Set-TppCodeSignProject -Path '\ved\code signing\projects\my_project' -ApplicationPath @('\VED\Code Signing\Signing Applications\Powershell - x64')


    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppCodeSignProject/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Set-TppCodeSignProject.ps1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-UpdateProject.php

    #>

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

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]] $ApplicationPath,

        #[Parameter(Mandatory)]
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]] $Owner,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [TppCodeSignProjectStatus] $Status,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]] $KeyUser,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]] $Auditor,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]] $KeyUseApprover,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string] $Description,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP' -AuthType 'token'

        $project = Get-TppCodeSignProject -Path $Path

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'Codesign/UpdateProject'
            Body       = @{
                Project = @{
                    ApplicationDNs = @{
                        Items = @($project.ApplicationPath)
                    }
                    Auditors = @{
                        Items = @($project.Auditor)
                    }
                    Description = $project.Description
                    Dn = $project.Path
                    Guid = $project.Guid.Guid
                    KeyUseApprovers = @{
                        Items = @($project.KeyUseApprover)
                    }
                    KeyUsers = @{
                        Items = @($project.KeyUser)
                    }
                    Owners = @{
                        Items = @($project.Owner)
                    }
                    ProjectStatus = $project.Status
                }
            }
        }

        if ( $PSBoundParameters.ContainsKey('ApplicationPath') ) {
            $applicationPathParams = @{
                Items = $ApplicationPath
            }
            $params.Body.Project.ApplicationDNs = $applicationPathParams
        }


        if ( $PSBoundParameters.ContainsKey('Description') ) {
            $params.Body.Project.Description = $Description
        }


        if ( $PSBoundParameters.ContainsKey('KeyUser') ) {
            $keyUsersParams = @{
                Items = $KeyUser
            }
            $params.Body.Project.KeyUsers = $keyUsersParams
        }

        if ( $PSBoundParameters.ContainsKey('Auditor') ) {
            $auditorsParams = @{
                Items = $Auditor
            }
            $params.Body.Project.Auditors = $auditorsParams
        }

        if ( $PSBoundParameters.ContainsKey('KeyUseApprover') ) {
            $keyUseApproversParams = @{
                Items = $KeyUseApprover
            }
            $params.Body.Project.KeyUseApprovers = $keyUseApproversParams
        }

        if ( $PSBoundParameters.ContainsKey('Owner') ) {
            $ownerParams = @{
                Items = $Owner
            }
            $params.Body.Project.Owners = $ownerParams
        }


    }

    process {

        $params.Body.Dn = $Path

        if ( $PSCmdlet.ShouldProcess($Path, "Updating project configuration") ) {
            $response = Invoke-VenafiRestMethod @params

            if ( -not $response.Success ) {
                Write-Error ('{0} : {1} : {2}' -f $response.Result, [enum]::GetName([TppCodeSignResult], $response.Result), $response.Error)
            }
        }
    }
}