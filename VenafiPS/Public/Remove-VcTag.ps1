function Remove-VcTag {
    <#
    .SYNOPSIS
    Remove a tag

    .DESCRIPTION
    Remove a tag from TLSPC

    .PARAMETER ID
    Tag ID/name

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    Name

    .EXAMPLE
    Remove-VcTag -ID 'MyTag'
    Remove a tag

    .EXAMPLE
    Remove-VcTag -ID 'MyTag' -Confirm:$false
    Remove a tag bypassing the confirmation prompt
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]

    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('tagId')]
        [string] $ID,

        [Parameter()]
        [int32] $ThrottleLimit = 100,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession $PSCmdlet.MyInvocation
        $allObjects = [System.Collections.Generic.List[object]]::new()
    }

    process {
        if ( $PSCmdlet.ShouldProcess($ID, "Delete Tag") ) {
            $allObjects.Add($ID)
        }
    }

    end {
        Invoke-VenafiParallel -InputObject $allObjects -ScriptBlock {
            $null = Invoke-VenafiRestMethod -Method 'Delete' -UriLeaf "tags/$PSItem"
        } -ThrottleLimit $ThrottleLimit -VenafiSession $VenafiSession
    }
}
