function Remove-VdcObject {
    <#
    .SYNOPSIS
    Remove TPP objects

    .DESCRIPTION
    Remove a TPP object and optionally perform a recursive removal.
    This process can be very destructive as it will remove anything you send it!!!

    .PARAMETER Path
    Full path to an existing object

    .PARAMETER Recursive
    Remove recursively, eg. everything within a policy folder

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    Path

    .OUTPUTS
    None

    .EXAMPLE
    Remove-VdcObject -Path '\VED\Policy\My empty folder'
    Remove an object

    .EXAMPLE
    Remove-VdcObject -Path '\VED\Policy\folder' -Recursive
    Remove an object and all objects contained

    .EXAMPLE
    Find-VdcObject -Class 'capi' | Remove-VdcObject
    Find 1 or more objects and remove them

    .EXAMPLE
    Remove-VdcObject -Path '\VED\Policy\folder' -Confirm:$false
    Remove an object without prompting for confirmation.  Be careful!

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Remove-VdcObject/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-VdcObject.ps1

    .LINK
    https://docs.venafi.com/Docs/currentSDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-delete.php

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [Alias('Remove-TppObject')]

    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String] $Path,

        [Parameter()]
        [switch] $Recursive,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        Write-Warning 'This operation is potentially very destructive.  Ensure you want to perform this action before continuing.'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriLeaf       = 'config/Delete'
            Body          = @{
                ObjectDN  = ''
                Recursive = [int] ($Recursive.IsPresent)
            }
        }
    }

    process {
        $params.Body.ObjectDN = $Path | ConvertTo-VdcFullPath

        if ($PSCmdlet.ShouldProcess($params.Body.ObjectDN, 'Remove object')) {
            $response = Invoke-VenafiRestMethod @params

            if ( $response.Result -ne [TppConfigResult]::Success ) {
                throw $response.Error
            }
        }
    }
}