function Set-VcConnector {
    <#
    .SYNOPSIS
    Update an existing connector

    .DESCRIPTION
    Update a new machine, CA, TPP, or credential connector.
    You can either update the manifest or disable/reenable it.

    .PARAMETER ManifestPath
    Path to an updated manifest for an existing connector.
    Ensure the manifest has the deployment element which is not needed when testing in the simulator.
    See https://github.com/Venafi/vmware-avi-connector?tab=readme-ov-file#manifest for details.

    .PARAMETER Connector
    Connector ID to update.
    If not provided, the ID will be looked up by the name in the manifest.

    .PARAMETER Disable
    Disable or reenable a connector

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
    Set-VcConnector -Connector 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -ManifestPath '/tmp/manifest_v2.json'

    Update an existing connector utilizing a specific connector ID

    .EXAMPLE
    Set-VcConnector -Connector 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Disable

    Disable a connector

    .EXAMPLE
    Get-VcConnector -ID 'My connector' | Set-VcConnector -Disable

    Disable a connector by name

    .EXAMPLE
    Set-VcConnector -Connector 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Disable:$false

    Reenable a disabled connector

    #>

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Manifest')]

    param (

        [Parameter(ParameterSetName = 'Manifest', Mandatory)]
        [ValidateScript(
            {
                if ( -not ( Test-Path $_ ) ) {
                    throw "The manifest path $_ cannot be found"
                }
                $true
            }
        )]
        [string] $ManifestPath,

        [Parameter(ParameterSetName = 'Manifest', ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'Disable', Mandatory, ValueFromPipelineByPropertyName)]
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

        [Parameter(ParameterSetName = 'Disable', Mandatory)]
        [switch] $Disable,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'
    }

    process {

        switch ($PSCmdLet.ParameterSetName) {
            'Manifest' {
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

            'Disable' {

                if ( $Disable ) {
                    if ( $PSCmdlet.ShouldProcess($Connector, "Disable connector") ) {
                        $null = Invoke-VenafiRestMethod -Method 'Post' -UriLeaf "plugins/$Connector/disablements"
                    }
                }
                else {
                    $null = Invoke-VenafiRestMethod -Method 'Delete' -UriLeaf "plugins/$Connector/disablements"
                }
            }
        }
    }
}
