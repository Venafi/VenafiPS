function Find-VcLog {
    <#
    .SYNOPSIS
    Find log entries on TLSPC

    .DESCRIPTION
    Find log entries

    .PARAMETER Filter
    Array or multidimensional array of fields and values to filter on.
    Each array should be of the format @('operator', @(field, comparison operator, value), @(field2, comparison operator2, value2)).
    Nested filters are supported.
    For a complete list of comparison operators, see https://docs.venafi.cloud/api/about-api-search-operators/.

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
    PSCustomObject
        activityLogId
        activityDate
        activityType
        activityName
        criticality
        message
        payload
        companyId

    .EXAMPLE
    Find-VcLog -First 10

    Get the most recent 10 log items

    .EXAMPLE
    Find-VcLog -Filter @('activityType', 'eq', 'Authentication')

    Filter log results

    .EXAMPLE
    Find-VcLog -Filter @('and', @('activityDate', 'gt', (get-date).AddMonths(-1)), @('or', @('message', 'find', 'greg@venafi.com'), @('message', 'find', 'bob@venafi.com')), @('activityType','eq','Authentication'))

    Advanced filtering of results.
    This filter will find authentication log entries by 1 of 2 people within the last month.

    .EXAMPLE
    Find-VcLog -Filter @('activityType', 'eq', 'Authentication') -Order 'activityDate'

    Filter log results and order them.
    By default, order will be ascending.

    .EXAMPLE
    Find-VcLog -Filter @('activityType', 'eq', 'Authentication') -Order @{'activityDate'='desc'}

    Filter log results and order them descending

    .EXAMPLE
    Find-VcLog -Filter @('activityType', 'eq', 'Authentication') -Order @{'activityDate'='desc'}, 'criticality'

    Filter log results and order them by multiple fields

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?configUrl=/v3/api-docs/swagger-config#/Activity%20Logs/activitylogs_getByExpression

    #>

    [CmdletBinding()]

    param (

        [Parameter()]
        [System.Collections.ArrayList] $Filter,

        [parameter()]
        [psobject[]] $Order,

        [Parameter()]
        [int] $First,

        [Parameter()]
        [psobject] $VenafiSession
    )

    Find-VcObject -Type ActivityLog @PSBoundParameters
}