<#
.SYNOPSIS
Get information about registered Server Agents or Agentless clients

.DESCRIPTION
Get information about registered Server Agent or Agentless clients.

.PARAMETER ClientType
The client type.
Allowed values include VenafiAgent, AgentJuniorMachine, AgentJuniorUser, Portal, Agentless, PreEnrollment, iOS, Android

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
None

.OUTPUTS
PSCustomObject with the following properties:
- ClientId
- ClientType
- FQDN
- OsName
- Username

.EXAMPLE
Find-TppClient
Find all clients

.EXAMPLE
Find-TppClient -ClientType Portal
Find clients with the specific type

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppClient/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Public/Find-TppClient.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Client.php

#>
function Find-TppClient {

    [CmdletBinding()]

    param (
        [Parameter()]
        [ValidateSet('VenafiAgent', 'AgentJuniorMachine', 'AgentJuniorUser', 'Portal', 'Agentless', 'PreEnrollment', 'iOS', 'Android')]
        [String] $ClientType,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('tpp') | Out-Null

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Get'
            UriLeaf       = 'Client/'
            Body          = @{ }
        }

        if ( $ClientType ) {
            $params.Body.ClientType = $ClientType
        }

        # if no filters provided, get all
        if ( $params.Body.Count -eq 0 ) {
            $params.Body.LastSeenOnLess = (Get-Date) | ConvertTo-UtcIso8601
        }
    }

    process {
        Invoke-VenafiRestMethod @params
    }
}