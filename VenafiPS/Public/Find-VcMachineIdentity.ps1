function Find-VcMachineIdentity {
    <#
    .SYNOPSIS
    Find machine identities

    .DESCRIPTION
    Find machine identities

    .PARAMETER Filter
    Array or multidimensional array of fields and values to filter on.
    Each array should be of the format @('operator', @(field, comparison operator, value), @(field2, comparison operator2, value2)).
    Nested filters are supported.
    For a complete list of comparison operators, see https://docs.venafi.cloud/api/about-api-search-operators/.

    .PARAMETER Order
    Array of fields to order on.
    For each item in the array, you can provide a field name by itself; this will default to ascending.
    You can also provide a hashtable with the field name as the key and either asc or desc as the value.

    .PARAMETER Status
    Either DISCOVERED, VALIDATED, or INSTALLED

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
        [ValidateSet('DISCOVERED', 'VALIDATED', 'INSTALLED')]
        [string] $Status,

        [Parameter()]
        [int] $First,

        [Parameter()]
        [psobject] $VenafiSession
    )

    Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'

    $params = @{
        Type  = 'MachineIdentity'
        First = $First
    }

    if ( $Order ) { $params.Order = $Order }

    if ( $PSCmdlet.ParameterSetName -eq 'Filter' ) {
        $params.Filter = $Filter
    }
    else {
        $newFilter = [System.Collections.ArrayList]@('AND')

        switch ($PSBoundParameters.Keys) {
            'Status' { $null = $newFilter.Add(@('status', 'EQ', $Status.ToUpper())) }
        }

        if ( $newFilter.Count -gt 1 ) { $params.Filter = $newFilter }
    }

    Find-VcObject @params
}