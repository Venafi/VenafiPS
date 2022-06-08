<#
.SYNOPSIS
Get object information

.DESCRIPTION
Return object information by either path or guid.  This will return a TppObject which can be used with many other functions.

.PARAMETER Path
The full path to the object

.PARAMETER Guid
Guid of the object

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
Path, Guid

.OUTPUTS
TppObject

.EXAMPLE
Get-TppObject -Path '\VED\Policy\My object'

Get an object by path

.EXAMPLE
[guid]'dab22152-0a81-4fb8-a8da-8c5e3d07c3f1' | Get-TppObject

Get an object by guid

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppObject/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppObject.ps1

#>
function Get-TppObject {

    [CmdletBinding()]

    param (
        [Parameter(Mandatory, ParameterSetName = 'ByPath', ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('DN')]
        [String[]] $Path,

        [Parameter(Mandatory, ParameterSetName = 'ByGuid', ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Alias('ObjectGuid')]
        [guid[]] $Guid,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'
    }

    process {

        if ( $PSCmdLet.ParameterSetName -eq 'ByPath' ) {
            $inputObject = $Path
        }
        else {
            $inputObject = $Guid
        }

        foreach ($thisInputObject in $inputObject) {
            [TppObject]::new($thisInputObject, $VenafiSession)
        }
    }
}