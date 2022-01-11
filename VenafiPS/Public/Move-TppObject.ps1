<#
.SYNOPSIS
Move an object of any type

.DESCRIPTION
Move an object of any type

.PARAMETER SourcePath
Full path to an object in TPP

.PARAMETER TargetPath
New path

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
none

.OUTPUTS

.EXAMPLE
Move-TppObject -SourceDN '\VED\Policy\My Folder\mycert.company.com' -TargetDN '\VED\Policy\New Folder\mycert.company.com'
Moves mycert.company.com to a new Policy folder

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Move-TppObject/

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Test-TppObject/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Move-TppObject.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-renameobject.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____35

#>
function Move-TppObject {
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
        [String] $SourcePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                } else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('TargetDN')]
        [String] $TargetPath,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    $VenafiSession.Validate() | Out-Null

    # ensure the object to rename already exists
    if ( -not (Test-TppObject -Path $SourcePath -ExistOnly -VenafiSession $VenafiSession) ) {
        throw ("Source path '{0}' does not exist" -f $SourcePath)
    }

    # ensure the new object doesn't already exist
    if ( Test-TppObject -Path $TargetPath -ExistOnly -VenafiSession $VenafiSession) {
        throw ("Target path '{0}' already exists" -f $TargetPath)
    }

    $params = @{
        VenafiSession = $VenafiSession
        Method     = 'Post'
        UriLeaf    = 'config/RenameObject'
        Body       = @{
            ObjectDN    = $SourcePath
            NewObjectDN = $TargetPath
        }
    }

    $response = Invoke-TppRestMethod @params

    if ( $response.Result -ne [TppConfigResult]::Success ) {
        throw $response.Error
    }
}