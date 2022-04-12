<#
.SYNOPSIS
Get application info

.DESCRIPTION
Get info for either a specific application or all applications.  Venafi as a Service only, not for TPP.

.PARAMETER ApplicationId
Id to get info for a specific application

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TppServer must also be set.

.INPUTS
ApplicationId

.OUTPUTS
PSCustomObject

.EXAMPLE
Get-VaasApplication
Get info for all applications

.EXAMPLE
Get-VaasApplication -ApplicationId 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Get info for a specific application

#>
function Get-VaasApplication {

    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'Id', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [guid] $ApplicationId,

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

        if ( $ApplicationId ) {
            $params.UriLeaf += "/$ApplicationId"
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
