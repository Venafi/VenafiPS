<#
.SYNOPSIS
Get a code sign project

.DESCRIPTION
Get code sign project details

.PARAMETER Path
Path of the project to get

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

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
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP' -AuthType 'token'

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'Codesign/GetProject'
            Body       = @{ }
        }
    }

    process {

        $params.Body.Dn = $Path
        $response = Invoke-VenafiRestMethod @params

        if ( $response.Success ) {
            Write-Debug $response.Project
            $response.Project | ConvertTo-TppCodeSignProject
        } else {
            Write-Error ('{0} : {1} : {2}' -f $response.Result, [enum]::GetName([TppCodeSignResult], $response.Result), $response.Error)
        }
    }
}
