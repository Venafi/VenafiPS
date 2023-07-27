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

    .PARAMETER Workflow
    The name of the workflow to trigger.
    Valid values are 'Test', 'GetConfig', 'Provision', or 'Discover'.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .EXAMPLE
    Invoke-VaasWorkflow -ID '1345baf1-fc56-49b7-aa03-78e35bfe0a1a' -Workflow 'Provision'

    ID                                   Success WorkflowName WorkflowID
    --                                   ------- ------------ ----------
    1345baf1-fc56-49b7-aa03-78e35bfe0a1a    True Provision    345b9d33-8c8a-4d4b-9fea-124f3a72f957

    Trigger provisioning

    .EXAMPLE
    Invoke-VaasWorkflow -ID '1345baf1-fc56-49b7-aa03-78e35bfe0a1a' -Workflow 'Test'

    ID               : 1345baf1-fc56-49b7-aa03-78e35bfe0a1a
    Success          : False
    WorkflowName     : Test
    WorkflowID       : 345b9d33-8c8a-4d4b-9fea-124f3a72f957
    Error            : failed to connect to Citrix ADC: [ERROR] nitro-go: Failed to create resource of type login, name=login, err=failed: 401 Unauthorized ({ "errorcode": 354,
                       "message": "Invalid username or password", "severity": "ERROR" })

    Trigger test connection, but it failed

    .EXAMPLE
    Find-VaasObject -Type MachineIdentity -Filter @('and', @('certificateValidityEnd', 'lt', (get-date).AddDays(30)), @('certificateValidityEnd', 'gt', (get-date))) | ForEach-Object {
        $renewResult = $_ | Invoke-VenafiCertificateAction -Renew
        # optionally add renew validation
        $_ | Invoke-VaasWorkflow -Workflow 'Provision'
    }

    ID                                   Success WorkflowName WorkflowID
    --                                   ------- ------------ ----------
    1345baf1-fc56-49b7-aa03-78e35bfe0a1a    True Provision    345b9d33-8c8a-4d4b-9fea-124f3a72f957
    89fa4370-2026-11ee-8a18-ff9579bb988e    True Provision    7598917c-7027-4927-be73-e592bcc4c567

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
        [string] $Workflow = 'Test',

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
            $Size = 2048
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
                UriLeaf       = "machines/$ID/workflows"
                Method        = 'Post'
                Body          = @{
                    'workflowInput' = @{
                        'wsClientId' = $thisWebSocketID
                    }
                    'workflowName'  = 'testConnection'
                }
                VenafiSession = $VenafiSession
            }

            switch ($Workflow) {
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
                Success      = $true
                WorkflowName = $Workflow
                WorkflowID   = $thisWebSocketID
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
