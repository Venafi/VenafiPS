function Get-VCConnector {
    <#
    .SYNOPSIS
    Get different types of objects from VaaS

    .DESCRIPTION
    Get 1 or all objects from VaaS.
    You can retrieve teams, applications, machines, machine identities, tags, issuing templates, and vsatellites.
    Where applicable, associated additional data will be retrieved and appended to the response.
    For example, when getting tags their values will be provided.

    .PARAMETER ID
    Application ID or name

    .PARAMETER All
    Get all applications

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .INPUTS
    ID

    .EXAMPLE
    Get-VaasObject -ApplicationID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'

    Get a single object by ID

    .EXAMPLE
    Get-VaasObject -ApplicationID 'My Awesome App'

    Get a single object by name.  The name is case sensitive.

    .EXAMPLE
    Get-VaasObject -ConnectorAll | Remove-VaasObject

    Get all connectors and remove them all

    #>

    [CmdletBinding()]
    [Alias('Get-VaasConnector')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipelineByPropertyName)]
        [Alias('connectorId')]
        [string] $ID,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch] $All,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'
    }

    process {

        $params = @{
            UriLeaf = 'connectors'
        }

        if ( $PSBoundParameters.ContainsKey('ID') ) {
            if ( Test-IsGuid($ID) ) {
                $guid = [guid] $ID
                $params.UriLeaf += "/{0}" -f $guid.ToString()
            }
            else {
                # search by name
                return Get-VCConnector -All | Where-Object { $_.name -eq $ID }
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
