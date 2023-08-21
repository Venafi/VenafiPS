function Get-VcTag {
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

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipelineByPropertyName, Position = 0)]
        [string] $Name,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch] $All,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'
    }

    process {

        if ( $PSCmdlet.ParameterSetName -eq 'All' ) {
            $values = Invoke-VenafiRestMethod -UriLeaf 'tags/values' | Select-Object -ExpandProperty values
            $response = Invoke-VenafiRestMethod -UriLeaf 'tags' | Select-Object -ExpandProperty tags
        }
        else {
            $response = Invoke-VenafiRestMethod -UriLeaf "tags/$Name"
            $values = Invoke-VenafiRestMethod -UriLeaf "tags/$Name/values" | Select-Object -ExpandProperty values
        }

        if ( $response ) {
            $response | Select-Object @{'n' = 'tagId'; 'e' = { $_.key } },
            @{
                'n' = 'value'
                'e' = {
                    $thisId = $_.id
                    , @(($values | Where-Object { $_.tagId -eq $thisId }).value)
                }
            }, * -ExcludeProperty id, name
        }
    }
}
