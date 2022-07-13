<#
.SYNOPSIS
Move an object of any type

.DESCRIPTION
Move an object of any type from one policy to another.
A rename can be done at the same time as the move by providing a full target path including the new object name.

.PARAMETER SourcePath
Full path to an existing object in TPP

.PARAMETER TargetPath
New path.  This can either be an existing policy and the existing object name will be kept or a full path including a new object name.

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
SourcePath (Path)

.OUTPUTS
n/a

.EXAMPLE
Move-TppObject -SourceDN '\VED\Policy\My Folder\mycert.company.com' -TargetDN '\VED\Policy\New Folder\mycert.company.com'
Move object to a new Policy folder

.EXAMPLE
Find-VenafiCertificate -Path '\ved\policy\certs' | Move-TppObject -TargetDN '\VED\Policy\New Folder'
Move all objects found in 1 folder to another

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
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        # determine if target is a policy or other object
        # if policy, we'll need to append the object name when moving
        # if not policy, the item won't exist so handle the error
        $targetObject = Get-TppObject -Path $TargetPath -VenafiSession $VenafiSession -ErrorAction SilentlyContinue
        $targetIsPolicy = ($targetObject.TypeName -eq 'Policy')
    }

    process {

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriLeaf       = 'config/RenameObject'
            Body          = @{
                ObjectDN    = $SourcePath
                NewObjectDN = $TargetPath
            }
        }

        # if target is a policy, append the object name from source
        if ( $targetIsPolicy ) {
            # get object name, issue 129
            $childPath = $SourcePath.Split('\')[-1]
            $params.Body.NewObjectDN = Join-Path -Path $TargetPath -ChildPath $childPath
        }

        if ( $PSCmdlet.ShouldProcess($SourcePath, ('Move to {0}' -f $params.Body.NewObjectDN)) ) {
            $response = Invoke-VenafiRestMethod @params

            if ( $response.Result -ne [TppConfigResult]::Success ) {
                Write-Error $response.Error
            }
        }
    }
}