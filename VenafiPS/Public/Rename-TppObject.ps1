<#
.SYNOPSIS
Rename and/or move an object

.DESCRIPTION
Rename and/or move an object

.PARAMETER Path
Full path to an existing object

.PARAMETER NewPath
New path, including name

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
none

.OUTPUTS

.EXAMPLE
Rename-TppObject -Path '\VED\Policy\My Devices\OldDeviceName' -NewPath '\ved\policy\my devices\NewDeviceName'
Rename an object

.EXAMPLE
Rename-TppObject -Path '\VED\Policy\My Devices\DeviceName' -NewPath '\ved\policy\new devices folder\DeviceName'
Move an object

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Rename-TppObject/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Rename-TppObject.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-renameobject.php

#>
function Rename-TppObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                } else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('SourceDN')]
        [String] $Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $NewPath,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

    $params = @{
        VenafiSession = $VenafiSession
        Method     = 'Post'
        UriLeaf    = 'config/RenameObject'
        Body       = @{
            ObjectDN    = $Path
            NewObjectDN = $NewPath
        }
    }

    $response = Invoke-VenafiRestMethod @params

    if ( $response.Result -ne [TppConfigResult]::Success ) {
        throw $response.Error
    }
}