<#
.SYNOPSIS
Read entries from the VaaS log

.DESCRIPTION
Read entries from the VaaS log.  You can filter, order, and page the results.

.PARAMETER Filter
Array or multidimensional array of fields and values to filter on.
Each array should be of the format @('operator', @(field, comparison operator, value), @(field2, comparison operator2, value2)).
Nested filters are supported.
For a complete list of comparison operators, see https://docs.venafi.cloud/api/about-api-search-operators/.

.PARAMETER Order
Array or multidimensional array of fields to Order on.
Each array should be of the format @(field, asc/desc).
If just the field name is provided, ascending will be used.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.OUTPUTS
PSCustomObject

.EXAMPLE
Read-VaasLog
Get log entries

.EXAMPLE
Read-VaasLog -Filter @('and', @('authenticationType', 'eq', 'NONE'))
Filter log results

.EXAMPLE
Read-VaasLog -Filter @('and', @('authenticationType', 'eq', 'NONE')) -First 5
Get first 5 entries of filtered log results

.EXAMPLE
Read-VaasLog -Filter @('and', @('activityDate', 'gt', (get-date).AddMonths(-1)), @('or', @('userId', 'eq', 'ab0feb46-8df7-47e7-8da9-f47ab314f26a'), @('userId', 'eq', '933c28de-6352-46f3-bc12-bd96077e8eae')))
Advanced filtering of results.  This filter will find log entries by 1 of 2 people within the last month.

.EXAMPLE
Read-VaasLog -Filter @('and', @('authenticationType', 'eq', 'NONE')) -Order 'activityDate'
Filter log results and order them

.EXAMPLE
Read-VaasLog -Filter @('and', @('authenticationType', 'eq', 'NONE')) -Order @{'activityDate'='desc'}
Filter log results and order them descending

.LINK
https://api.venafi.cloud/webjars/swagger-ui/index.html?configUrl=/v3/api-docs/swagger-config#/Activity%20Logs/activitylogs_getByExpression

#>
function Read-VaasLog {

    [CmdletBinding(SupportsPaging)]
    [OutputType([PSCustomObject])]

    param (

        [Parameter()]
        [System.Collections.ArrayList] $Filter,

        [parameter()]
        [psobject[]] $Order,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    $VenafiSession.Validate('VaaS')

    if ( $PSBoundParameters.Keys -contains 'Skip' -or $PSBoundParameters.Keys -contains 'IncludeTotalCount' ) {
        Write-Warning '-Skip and -IncludeTotalCount not implemented yet'
    }

    $queryParams = @{
        Filter            = $Filter
        Order             = $Order
        First             = $PSCmdlet.PagingParameters.First
        Skip              = $PSCmdlet.PagingParameters.Skip
        IncludeTotalCount = $PSCmdlet.PagingParameters.IncludeTotalCount
    }

    $body = New-VaasSearchQuery @queryParams

    $params = @{
        VenafiSession = $VenafiSession
        Method        = 'Post'
        UriRoot       = 'v1'
        UriLeaf       = 'activitylogsearch'
        Body          = $body
    }

    Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty activityLogEntries
}