function Get-VaasIssuingTemplate {
    <#
    .SYNOPSIS
    Get issuing templates

    .DESCRIPTION
    Get list of issuing template details

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-VaasIssuingTemplate
    Get details on all issuing templates

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
