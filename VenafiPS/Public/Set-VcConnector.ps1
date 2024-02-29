function Set-VcConnector {
    <#
    .SYNOPSIS
    Update an existing connector

    .DESCRIPTION
    Update a new machine, CA, TPP, or credential connector.
    This will update the revision of the connector.

    .PARAMETER ManifestPath
    Path to an updated manifest for an existing connector.
    Ensure the manifest has the deployment element which is not needed when testing in the simulator.
    See https://github.com/Venafi/vmware-avi-connector?tab=readme-ov-file#manifest for details.

    .PARAMETER Connector
    Connector ID to update.
    If not provided, the ID will be looked up by the name in the manifest.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    Connector

    .EXAMPLE
    Set-VcConnector -ManifestPath '/tmp/manifest_v2.json'

    Update an existing connector with the same name as in the manifest

    .EXAMPLE
    Set-VcConnector -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -ManifestPath '/tmp/manifest_v2.json'

    Update an existing connector utilizing a specific connector ID

    #>

    [CmdletBinding(SupportsShouldProcess)]

    param (

        [Parameter(Mandatory)]
        [ValidateScript(
            {
                if ( -not ( Test-Path $_ ) ) {
                    throw "The manifest path $_ cannot be found"
                }
                $true
            }
        )]
        [string] $ManifestPath,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('connectorId', 'ID')]
        [ValidateScript(
            {
                if ( -not (Test-IsGuid -InputObject $_ ) ) {
                    throw "$_ is not a valid connector id format"
                }
                $true
            }
        )]
        [string] $Connector,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'
    }

    process {

        $manifestObject = Get-Content -Path $ManifestPath -Raw | ConvertFrom-Json

        # if connector is provided, update that specific one
        # if not, use the name from the manifest to find the existing connector id

        if ( $Connector ) {
            $connectorId = $Connector
        }
        else {
            $thisConnector = Get-VcConnector -ID $manifestObject.name
            if ( -not $thisConnector ) {
                throw ('An existing connector with the name {0} was not found' -f $manifestObject.name)
            }
            $connectorId = $thisConnector.connectorId
        }

        # ensure deployment is provided which is not needed during simulator testing
        if ( -not $manifestObject.deployment ) {
            throw 'A deployment element was not found in the manifest.  See https://github.com/Venafi/vmware-avi-connector?tab=readme-ov-file#manifest for details.'
        }

        $params = @{
            Method  = 'Patch'
            UriLeaf = "plugins/$connectorId"
            Body    = @{
                manifest = $manifestObject
            }
        }

        if ( $PSCmdlet.ShouldProcess($manifestObject.name, 'Update connector') ) {
            $null = Invoke-VenafiRestMethod @params
        }
    }
}
