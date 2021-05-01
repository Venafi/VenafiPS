<#
.SYNOPSIS
Get a code sign project

.DESCRIPTION
Get code sign project details

.PARAMETER Path
Path of the project to get

.PARAMETER TppSession
Session object created from New-TppSession method.  The value defaults to the script session object $TppSession.

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
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Get-TppCodeSignProject.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-GetProject.php?tocpath=CodeSign%20Protect%20Admin%20REST%C2%A0API%7CProjects%20and%20environments%7C_____10

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
        [TppSession] $TppSession = $Script:TppSession
    )

    begin {
        $TppSession.Validate('token')

        $params = @{
            TppSession = $TppSession
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
