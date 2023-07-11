function Invoke-VaasWorkflow {
    <#
    .SYNOPSIS
        Start a machine or machine identity workflow
    .DESCRIPTION
        Start a workflow to either test
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
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

    begin {

    }

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

    end {

    }
}
