function Remove-VaasConnector {
    <#
    .SYNOPSIS
    Remove a VaaS connector

    .DESCRIPTION
    Remove a VaaS connector

    .PARAMETER ID
    Guid of the connector

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .INPUTS
    ID

    .OUTPUTS
    None

    .EXAMPLE
    Remove-VaasConnector -ID $my_guid

    Remove a connector

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Remove-VaasConnector/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-VaasConnector.ps1

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=connectors-service#/Connectors/connectors_delete

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('connectorId')]
        [guid] $ID,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        Write-Warning 'Remove-VaasConnector will soon be deprecated.  Please use Remove-VaasObject -ConnectorID.'

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Delete'
            UriRoot       = 'v1'
        }
    }

    process {

        $params.UriLeaf = "connectors/$ID"

        if ( $PSCmdlet.ShouldProcess($ID, 'Remove connector') ) {
            Invoke-VenafiRestMethod @params
        }
    }
}
