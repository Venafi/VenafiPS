<#
.SYNOPSIS
Search for code sign projects

.DESCRIPTION
Search for specific code sign projects or return all

.PARAMETER Name
Name of the project to search for

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

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
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-EnumerateProjects.php

#>
function Find-TppCodeSignTemplate {

    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Name')]
        [String] $Name,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP' -AuthType 'token'

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'Codesign/EnumerateTemplates'
            Body       = @{ }
        }

        $allTemplates = @()
    }

    process {

        Switch ($PsCmdlet.ParameterSetName)	{
            'Name' {
                $params.Body.Filter = $Name
            }

            'All' {
            }
        }

        $response = Invoke-VenafiRestMethod @params

        if ( $response.Success ) {
            $allTemplates += foreach ($thisTemplate in $response.CertificateTemplates) {
                [TppObject] @{
                    TypeName = $thisTemplate.Type
                    Path     = $thisTemplate.DN
                    Guid     = $thisTemplate.Guid
                }
            }

        } else {
            Write-Error ('{0} : {1} : {2}' -f $response.Result, [enum]::GetName([TppCodeSignResult], $response.Result), $response.Error)
        }
    }

    end {
        $allTemplates | Sort-Object -Property Path -Unique
    }
}