function New-VcConnector {
    <#
    .SYNOPSIS
    Create a new connector

    .DESCRIPTION
    Create a new machine, CA, TPP, or credential connector

    .PARAMETER ManifestPath
    Path to an existing manifest.
    Ensure the manifest has the deployment element which is not needed when testing in the simulator.
    See https://github.com/Venafi/vmware-avi-connector?tab=readme-ov-file#manifest for details.

    .PARAMETER PassThru
    Return newly created connector object

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .OUTPUTS
    PSCustomObject, if PassThru provided

    .EXAMPLE
    New-VcConnector -ManifestPath '/tmp/manifest.json'

    Create a new connector

    .EXAMPLE
    New-VcConnector -ManifestPath '/tmp/manifest.json' -PassThru

    Create a new connector and return the newly created connector object

    .LINK
    https://developer.venafi.com/tlsprotectcloud/reference/post-v1-plugins

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

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'
    }

    process {

        $manifestObject = Get-Content -Path $ManifestPath -Raw | ConvertFrom-Json
        $connectorType = $manifestObject.pluginType

        # ensure deployment is provided which is not needed during simulator testing
        if ( -not $manifestObject.deployment ) {
            throw 'A deployment element was not found in the manifest.  See https://github.com/Venafi/vmware-avi-connector?tab=readme-ov-file#manifest for details.'
        }

        $params = @{
            Method  = 'Post'
            UriLeaf = 'plugins'
            Body    = @{
                manifest   = $manifestObject
                pluginType = $connectorType
            }
        }

        if ( $PSCmdlet.ShouldProcess($manifestObject.name, 'Create connector') ) {

            try {
                $response = Invoke-VenafiRestMethod @params
                if ( $PassThru ) {
                    $response.plugins | Select-Object @{ 'n' = 'connectorId'; 'e' = { $_.Id } }, @{ 'n' = 'connectorType'; 'e' = { $_.pluginType } }, * -ExcludeProperty Id, pluginType
                }
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }
    }
}