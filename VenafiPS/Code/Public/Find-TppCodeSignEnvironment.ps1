<#
.SYNOPSIS
Search for code sign environments

.DESCRIPTION
Search for specific code sign environments that match a name you provide or get all.  This will search across projects.

.PARAMETER Name
Name of the environment to search for

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
None

.OUTPUTS
TppObject

.EXAMPLE
Find-TppCodeSignEnvironment
Get all code sign environments

.EXAMPLE
Find-TppCodeSignEnvironment -Name Development
Find all environments that match the name Development

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppCodeSignEnvironment/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Find-TppCodeSignEnvironment.ps1

#>
function Find-TppCodeSignEnvironment {

    [CmdletBinding(DefaultParameterSetName = 'All')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '',	Justification = 'Param is being used, possible pssa bug?')]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Name')]
        [String] $Name,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('token')
        $projects = Find-TppCodeSignProject | Get-TppCodeSignProject
    }

    process {

        Switch ($PsCmdlet.ParameterSetName)	{
            'Name' {
                $envs = $projects.CertificateEnvironment | Where-Object { $_.Name -match $Name }
                $envs = $envs | Sort-Object -Property Path -Unique
            }

            'All' {
                $envs = $projects.CertificateEnvironment
            }
        }

        foreach ($env in $envs) {
            [TppObject] @{
                Name     = $env.Name
                TypeName = $env.TypeName
                Path     = $env.Path
                Guid     = $env.Guid
            }
        }
    }
}
