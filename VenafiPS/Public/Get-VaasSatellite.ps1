function Get-VaasSatellite {
    <#
    .SYNOPSIS
    Get VSatellite info

    .DESCRIPTION
    Get info for either a specific VSatellite or all.
    There is an option to also include the encryption key and algorithm.

    .PARAMETER ID
    Name or uuid to get info for a specific VSatellite

    .PARAMETER All
    Get all VSatellites

    .PARAMETER IncludeKey
    Include the encryption key and algorithm

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .INPUTS
    ID

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-VaasSatellite -ID 'VSatellite Hub 0001'

    Get info for a specific VSatellite by name

    .EXAMPLE
    Get-VaasSatellite -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'

    Get info for a specific VSatellite

    .EXAMPLE
    Get-VaasSatellite -All

    Get info for all VSatellites

    .EXAMPLE
    Get-VaasSatellite -All -IncludeKey

    Get info for VSatellites including the encryption key and algorithm

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Get-VaasSatellite/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VaasSatellite.ps1

    .LINK
    https://developer.venafi.com/tlsprotectcloud/reference/edgeinstances_getall

    .LINK
    https://developer.venafi.com/tlsprotectcloud/reference/edgeencryptionkeys_getall
    #>

    [CmdletBinding(DefaultParameterSetName = 'ID')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('applicationId')]
        [string] $ID,

        [Parameter(ParameterSetName = 'All', Mandatory)]
        [switch] $All,

        [Parameter()]
        [switch] $IncludeKey,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Get'
        }

        # get all keys once and perform lookup later
        if ( $IncludeKey ) {
            $allKeys = Invoke-VenafiRestMethod -UriLeaf 'edgeencryptionkeys' -VenafiSession $VenafiSession | Select-Object -ExpandProperty encryptionKeys
        }
    }

    process {

        if ( $PSCmdlet.ParameterSetName -eq 'All' ) {
            $params.UriLeaf = 'edgeinstances'
            $response = Invoke-VenafiRestMethod @params
        }
        else {
            if ( [guid]::TryParse($ID, $([ref][guid]::Empty)) ) {
                $guid = [guid] $ID
                $params.UriLeaf = 'edgeinstances/{0}' -f $guid.ToString()
                $response = Invoke-VenafiRestMethod @params
            }
            else {
                # assume team name
                $params.UriLeaf = 'edgeinstances'
                $allInstances = Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty edgeinstances
                $response = $allInstances | Where-Object { $_.name -eq $ID }
            }
        }

        if ( -not $response ) {
            continue
        }

        if ( $response.PSObject.Properties.Name -contains 'edgeinstances' ) {
            $thisInstance = $response | Select-Object -ExpandProperty edgeinstances
        }
        else {
            $thisInstance = $response
        }

        $thisInstance | Select-Object *,
        @{
            'n' = 'vsatelliteId'
            'e' = {
                $_.Id
            }
        },
        @{
            'n' = 'encryptionKey'
            'e' = {
                if ( $IncludeKey ) {
                    $thisId = $_.encryptionKeyId
                    ($allKeys | Where-Object { $_.id -eq $thisId }).key
                }
            }
        },
        @{
            'n' = 'encryptionKeyAlgorithm'
            'e' = {
                if ( $IncludeKey ) {
                    $thisId = $_.encryptionKeyId
                    ($allKeys | Where-Object { $_.id -eq $thisId }).KeyAlgorithm
                }
            }
        } -ExcludeProperty Id
    }
}
