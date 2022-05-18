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

    [CmdletBinding()]

    param (

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

        $response = Invoke-VenafiRestMethod @params

        if ( $response.certificateissuingtemplates ) {
            $response.certificateissuingtemplates |
            Select-Object -Property @{'n' = 'certificateIssuingTemplateId'; 'e' = { $_.id } }, * -ExcludeProperty id
        }

    }
}
