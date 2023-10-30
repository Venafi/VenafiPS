function Convert-VdcObject {
    <#
    .SYNOPSIS
    Change the class/object type of an existing object

    .DESCRIPTION
    Change the class/object type of an existing object.
    Please note, changing the class does NOT change any attributes and must be done separately.
    Using -PassThru will allow you to pass the input to other functions including Set-VdcAttribute; see the examples.

    .PARAMETER Path
    Path to the object

    .PARAMETER Class
    New class/type

    .PARAMETER PassThru
    Return a TppObject representing the newly converted object

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named TLSPDC_SERVER must also be set.

    .INPUTS
    Path

    .OUTPUTS
    TppObject, if -PassThru provided

    .EXAMPLE
    Convert-VdcObject -Path '\ved\policy\' -Class 'X509 Device Certificate'
    Convert an object to a different type

    .EXAMPLE
    Convert-VdcObject -Path '\ved\policy\device\app' -Class 'CAPI' -PassThru | Set-VdcAttribute -Attribute @{'Driver Name'='appcapi'}
    Convert an object to a different type, return the updated object and update attributes

    .EXAMPLE
    Find-VdcObject -Class Basic | Convert-VdcObject -Class 'capi' -PassThru | Set-VdcAttribute -Attribute @{'Driver Name'='appcapi'}
    Convert multiple objects to a different type, return the updated objects and update attributes

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Convert-VdcObject.ps1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-mutateobject.php

    #>

    [CmdletBinding(SupportsShouldProcess)]
    [Alias('Convert-TppObject')]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid path"
                }
            })]
        [String] $Path,

        [Parameter(Mandatory)]
        [String] $Class,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TLSPDC'

        $params = @{
            Method        = 'Post'
            UriLeaf       = 'config/MutateObject'
            Body          = @{
                Class = $Class
            }
        }
    }

    process {

        $params.Body.ObjectDN = $Path

        if ( $PSCmdlet.ShouldProcess($Path, "Convert to type $Class") ) {

            $response = Invoke-VenafiRestMethod @params

            if ( $response.Result -eq [TppConfigResult]::Success ) {
                if ( $PassThru ) {
                    ConvertTo-VdcObject -Path $Path
                }
            }
            else {
                Write-Error $response.Error
            }
        }
    }
}