function Get-VcConnector {
    <#
    .SYNOPSIS
    Get connector/webhook info

    .DESCRIPTION
    Get 1 or all connector/webhook info

    .PARAMETER ID
    Connector ID or name

    .PARAMETER All
    Get all connectors

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    ID

    .EXAMPLE
    Get-VcConnector -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' | ConvertTo-Json

    {
        "connectorId": "a7ddd210-0a39-11ee-8763-134b935c90aa",
        "name": "ServiceNow-expiry,
        "properties": {
            "connectorKind": "WEBHOOK",
            "filter": {
                "filterType": "EXPIRATION",
                "applicationIds": []
            },
            "target": {
                "type": "generic",
                "connection": {
                    "secret": "MySecret",
                    "url": "https://instance.service-now.com/api/company/endpoint"
                }
            }
        }
    }

    Get a single object by ID

    .EXAMPLE
    Get-VcConnector -ID 'My Connector'

    Get a single object by name.  The name is case sensitive.

    .EXAMPLE
    Get-VcConnector -All

    Get all connectors

    #>

    [CmdletBinding(DefaultParameterSetName = 'ID')]
    [Alias('Get-VaasConnector')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('connectorId')]
        [string] $ID,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch] $All,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TLSPC'
    }

    process {

        $params = @{
            UriLeaf = 'connectors'
        }

        if ( $PSBoundParameters.ContainsKey('ID') ) {
            if ( Test-IsGuid($ID) ) {
                $params.UriLeaf += "/{0}" -f $ID
            }
            else {
                # search by name
                return Get-VcConnector -All | Where-Object { $_.name -eq $ID }
            }
        }

        $response = Invoke-VenafiRestMethod @params

        if ( $response.PSObject.Properties.Name -contains 'connectors' ) {
            $connectors = $response | Select-Object -ExpandProperty connectors
        }
        else {
            $connectors = $response
        }

        if ( $connectors ) {
            $connectors | Select-Object @{ 'n' = 'connectorId'; 'e' = { $_.Id } }, * -ExcludeProperty Id
        }
    }
}
