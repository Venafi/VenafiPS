﻿function Remove-VcMachine {
    <#
    .SYNOPSIS
    Remove a machine

    .DESCRIPTION
    Remove a machine from TLSPC

    .PARAMETER ID
    Machine ID, this is the guid/uuid

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    ID

    .EXAMPLE
    Remove-VcMachine -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
    Remove a machine

    .EXAMPLE
    Remove-VcMachine -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Confirm:$false
    Remove a machine bypassing the confirmation prompt
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]

    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('machineId')]
        [string] $ID,

        [Parameter()]
        [int32] $ThrottleLimit = 100,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'
        $allObjects = [System.Collections.Generic.List[object]]::new()
    }

    process {
        if ( $PSCmdlet.ShouldProcess($ID, "Delete machine") ) {
            $allObjects.Add($ID)
        }
    }

    end {
        Invoke-VenafiParallel -InputObject $allObjects -ScriptBlock {
            $null = Invoke-VenafiRestMethod -Method 'Delete' -UriLeaf "machines/$PSItem"
        } -ThrottleLimit $ThrottleLimit -VenafiSession $VenafiSession
    }
}
