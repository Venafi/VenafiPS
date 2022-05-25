<#
.SYNOPSIS
Set project status

.DESCRIPTION
Set project status

.PARAMETER Path
Path of the project to update

.PARAMETER Config
New project configuration...

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
Set-TppCodeSignProject -Path '\ved\code signing\projects\my_project' -Config $config

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppCodeSignProject/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Set-TppCodeSignProject.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-UpdateProject.php

#>
function Set-TppCodeSignProject {

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
        [psobject[]] $ApplicationDNs,

        #[Parameter(Mandatory)]
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]] $Owners,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [TppCodeSignProjectStatus] $Status,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]] $KeyUsers,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]] $Auditors,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]] $KeyUseApprovers,

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

        if ( $PSBoundParameters.ContainsKey('ApplicationDNs') ) {
            $apps = @()
            foreach ($app in $ApplicationDNs) {
                $apps += $app.Dn        
            }
            $applicationDNsParams = @{
                Items = $apps
            }
            $params.Body.Project.ApplicationDNs = $applicationDNsParams
        }


        if ( $PSBoundParameters.ContainsKey('Description') ) {
            $params.Body.Project.Description = $Description
        }


        if ( $PSBoundParameters.ContainsKey('KeyUsers') ) {
            $keyUsersParams = @{
                Items = $KeyUsers
            }
            $params.Body.Project.KeyUsers = $keyUsersParams
        }

        if ( $PSBoundParameters.ContainsKey('Auditors') ) {
            $auditorsParams = @{
                Items = $Auditors
            }
            $params.Body.Project.Auditors = $auditorsParams
        }

        if ( $PSBoundParameters.ContainsKey('KeyUseApprovers') ) {
            $keyUseApproversParams = @{
                Items = $KeyUseApprovers
            }
            $params.Body.Project.KeyUseApprovers = $keyUseApproversParams
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