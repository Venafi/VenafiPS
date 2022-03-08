<#
.SYNOPSIS
Create a new code sign project

.DESCRIPTION
Create a new code sign project which will be empty.

.PARAMETER Path
Path of the project to create

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Path

.OUTPUTS
PSCustomObject with the following properties:
    Application
    Auditor
    CertificateEnvironments
    Collection
    CreatedOn
    Guid
    Id
    KeyUseApprovers
    KeyUsers
    Owners
    Status
    Name
    Path
    TypeName

.EXAMPLE
New-TppCodeSignProject -Path '\ved\code signing\projects\my_project'
Create a new code sign project

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/New-TppCodeSignProject/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Public/New-TppCodeSignProject.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-CreateProject.php?tocpath=CodeSign%20Protect%20Admin%20REST%C2%A0API%7CProjects%20and%20environments%7C_____5

#>
function New-TppCodeSignProject {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
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
            UriLeaf    = 'Codesign/CreateProject'
            Body       = @{ }
        }
    }

    process {

        $params.Body.Dn = $Path

        if ( $PSCmdlet.ShouldProcess($Path, 'New code sign project') ) {
            $response = Invoke-VenafiRestMethod @params

            if ( $response.Success ) {
                $response.Project | ConvertTo-TppCodeSignProject
            } else {
                Write-Error ('{0} : {1} : {2}' -f $response.Result, [enum]::GetName([TppCodeSignResult], $response.Result), $response.Error)
            }
        }
    }
}
