function Get-VcSatelliteWorker {
    <#
    .SYNOPSIS
    Get VSatellite worker info

    .DESCRIPTION
    Get 1 or more VSatellite workers, the bridge between a vsatellite and ADCS

    .PARAMETER ID
    VSatellite worker ID

    .PARAMETER All
    Get all VSatellite workers

    .PARAMETER VSatelliteID
    Get workers associated with a specific VSatellite

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    ID, VSatelliteID

    .EXAMPLE
    Get-VcSatelliteWorker -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'

    vsatelliteWorkerId : 5df78790-a155-11ef-a5a8-8f3513444123
    companyId          : 09b24f81-b22b-11ea-91f3-123456789098
    host               : 1.2.3.4
    port               : 555
    pairingCode        : a138fe58-ecb6-45a4-a9af-01dd4d5c74d1
    pairingPublicKey   : FDww6Nml8IUFQZ56j9LRweEWoCQ1732wi/ZfZaQj+s0=
    status             : DRAFT

    Get a single worker by ID

    .EXAMPLE
    Get-VcSatelliteWorker -All

    Get all VSatellite workers

    .EXAMPLE
    Get-VcSatelliteWorker -VSatelliteID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f3'

    Get all workers associated with a specific VSatellite

    #>

    [CmdletBinding()]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('vsatelliteWorkerId')]
        [string] $ID,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch] $All,

        [Parameter(Mandatory, ParameterSetName = 'VSatellite', ValueFromPipelineByPropertyName)]
        [string] $VSatellite,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'
    }

    process {

        switch ($PSCmdlet.ParameterSetName) {
            'All' {
                $response = Invoke-VenafiRestMethod -UriLeaf 'edgeworkers' | Select-Object -ExpandProperty edgeWorkers
            }

            'ID' {
                $guid = [guid] $ID
                $response = Invoke-VenafiRestMethod -UriLeaf ('edgeworkers/{0}' -f $guid.ToString())
            }

            'VSatellite' {
                $vsatelliteID = Get-VcSatellite -VSatellite $VSatellite | Select-Object -ExpandProperty vsatelliteId
                $response = Invoke-VenafiRestMethod -UriLeaf 'edgeworkers' -Body @{'edgeInstanceId' = $vsatelliteID } | Select-Object -ExpandProperty edgeWorkers
            }
        }

        if ( -not $response ) { continue }

        $response | Select-Object @{'n' = 'vsatelliteWorkerId'; 'e' = { $_.Id } }, * -ExcludeProperty Id
    }
}
