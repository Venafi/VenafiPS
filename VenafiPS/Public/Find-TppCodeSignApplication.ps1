<#
.SYNOPSIS
Search for code sign applications

.DESCRIPTION
Search for specific code sign applications or return all

.PARAMETER Name
Name of the code signing application to search for

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TppServer must also be set.

.INPUTS
None

.OUTPUTS
TppObject

.EXAMPLE
Find-TppCodeSignApplication
Get all code sign applications

.EXAMPLE
Find-TppCodeSignApplication -Name Powershell
Find all code signing applications that match the name Powershell

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppCodeSignApplication/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppCodeSignApplication.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-EnumerateApplications.php

#>
function Find-TppCodeSignApplication {

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
            UriLeaf    = 'Codesign/EnumerateApplications'
            Body       = @{ }
        }

        $allApplications = @()
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
            $allApplications += foreach ($thisApplication in $response.Applications) {
                @{
                    Dn     = $thisApplication.DN
                    Guid     = $thisApplication.Guid
                    Id       = $thisApplication.Id
                    Location = $thisApplication.Location
                }
            }

        } else {
            Write-Error ('{0} : {1} : {2}' -f $response.Result, [enum]::GetName([TppCodeSignResult], $response.Result), $response.Error)
        }
    }

    end {
        $allApplications | Sort-Object -Property Dn -Unique
    }
}