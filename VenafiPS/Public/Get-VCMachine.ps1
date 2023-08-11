function Get-VCMachine {
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
    [Alias('Get-VaasMachine')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipelineByPropertyName)]
        [Alias('machineId')]
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

        if ( $PSCmdlet.ParameterSetName -eq 'All' ) {

            $params = @{
                InputObject = Find-VaasObject -Type Machine
                ScriptBlock = { $PSItem | Get-VaasObject }
            }
            return Invoke-VenafiParallel @params
        }
        else {
            if ( Test-IsGuid($ID) ) {
                $guid = [guid] $ID
                try {
                    $response = Invoke-VenafiRestMethod -UriLeaf ('machines/{0}' -f $guid.ToString())
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
            }
            else {
                # no lookup by name directly.  search for it and then get details
                Find-VaasObject -Type 'Machine' -Name $ID | Get-VaasObject
            }
        }

        if ( $response ) {
            $response | Select-Object @{ 'n' = 'machineId'; 'e' = { $_.Id } }, * -ExcludeProperty Id
        }
    }
}
