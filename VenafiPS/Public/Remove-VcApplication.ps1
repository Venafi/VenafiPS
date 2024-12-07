function Remove-VcApplication {
    <#
    .SYNOPSIS
    Remove a application

    .DESCRIPTION
    Remove a application from TLSPC

    .PARAMETER ID
    Application ID, this is the guid/uuid

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    ID

    .EXAMPLE
    Remove-VcApplication -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
    Remove a application

    .EXAMPLE
    Remove-VcApplication -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Confirm:$false
    Remove a application bypassing the confirmation prompt
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]

    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('applicationId')]
        [string] $ID,

        [Parameter()]
        [int32] $ThrottleLimit = 100,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession $PSCmdlet.MyInvocation
        $allObjects = [System.Collections.Generic.List[object]]::new()
    }

    process {
        if ( $PSCmdlet.ShouldProcess($ID, "Delete application") ) {
            $allObjects.Add($ID)
        }
    }

    end {
        Invoke-VenafiParallel -InputObject $allObjects -ScriptBlock {
            $null = Invoke-VenafiRestMethod -Method 'Delete' -UriRoot 'outagedetection/v1' -UriLeaf "applications/$PSItem"
        } -ThrottleLimit $ThrottleLimit -VenafiSession $VenafiSession
    }
}
