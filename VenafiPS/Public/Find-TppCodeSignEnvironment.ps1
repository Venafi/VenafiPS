<#
.SYNOPSIS
Search for code sign environments

.DESCRIPTION
Search for specific code sign environments that match a name you provide or get all.  This will search across projects.

.PARAMETER Name
Name of the environment to search for

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
Find-TppCodeSignEnvironment
Get all code sign environments

.EXAMPLE
Find-TppCodeSignEnvironment -Name Development
Find all environments that match the name Development

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppCodeSignEnvironment/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppCodeSignEnvironment.ps1

#>
function Find-TppCodeSignEnvironment {

    [CmdletBinding(DefaultParameterSetName = 'All')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '',	Justification = 'Param is being used, possible pssa bug?')]
    [OutputType([TppObject])]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Name')]
        [String] $Name,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP' -AuthType 'token'
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
