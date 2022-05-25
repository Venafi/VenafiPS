function Get-VaasIssuingTemplate {
    <#
    .SYNOPSIS
    Get issuing templates

    .DESCRIPTION
    Get info for either a specific template or all templates.
    Venafi as a Service only, not for TPP.

    .PARAMETER ID
    Id to get info for a specific template

    .PARAMETER All
    Get all templates

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .INPUTS
    ID

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-VaasIssuingTemplate -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'

    Get info for a specific template

    .EXAMPLE
    Get-VaasIssuingTemplate -All

    Get info for all templates

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Get-VaasIssuingTemplate/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VaasIssuingTemplate.ps1

    #>

    [CmdletBinding(DefaultParameterSetName = 'ID')]

    param (
        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('certificateIssuingTemplateId')]
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
            UriLeaf       = 'certificateissuingtemplates'
        }
    }

    process {

        if ( $PSBoundParameters.ContainsKey('ID') ) {
            $params.UriLeaf += "/$ID"
        }

        $response = Invoke-VenafiRestMethod @params

        if ( $response.PSObject.Properties.Name -contains 'certificateissuingtemplates' ) {
            $templates = $response | Select-Object -ExpandProperty certificateissuingtemplates
        } else {
            $templates = $response
        }

        if ( $templates ) {
            $templates | Select-Object -Property @{'n' = 'certificateIssuingTemplateId'; 'e' = { $_.id } }, * -ExcludeProperty id
        }

    }
}
