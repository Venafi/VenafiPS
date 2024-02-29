﻿function Remove-VcConnector {
    <#
    .SYNOPSIS
    Remove a connector

    .DESCRIPTION
    Remove a connector from TLSPC

    .PARAMETER ID
    Connector ID, this is the guid/uuid

    .PARAMETER DisableOnly
    Disable the connector instead of removing

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    ID

    .EXAMPLE
    Remove-VcConnector -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
    Remove a connector

    .EXAMPLE
    Remove-VcConnector -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -DisableOnly
    Disable a connector, do not remove it

    .EXAMPLE
    Remove-VcConnector -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Confirm:$false
    Remove a connector bypassing the confirmation prompt
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]

    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('connectorId')]
        [string] $ID,

        [Parameter()]
        [switch] $DisableOnly,

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
        if ( $PSCmdlet.ShouldProcess($ID, "Delete connector") ) {
            $allObjects.Add($ID)
        }
    }

    end {
        Invoke-VenafiParallel -InputObject $allObjects -ScriptBlock {
            if ( $using:DisableOnly ) {
                $null = Invoke-VenafiRestMethod -Method 'Post' -UriLeaf "plugins/$PSItem/disablements"
            }
            else {
                $null = Invoke-VenafiRestMethod -Method 'Delete' -UriLeaf "plugins/$PSItem"
            }
        } -ThrottleLimit $ThrottleLimit -VenafiSession $VenafiSession
    }
}
