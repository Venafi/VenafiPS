<#
.SYNOPSIS
Read entries from the VaaS or TPP log

.DESCRIPTION
Read entries from the VaaS or TPP log.
Supports -First for paging.
Limit of 1000 records.

.PARAMETER Path
TPP.  Path to search for related records

.PARAMETER EventId
TPP.  Event ID as found in Logging->Event Definitions

.PARAMETER Severity
TPP.  Filter records by severity

.PARAMETER StartTime
TPP.  Start time of events

.PARAMETER EndTime
TPP.  End time of events

.PARAMETER Text1
TPP.  Filter matching results of Text1

.PARAMETER Text2
TPP.  Filter matching results of Text2

.PARAMETER Value1
TPP.  Filter matching results of Value1

.PARAMETER Value2
TPP.  Filter matching results of Value2

.PARAMETER Filter
VaaS.  Array or multidimensional array of fields and values to filter on.
Each array should be of the format @('operator', @(field, comparison operator, value), @(field2, comparison operator2, value2)).
Nested filters are supported.
For a complete list of comparison operators, see https://docs.venafi.cloud/api/about-api-search-operators/.

.PARAMETER Order
VaaS.  Array of fields to order on.
For each item in the array, you can provide a field name by itself; this will default to ascending.
You can also provide a hashtable with the field name as the key and either asc or desc as the value.

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
Path (for TPP)

.OUTPUTS
PSCustomObject
For TPP:
    EventId
    ClientTimestamp
    Component
    ComponentId
    ComponentSubsystem
    Data
    Grouping
    Id
    Name
    ServerTimestamp
    Severity
    SourceIP
    Text1
    Text2
    Value1
    Value2
For VaaS:
    id
    companyId
    userId
    activityDate
    authenticationType
    resourceUrl
    resourceId
    messageKey
    messageKeyKey
    messageArgs
    message

.EXAMPLE
Read-VenafiLog -First 10

Get the most recent 10 log items

.EXAMPLE
$capiObject | Read-VenafiLog

Find all events for a specific TPP object

.EXAMPLE
Read-VenafiLog -EventId '00130003'

Find all TPP events with event ID '00130003', Certificate Monitor - Certificate Expiration Notice

.EXAMPLE
Read-VenafiLog -Filter @('and', @('authenticationType', 'eq', 'NONE'))

Filter VaaS log results

.EXAMPLE
Read-VenafiLog -Filter @('and', @('authenticationType', 'eq', 'NONE')) -First 5

Get first 5 VaaS entries of filtered log results

.EXAMPLE
Read-VenafiLog -Filter @('and', @('activityDate', 'gt', (get-date).AddMonths(-1)), @('or', @('userId', 'eq', 'ab0feb46-8df7-47e7-8da9-f47ab314f26a'), @('userId', 'eq', '933c28de-6352-46f3-bc12-bd96077e8eae')))

Advanced filtering of VaaS results.  This filter will find log entries by 1 of 2 people within the last month.

.EXAMPLE
Read-VenafiLog -Filter @('and', @('authenticationType', 'eq', 'NONE')) -Order 'activityDate'

Filter VaaS log results and order them

.EXAMPLE
Read-VenafiLog -Filter @('and', @('authenticationType', 'eq', 'NONE')) -Order @{'activityDate'='desc'}

Filter VaaS log results and order them descending

.EXAMPLE
Read-VenafiLog -Filter @('and', @('authenticationType', 'eq', 'NONE')) -Order @{'activityDate'='desc'}, 'statusCode'

Filter VaaS log results and order them by multiple fields

.LINK
https://api.venafi.cloud/webjars/swagger-ui/index.html?configUrl=/v3/api-docs/swagger-config#/Activity%20Logs/activitylogs_getByExpression

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Read-TppLog/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Read-TppLog.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Log.php

#>
function Read-VenafiLog {

    [CmdletBinding(DefaultParameterSetName = 'TPP', SupportsPaging)]
    [Alias('Read-TppLog')]

    param (

        [Parameter(ParameterSetName = 'TPP', ValueFromPipelineByPropertyName)]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('DN')]
        [string] $Path,

        [Parameter(ParameterSetName = 'TPP')]
        [string] $EventId,

        [Parameter(ParameterSetName = 'TPP')]
        [TppEventSeverity] $Severity,

        [Parameter(ParameterSetName = 'TPP')]
        [DateTime] $StartTime,

        [Parameter(ParameterSetName = 'TPP')]
        [DateTime] $EndTime,

        [Parameter(ParameterSetName = 'TPP')]
        [ValidateNotNullOrEmpty()]
        [string] $Text1,

        [Parameter(ParameterSetName = 'TPP')]
        [ValidateNotNullOrEmpty()]
        [string] $Text2,

        [Parameter(ParameterSetName = 'TPP')]
        [int] $Value1,

        [Parameter(ParameterSetName = 'TPP')]
        [int] $Value2,

        [Parameter(ParameterSetName = 'VaaS')]
        [System.Collections.ArrayList] $Filter,

        [parameter(ParameterSetName = 'VaaS')]
        [psobject[]] $Order,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        $platform = Test-VenafiSession -VenafiSession $VenafiSession -PassThru

        if ( $PSBoundParameters.Keys -contains 'Skip' -or $PSBoundParameters.Keys -contains 'IncludeTotalCount' ) {
            Write-Warning '-Skip and -IncludeTotalCount not implemented yet'
        }

        if ( $platform -eq 'VaaS' ) {
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
        }
        else {

            $params = @{
                VenafiSession = $VenafiSession
                Method        = 'Get'
                UriLeaf       = 'Log/'
                Body          = @{ }
            }

            switch ($PSBoundParameters.Keys) {

                'EventId' {
                    $params.Body.Add('Id', [uint32]('0x{0}' -f $EventId))
                }

                'Severity' {
                    $params.Body.Add('Severity', $Severity)
                }

                'StartTime' {
                    $params.Body.Add('FromTime', ($StartTime | ConvertTo-UtcIso8601) )
                }

                'EndTime' {
                    $params.Body.Add('ToTime', ($EndTime | ConvertTo-UtcIso8601) )
                }

                'Text1' {
                    $params.Body.Add('Text1', $Text1)
                }

                'Text2' {
                    $params.Body.Add('Text2', $Text2)
                }

                'Value1' {
                    $params.Body.Add('Value1', $Value1)
                }

                'Value2' {
                    $params.Body.Add('Value2', $Value2)
                }

                'First' {
                    $params.Body.Add('Limit', $PSCmdlet.PagingParameters.First)
                }
            }
        }
    }

    process {

        if ( $platform -eq 'VaaS' ) {
            Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty activityLogEntries
        }
        else {

            if ( $PSBoundParameters.ContainsKey('Path') ) {
                $params.Body.Component = $Path
            }

            Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty LogEvents | Select-Object -Property @{'n' = 'EventId'; 'e' = { '{0:x8}' -f $_.Id } }, *
        }
    }
}