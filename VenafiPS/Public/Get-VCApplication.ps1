function Get-VCApplication {
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

    param (

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipelineByPropertyName)]
        [Alias('applicationId')]
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
            UriRoot = 'outagedetection/v1'
            UriLeaf = 'applications'
        }

        if ( $PSBoundParameters.ContainsKey('ID') ) {
            if ( Test-IsGuid($ID) ) {
                $guid = [guid] $ID
                $params.UriLeaf += "/{0}" -f $guid.ToString()
            }
            else {
                # search by name
                $params.UriLeaf += "/name/$ID"
            }
        }

        try {
            $response = Invoke-VenafiRestMethod @params
        }
        catch {
            if ( $_.Exception.Response.StatusCode.value__ -eq 404 ) {
                # not found, return nothing
                return
            }
            else {
                throw $_
            }
        }

        if ( $response.PSObject.Properties.Name -contains 'applications' ) {
            $applications = $response | Select-Object -ExpandProperty applications
        }
        else {
            $applications = $response
        }

        if ( $applications ) {
            $applications | Select-Object @{'n' = 'applicationId'; 'e' = { $_.Id }},
            @{
                'n' = 'certificateIssuingTemplate'
                'e' = {
                    $_.certificateIssuingTemplateAliasIdMap.psobject.Properties | Select-Object name, @{'n' = 'id'; 'e' = { $_.Value } }
                }
            }, * -ExcludeProperty Id, certificateIssuingTemplateAliasIdMap
        }
    }
}
