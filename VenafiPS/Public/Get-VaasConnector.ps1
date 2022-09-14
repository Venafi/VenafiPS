function Get-VaasConnector {
    <#
    .SYNOPSIS
    Get VaaS connectors

    .DESCRIPTION
    Get 1 or all VaaS connectors

    .PARAMETER ID
    Guid for the specific connector to retrieve

    .PARAMETER All
    Get all connectors

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .INPUTS
    ID

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-VaasConnector -ID $my_guid

    Get info for a specific connector

    .EXAMPLE
    Get-VaasConnector -All

    Get info for all connectors

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Get-VaasConnector/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VaasConnector.ps1

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=connectors-service#/Connectors/connectors_getAll

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=connectors-service#/Connectors/connectors_getById
    #>

    [CmdletBinding(DefaultParameterSetName = 'ID')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('connectorId')]
        [guid] $ID,

        [Parameter(ParameterSetName = 'All', Mandatory)]
        [switch] $All,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Get'
            UriRoot       = 'v1'
            UriLeaf       = 'connectors'
        }
    }

    process {

        if ( $PSBoundParameters.ContainsKey('ID') ) {
            $params.UriLeaf += "/{0}" -f $ID
            # if ( [guid]::TryParse($ID, $([ref][guid]::Empty)) ) {
            #     $guid = [guid] $ID
            # }
        }

        $response = Invoke-VenafiRestMethod @params

        if ( $response.PSObject.Properties.Name -contains 'connectors' ) {
            $connectors = $response | Select-Object -ExpandProperty connectors
        } else {
            $connectors = $response
        }

        if ( $connectors ) {
            $connectors | Select-Object *,
            @{
                'n' = 'connectorId'
                'e' = {
                    $_.Id
                }
            } -ExcludeProperty Id
        }
    }
}
