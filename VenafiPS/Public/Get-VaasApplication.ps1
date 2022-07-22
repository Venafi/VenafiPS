function Get-VaasApplication {
    <#
    .SYNOPSIS
    Get application info

    .DESCRIPTION
    Get info for either a specific application or all applications.  Venafi as a Service only, not for TPP.

    .PARAMETER ID
    Name or Guid to get info for a specific application

    .PARAMETER All
    Get all applications

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .INPUTS
    ID

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-VaasApplication -ID 'MyApp'

    Get info for a specific application by name

    .EXAMPLE
    Get-VaasApplication -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'

    Get info for a specific application

    .EXAMPLE
    Get-VaasApplication -All

    Get info for all applications

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Get-VaasApplication/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VaasApplication.ps1

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Applications/applications_getAll

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Applications/applications_getById
    #>

    [CmdletBinding(DefaultParameterSetName = 'ID')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('applicationId')]
        [string] $ID,

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
            UriRoot       = 'outagedetection/v1'
            UriLeaf       = 'applications'
        }
    }

    process {

        if ( $PSBoundParameters.ContainsKey('ID') ) {
            if ( [guid]::TryParse($ID, $([ref][guid]::Empty)) ) {
                $guid = [guid] $ID
                $params.UriLeaf += "/{0}" -f $guid.ToString()
            } else {
                # search by name
                $params.UriLeaf += "/name/$ID"
            }
        }

        $response = Invoke-VenafiRestMethod @params

        if ( $response.PSObject.Properties.Name -contains 'applications' ) {
            $applications = $response | Select-Object -ExpandProperty applications
        } else {
            $applications = $response
        }

        if ( $applications ) {
            $applications | Select-Object *,
            @{
                'n' = 'applicationId'
                'e' = {
                    $_.Id
                }
            } -ExcludeProperty Id
        }
    }
}
