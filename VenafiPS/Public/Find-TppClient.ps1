<#
.SYNOPSIS
Get information about registered Server Agents or Agentless clients

.DESCRIPTION
Get information about registered Server Agent or Agentless clients.

.PARAMETER ClientType
The client type.
Allowed values include VenafiAgent, AgentJuniorMachine, AgentJuniorUser, Portal, Agentless, PreEnrollment, iOS, Android

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
None

.OUTPUTS
PSCustomObject

.EXAMPLE
Find-TppClient
Find all clients

.EXAMPLE
Find-TppClient -ClientType Portal
Find clients with the specific type

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppClient/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppClient.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-ClientDetails.php

#>
function Find-TppClient {

    [CmdletBinding()]

    param (
        [Parameter()]
        [ValidateSet('VenafiAgent', 'AgentJuniorMachine', 'AgentJuniorUser', 'Portal', 'Agentless', 'PreEnrollment', 'iOS', 'Android')]
        [String] $ClientType,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Get'
            UriLeaf       = 'Client/Details/'
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