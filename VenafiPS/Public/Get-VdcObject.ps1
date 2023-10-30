function Get-VdcObject {
    <#
    .SYNOPSIS
    Get object information

    .DESCRIPTION
    Return object information by either path or guid.  This will return a TppObject which can be used with many other functions.

    .PARAMETER Path
    The full path to the object.
    \ved\policy will be automatically applied if a full path isn't provided.

    .PARAMETER Guid
    Guid of the object

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named TLSPDC_SERVER must also be set.

    .INPUTS
    Path, Guid

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-VdcObject -Path '\VED\Policy\My object'

    Get an object by path

    .EXAMPLE
    [guid]'dab22152-0a81-4fb8-a8da-8c5e3d07c3f1' | Get-VdcObject

    Get an object by guid

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Get-VdcObject/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VdcObject.ps1

    #>

    [CmdletBinding()]
    [Alias('Get-TppObject', 'gvdo')]

    param (
        [Parameter(Mandatory, ParameterSetName = 'ByPath', ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DN')]
        [String[]] $Path,

        [Parameter(Mandatory, ParameterSetName = 'ByGuid', ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Alias('ObjectGuid')]
        [guid[]] $Guid,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TLSPDC'
    }

    process {

        if ( $PSCmdLet.ParameterSetName -eq 'ByPath' ) {
            $Path | ConvertTo-VdcFullPath | ForEach-Object {
                ConvertTo-VdcObject -Path $_
            }
        }
        else {
            $Guid | ConvertTo-VdcFullPath | ForEach-Object {
                ConvertTo-VdcObject -Guid $_
            }
        }
    }
}