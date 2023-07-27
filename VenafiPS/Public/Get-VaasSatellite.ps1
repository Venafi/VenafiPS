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

    companyId                   : a05013bd-921d-440c-bc22-c9ead5c8d548
    productEntitlements         : {ANY}
    environmentId               : a05013bd-921d-440c-bc22-c9ead5c8d548
    pairingCodeId               : a05013bd-921d-440c-bc22-c9ead5c8d548
    name                        : VSatellite Hub 0001
    edgeType                    : HUB
    edgeStatus                  : ACTIVE
    clientId                    : a05013bd-921d-440c-bc22-c9ead5c8d548
    modificationDate            : 6/15/2023 11:48:40 AM
    address                     : 1.2.3.4
    deploymentDate              : 6/15/2023 11:44:14 AM
    lastSeenOnDate              : 7/13/2023 12:00:40 PM
    reconciliationFailed        : False
    encryptionKeyId             : mwU4oTet9KwTGggRfhek0UtvighIw=
    encryptionKeyDeploymentDate : 6/15/2023 11:48:40 AM
    kubernetesVersion           : v1.23.6+k3s1
    integrationServicesCount    : 0
    vsatelliteId                : a05013bd-921d-440c-bc22-c9ead5c8d548
    encryptionKey               :
    encryptionKeyAlgorithm      :

    Get info for a specific VSatellite by name

    .EXAMPLE
    Get-VaasSatellite -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'

    Get info for a specific VSatellite

    .EXAMPLE
    Get-VaasSatellite -All

    Get info for all VSatellites

    .EXAMPLE
    Get-VaasSatellite -All -IncludeKey

    companyId                   : a05013bd-921d-440c-bc22-c9ead5c8d548
    productEntitlements         : {ANY}
    environmentId               : a05013bd-921d-440c-bc22-c9ead5c8d548
    pairingCodeId               : a05013bd-921d-440c-bc22-c9ead5c8d548
    name                        : VSatellite Hub 0001
    edgeType                    : HUB
    edgeStatus                  : ACTIVE
    clientId                    : a05013bd-921d-440c-bc22-c9ead5c8d548
    modificationDate            : 6/15/2023 11:48:40 AM
    address                     : 1.2.3.4
    deploymentDate              : 6/15/2023 11:44:14 AM
    lastSeenOnDate              : 7/13/2023 12:00:40 PM
    reconciliationFailed        : False
    encryptionKeyId             : mwU4oTet9KwTGggRfhek0UtvighIw=
    encryptionKeyDeploymentDate : 6/15/2023 11:48:40 AM
    kubernetesVersion           : v1.23.6+k3s1
    integrationServicesCount    : 0
    vsatelliteId                : a05013bd-921d-440c-bc22-c9ead5c8d548
    encryptionKey               : o4aFaJUTtCydprvgRupQ1ZiY=
    encryptionKeyAlgorithm      : ED25519

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
        [Alias('vsatelliteId')]
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
            $response = Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty edgeinstances
        }
        else {
            if ( [guid]::TryParse($ID, $([ref][guid]::Empty)) ) {
                $guid = [guid] $ID
                $params.UriLeaf = 'edgeinstances/{0}' -f $guid.ToString()
                $response = Invoke-VenafiRestMethod @params
            }
            else {
                # get all and find by name since another method doesn't exist
                $params.UriLeaf = 'edgeinstances'
                $allInstances = Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty edgeinstances
                $response = $allInstances | Where-Object { $_.name -eq $ID }
            }
        }

        if ( -not $response ) {
            continue
        }

        $response | Select-Object *,
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
