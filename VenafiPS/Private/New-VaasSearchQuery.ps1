function New-VaasSearchQuery {
    <#
    .SYNOPSIS
        Build body for various vaas api calls

    .DESCRIPTION
        Build body for various api calls, typically for searching, eg. certificates, logs.

    .PARAMETER Filter
        Array or multidimensional array of fields and values to filter on.
        Each array should be of the format @('operator', @(field, comparison operator, value), @(field2, comparison operator2, value2)).
        Nested filters are supported.
        For a complete list of comparison operators, see https://docs.venafi.cloud/api/about-api-search-operators/.

    .PARAMETER Order
        Array or multidimensional array of fields to Order on.
        Each array should be of the format @(field, asc/desc).
        If just the field name is provided, ascending will be used.

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

    .OUTPUTS
    Hashtable
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'No state is actually changing')]

    [CmdletBinding(SupportsPaging)]
    [OutputType([Hashtable])]

    param(

        [parameter()]
        [System.Collections.ArrayList] $Filter,

        [parameter()]
        [psobject[]] $Order

    )

    begin {

        $operators = 'EQ', 'FIND', 'GT', 'GTE', 'IN', 'LT', 'LTE', 'MATCH'

        $query = @{
            'expression' = @{}
            'ordering'   = @{}
            'paging'     = @{}
        }

        # page size limit from vaas is 1000
        if ($PSBoundParameters.ContainsKey('First') -and $PSCmdlet.PagingParameters.First -le 1000) {
            $query.paging.Add('pageSize', $PSCmdlet.PagingParameters.First)
        } else {
            $query.paging.Add('pageSize', 1000)
        }
        $query.paging.Add('pageNumber', 0)

        function New-VaasExpression {
            [CmdletBinding()]
            param (
                [parameter()]
                [psobject] $Filter
            )

            $loopFilter = $Filter
            $operator = $null

            # first item may be the operator or a filter
            # if so, pull it off the list and process the rest
            if ($Filter[0].GetType().Name -eq 'String' -and $Filter[0] -in 'AND', 'OR') {
                $operator = $Filter[0].ToUpper()
                $loopFilter = $Filter | Select-Object -Skip 1
                $loopFilter = @(, $loopFilter)
            }

            $operands = $loopFilter | ForEach-Object {
                $thisItem = $_
                if ( $thisItem.count -eq 3 -and -not ($thisItem | ForEach-Object { if ($_.GetType().Name -eq 'Object[]') { 'array' } })) {
                    $newOperand = @{
                        'field'    = $thisItem[0]
                        'operator' = $thisItem[1].ToUpper()
                    }

                    # handle different value types
                    # note the use of property 'values' for an array, eg. when the operator is find, in, match
                    switch ($thisItem[2].GetType().Name) {
                        'DateTime' {
                            $newOperand.Add('value', ($thisItem[2] | ConvertTo-UtcIso8601))
                        }

                        'String' {
                            $newOperand.Add('value', $thisItem[2])
                        }

                        Default {
                            # we have a list
                            $newOperand.Add('values', $thisItem[2])
                        }
                    }

                    $newOperand
                } else {
                    New-VaasExpression -Filter $thisItem
                }

            }
            if ( $operator ) {
                @{
                    'operator' = $operator
                    'operands' = @($operands)
                }
            } else {
                $operands
            }
        }
    }

    process {

        if ( $Filter ) {
            $thisFilter = @(, $Filter)
            $query.expression = New-VaasExpression -Filter $thisFilter
        }


        if ( $Order ) {
            $query.ordering.Add('orders', @())

            @($Order) | ForEach-Object {
                $thisOrder = $_
                switch ($thisOrder.GetType().Name) {
                    'String' {
                        $query.ordering.orders += @{
                            'field'     = $thisOrder
                            'direction' = 'ASC'
                        }
                    }

                    'HashTable' {
                        $thisOrder.GetEnumerator() | ForEach-Object {

                            if ( $_.Value -notin 'asc', 'desc' ) {
                                throw ('Invalid order direction, {0}.  Provide either ''asc'' or ''desc''' -f $_.Value)
                            }

                            $query.ordering.orders += @{
                                'field'     = $_.Key
                                'direction' = $_.Value.ToUpper()
                            }
                        }
                    }

                    Default {
                        throw 'Invalid format for Order'
                    }
                }
            }
        }
        $query
    }
}