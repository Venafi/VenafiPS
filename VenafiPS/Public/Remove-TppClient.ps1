<#
.SYNOPSIS
Remove registered client agents

.DESCRIPTION
Remove registered client agents.
Provide an array of client IDs to remove a large list at once.

.PARAMETER ClientId
Unique id for one or more clients

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
ClientId

.OUTPUTS
None

.EXAMPLE
Remove-TppClient -ClientId 1234
Remove a client

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppClient/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppClient.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-ClientDelete.php

#>
function Remove-TppClient {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String[]] $ClientId,

        [Parameter()]
        [switch] $RemoveAssociatedDevices,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('tpp') | Out-Null

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriLeaf       = 'Client/Delete'
            Body          = @{}
        }

    }

    process {

        $clientIds = $ClientId | ForEach-Object {
            @{ 'ClientId' = $_ }
        }

        $params.Body.Clients = @($clientIds)
        $params.Body.DeleteAssociatedDevices = $RemoveAssociatedDevices.IsPresent.ToString().ToLower()

        if ( $PSCmdlet.ShouldProcess($ClientId -join ', ') ) {
            $response = Invoke-VenafiRestMethod @params

            if ( $response.Errors ) {
                Write-Error ($response.Errors | ConvertTo-Json)
            }
        }
    }
}