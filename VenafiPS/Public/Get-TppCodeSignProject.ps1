<#
.SYNOPSIS
Get a code sign project

.DESCRIPTION
Get code sign project details

.PARAMETER Path
Path of the project to get

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Path

.OUTPUTS
PSCustomObject with the following properties:
    Application
    Auditor
    CertificateEnvironment
    Collection
    CreatedOn
    Guid
    Id
    KeyUseApprover
    KeyUser
    Owner
    Status
    Name
    Path
    TypeName

.EXAMPLE
Get-TppCodeSignProject -Path '\ved\code signing\projects\my_project'
Get a code sign project

.EXAMPLE
$projectObj | Get-TppCodeSignProject
Get a project after searching using Find-TppCodeSignProject

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppCodeSignProject/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppCodeSignProject.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-GetProject.php

#>
function Get-TppCodeSignProject {

    [CmdletBinding()]
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
        $VenafiSession.Validate('token') | Out-Null

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'Codesign/GetProject'
            Body       = @{ }
        }
    }

    process {

        $params.Body.Dn = $Path
        $response = Invoke-TppRestMethod @params

        if ( $response.Success ) {
            Write-Debug $response.Project
            $response.Project | ConvertTo-TppCodeSignProject
        } else {
            Write-Error ('{0} : {1} : {2}' -f $response.Result, [enum]::GetName([TppCodeSignResult], $response.Result), $response.Error)
        }
    }
}
