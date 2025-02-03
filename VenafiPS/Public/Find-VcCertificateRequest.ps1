function Find-VcCertificateRequest {
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

    .PARAMETER Order
    Array of fields to order on.
    For each item in the array, you can provide a field name by itself; this will default to ascending.
    You can also provide a hashtable with the field name as the key and either asc or desc as the value.

    .PARAMETER Status
    Request status, one of 'NEW', 'PENDING', 'PENDING_APPROVAL', 'PENDING_FINAL_APPROVAL', 'REJECTED_APPROVAL', 'REQUESTED', 'ISSUED', 'REJECTED', 'CANCELLED', 'REVOKED', 'FAILED', 'DELETED'

    .PARAMETER KeyLength
    Certificate key length

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

        [Parameter(ParameterSetName = 'All')]
        [ValidateSet('NEW', 'PENDING', 'PENDING_APPROVAL', 'PENDING_FINAL_APPROVAL', 'REJECTED_APPROVAL', 'REQUESTED', 'ISSUED', 'REJECTED', 'CANCELLED', 'REVOKED', 'FAILED', 'DELETED')]
        [string] $Status,

        [Parameter(ParameterSetName = 'All')]
        [int] $KeyLength,

        [Parameter(Mandatory, ParameterSetName = 'Filter')]
        [System.Collections.ArrayList] $Filter,

        [parameter()]
        [psobject[]] $Order,

        [Parameter()]
        [int] $First,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [psobject] $VenafiSession
    )

    Test-VenafiSession $PSCmdlet.MyInvocation

    $params = @{
        Type = 'CertificateRequest'
        First = $First
    }

    if ( $Order ) { $params.Order = $Order }

    if ( $PSCmdlet.ParameterSetName -eq 'Filter' ) {
        $params.Filter = $Filter
    }
    else {
        $newFilter = [System.Collections.Generic.List[object]]::new()
        $newFilter.Add('AND')

        switch ($PSBoundParameters.Keys) {
            'Status' { $null = $newFilter.Add(@('status', 'EQ', $Status.ToUpper())) }
            'KeyLength' { $null = $newFilter.Add(@('keyLength', 'EQ', $KeyLength.ToString())) }
        }

        if ( $newFilter.Count -gt 1 ) { $params.Filter = $newFilter }
    }

    Find-VcObject @params

}