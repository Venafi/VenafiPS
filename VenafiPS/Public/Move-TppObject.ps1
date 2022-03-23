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
SourcePath (Path)

.OUTPUTS
n/a

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
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-renameobject.php

#>
function Move-TppObject {

    [CmdletBinding(SupportsShouldProcess)]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('SourceDN', 'Path')]
        [String] $SourcePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('TargetDN')]
        [String] $TargetPath,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('TPP')
    }

    process {

        if ( $PSCmdlet.ShouldProcess($SourcePath, "Move to $TargetPath") ) {

            $params = @{
                VenafiSession = $VenafiSession
                Method        = 'Post'
                UriLeaf       = 'config/RenameObject'
                Body          = @{
                    ObjectDN    = $SourcePath
                    NewObjectDN = $TargetPath
                }
            }

            $response = Invoke-VenafiRestMethod @params

            if ( $response.Result -ne [TppConfigResult]::Success ) {
                Write-Error $response.Error
            }
        }
    }
}