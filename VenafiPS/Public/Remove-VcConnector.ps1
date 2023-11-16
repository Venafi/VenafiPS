function Remove-VcConnector {
    <#
    .SYNOPSIS
    Remove a connector

    .DESCRIPTION
    Remove a connector from TLSPC

    .PARAMETER ID
    Connector ID, this is the guid/uuid

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
    Remove-VcConnector -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Confirm:$false
    Remove a connector bypassing the confirmation prompt
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]

    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('connectorId')]
        [string] $ID,

        [Parameter()]
        [int] $ThrottleLimit = 100,

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
            $null = Invoke-VenafiRestMethod -Method 'Delete' -UriLeaf "connectors/$PSItem"
        } -ThrottleLimit $ThrottleLimit -VenafiSession $VenafiSession
    }
}
