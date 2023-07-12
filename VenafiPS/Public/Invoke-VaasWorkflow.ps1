function Invoke-VaasWorkflow {
    <#
    .SYNOPSIS
    Start a machine or machine identity workflow

    .DESCRIPTION
    Start a workflow to either test machine credentials or provision or discover machine identities

    .PARAMETER ID
    Machine or machine identity id for the workflow to trigger.
    Workflows 'Test' and 'GetConfig' require the machine ID.
    Workflows 'Provision' and 'Discover' require the machine identity ID.

    .PARAMETER WorkflowName
    The name of the workflow to trigger.
    Valid values are 'Test', 'GetConfig', 'Provision', or 'Discover'.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .EXAMPLE
    Invoke-VaasWorkflow -ID '1345baf1-fc56-49b7-aa03-78e35bfe0a1a' -WorkflowName 'Provision'

    ID                                   WorkflowName Success
    --                                   ------------ -------
    89fa4370-2026-11ee-8a18-ff9579bb988e Test         True

    Trigger provisioning

    .EXAMPLE
    Invoke-VaasWorkflow -ID '1345baf1-fc56-49b7-aa03-78e35bfe0a1a' -WorkflowName 'Provision'

    ID                                   WorkflowName Success Error
    --                                   ------------ ------- -----
    1345baf1-fc56-49b7-aa03-78e35bfe0a1a Provision    False   Failed for some reason....

    Trigger provisioning, but it failed

    .EXAMPLE
    Find-VaasObject -Type MachineIdentity -Filter @('and', @('certificateValidityEnd', 'lt', (get-date).AddDays(30)), @('certificateValidityEnd', 'gt', (get-date))) | ForEach-Object {
        $renewResult = $_ | Invoke-VenafiCertificateAction -Renew
        # optionally add renew validation
        $_ | Invoke-VaasWorkflow -WorkflowName 'Provision'
    }

    ID                                   WorkflowName Success
    --                                   ------------ -------
    89fa4370-2026-11ee-8a18-ff9579bb988e Provision    True
    7598917c-7027-4927-be73-e592bcc4c567 Provision    True

    Renew and provision all machine identities with certificates expiring within 30 days

    .INPUTS
    ID

    .OUTPUTS
    pscustomobject
    #>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('machineID', 'machineIdentityID')]
        [string] $ID,

        [Parameter()]
        [ValidateSet('Test', 'GetConfig', 'Provision', 'Discover')]
        [string] $WorkflowName = 'Test',

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    process {

        $thisWebSocketID = (New-Guid).Guid

        try {

            $URL = 'wss://api.venafi.cloud/ws/notificationclients/' + $thisWebSocketID
            $WS = New-Object System.Net.WebSockets.ClientWebSocket
            $CT = New-Object System.Threading.CancellationToken

            if ( $VenafiSession.GetType().Name -eq 'VenafiSession' ) {
                $WS.Options.SetRequestHeader("tppl-api-key", $VenafiSession.Key.GetNetworkCredential().password)
            }
            else {
                $WS.Options.SetRequestHeader("tppl-api-key", $VenafiSession)
            }

            #Get connected
            $Conn = $WS.ConnectAsync($URL, $CT)

            While ( !$Conn.IsCompleted ) {
                Start-Sleep -Milliseconds 100
            }

            Write-Verbose "Connecting to $($URL)..."
            $Size = 1024
            $Array = [byte[]] @(, 0) * $Size

            #Send Starting Request
            $Command = [System.Text.Encoding]::UTF8.GetBytes("ACTION=Command")
            $Send = New-Object System.ArraySegment[byte] -ArgumentList @(, $Command)
            $Conn = $WS.SendAsync($Send, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $CT)

            While (!$Conn.IsCompleted) {
                Start-Sleep -Milliseconds 100
            }

            #Start reading the received items
            $Recv = New-Object System.ArraySegment[byte] -ArgumentList @(, $Array)
            $Conn = $WS.ReceiveAsync($Recv, $CT)

            Write-Verbose 'Triggering workflow'

            $triggerParams = @{
                UriLeaf = "machines/$ID/workflows"
                Method  = 'Post'
                Body    = @{
                    'workflowInput' = @{
                        'wsClientId' = $thisWebSocketID
                    }
                    'workflowName'  = 'testConnection'
                }
            }

            switch ($WorkflowName) {
                'GetConfig' {
                    $triggerParams.Body.workflowName = 'getTargetConfiguration'
                }

                'Provision' {
                    $triggerParams.Body.workflowName = 'provisionCertificate'
                    $triggerParams.UriLeaf = "machineidentities/$ID/workflows"
                }

                'Discover' {
                    $triggerParams.Body.workflowName = 'discoverCertificates'
                    $triggerParams.UriLeaf = "machineidentities/$ID/workflows"
                }
            }

            $null = Invoke-VenafiRestMethod @triggerParams

            While (!$Conn.IsCompleted) {
                Start-Sleep -Milliseconds 100
            }

            $response = ''
            $Recv.Array[0..($Conn.Result.Count - 1)] | ForEach-Object { $response += [char]$_ }

            Write-Verbose $response

            $responseObj = $response | ConvertFrom-Json

            $out = [pscustomobject]@{
                ID           = $ID
                WorkflowName = $WorkflowName
                Success      = $true
            }

            if ( $responseObj.data.result -ne $true ) {
                $out.Success = $false
                $out | Add-Member @{'Error' = $responseObj.data.result.message }
            }

            $out

        }
        finally {
            $WS.Dispose()
        }
    }
}
