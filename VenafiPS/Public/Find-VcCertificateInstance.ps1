function Find-VcCertificateInstance {
    <#
    .SYNOPSIS
    Find certificate requests

    .DESCRIPTION
    Find certificate requests

    .PARAMETER Filter
    Array or multidimensional array of fields and values to filter on.
    Each array should be of the format @('operator', @(field, comparison operator, value), @(field2, comparison operator2, value2)).
    Nested filters are supported.
    For a complete list of comparison operators, see https://docs.venafi.cloud/api/about-api-search-operators/.
    To see which fields you can search on, execute Find-VcCertificateInstance -First 1.

    .PARAMETER Order
    Array of fields to order on.
    For each item in the array, you can provide a field name by itself; this will default to ascending.
    You can also provide a hashtable with the field name as the key and either asc or desc as the value.

    .PARAMETER First
    Only retrieve this many records

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .OUTPUTS

    #>

    [CmdletBinding(DefaultParameterSetName = 'All')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'Filter')]
        [System.Collections.ArrayList] $Filter,

        [parameter()]
        [psobject[]] $Order,

        [Parameter(ParameterSetName = 'All')]
        [string] $HostName,

        [Parameter(ParameterSetName = 'All')]
        [ValidateScript({
                try {
                    [ipaddress] $_
                    $true
                }
                catch {
                    $false
                }
            })
        ]
        [string] $IpAddress,

        [Parameter(ParameterSetName = 'All')]
        [int] $Port,

        [Parameter()]
        [int] $First,

        [Parameter()]
        [psobject] $VenafiSession
    )

    $params = @{
        Type = 'CertificateInstance'
    }

    if ( $PSCmdlet.ParameterSetName -eq 'Filter' ) {
        $params.Filter = $Filter
        if ( $Order ) { $params.Order = $Order }
    }
    else {
        $newFilter = [System.Collections.ArrayList]@('AND')

        switch ($PSBoundParameters.Keys) {
            'HostName' { $null = $newFilter.Add(@('hostname', 'EQ', $HostName)) }
            'IpAddress' { $null = $newFilter.Add(@('ipAddress', 'EQ', $IpAddress)) }
            'Port' { $null = $newFilter.Add(@('port', 'EQ', $Port.ToString())) }
        }

        if ( $newFilter.Count -gt 1 ) { $params.Filter = $newFilter }
    }

    Find-VcObject @params
}