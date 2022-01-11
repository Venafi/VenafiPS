<#
.SYNOPSIS
Search for code sign projects

.DESCRIPTION
Search for specific code sign projects or return all

.PARAMETER Name
Name of the project to search for

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
None

.OUTPUTS
TppObject

.EXAMPLE
Find-TppCodeSignProject
Get all code sign projects

.EXAMPLE
Find-TppCodeSignProject -Name CSTest
Find all projects that match the name CSTest

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppCodeSignProject/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppCodeSignProject.ps1

.LINK
https://docs.venafi.com/Docs/20.3/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-EnumerateProjects.php?tocpath=CodeSign%20Protect%20SDK%20reference%7CProjects%20and%20environments%7C_____8

#>
function Find-TppCodeSignProject {

    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Name')]
        [String] $Name,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('token') | Out-Null

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'Codesign/EnumerateProjects'
            Body       = @{ }
        }

        $allProjects = @()
    }

    process {

        Switch ($PsCmdlet.ParameterSetName)	{
            'Name' {
                $params.Body.Filter = $Name
            }

            'All' {
            }
        }

        $response = Invoke-TppRestMethod @params

        if ( $response.Success ) {
            $allProjects += foreach ($thisProject in $response.Projects) {
                [TppObject] @{
                    Name     = Split-Path $thisProject.DN -Leaf
                    TypeName = 'Code Signing Project'
                    Path     = $thisProject.DN
                    Guid     = $thisProject.Guid
                }
            }

        } else {
            Write-Error ('{0} : {1} : {2}' -f $response.Result, [enum]::GetName([TppCodeSignResult], $response.Result), $response.Error)
        }
    }

    end {
        $allProjects | Sort-Object -Property Path -Unique
    }
}