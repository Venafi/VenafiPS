function Find-VaasMachine {
    <#
    .SYNOPSIS
    Find different objects on VaaS

    .DESCRIPTION
    Find objects of type ActivityLog, Machine, MachineIdentity, CertificateRequest, CertificateInstance on VaaS.
    Supports -First for page size and -IncludeTotalCount to retrieve all by paging.
    The max page size is 1000.
    To find certificate objects, use Find-VenafiCertificate.

    .PARAMETER Type
    Type of object to retrieve.  Can be ActivityLog, Machine, MachineIdentity, CertificateRequest, or CertificateInstance.

    .PARAMETER Filter
    Array or multidimensional array of fields and values to filter on.
    Each array should be of the format @('operator', @(field, comparison operator, value), @(field2, comparison operator2, value2)).
    Nested filters are supported.
    For a complete list of comparison operators, see https://docs.venafi.cloud/api/about-api-search-operators/.

    .PARAMETER Order
    Array of fields to order on.
    For each item in the array, you can provide a field name by itself; this will default to ascending.
    You can also provide a hashtable with the field name as the key and either asc or desc as the value.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Find-VaasObject -Type CertificateInstance

    Get first 1000 records

    .EXAMPLE
    Find-VaasObject -Type CertificateInstance -First 50

    Get first 50 records

    .EXAMPLE
    Find-VaasObject -Type CertificateInstance -First 500 -IncludeTotalCount

    Get all records paging 500 at a time

    .EXAMPLE
    Find-VaasObject -Type ActivityLog -Filter @('activityType', 'eq', 'Notifications') -First 10

    Retrieve 10 records matching the field name

    .EXAMPLE
    Find-VaasObject -Type ActivityLog -Filter @('activityType', 'eq', 'Notifications') -First 10 -Order @{'activityDate'='desc'}

    Retrieve the most recent 10 records matching the field name

    .EXAMPLE
    Find-VaasObject -Filter @('and', @('activityDate', 'gt', (get-date).AddMonths(-1)), @('or', @('userId', 'eq', 'ab0feb46-8df7-47e7-8da9-f47ab314f26a'), @('userId', 'eq', '933c28de-6352-46f3-bc12-bd96077e8eae')))

    Advanced filtering of results.  This filter will find log entries by 1 of 2 people within the last month.

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Find-VaasObject/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-VaasObject.ps1
    #>

    [CmdletBinding()]

    param (

        [Parameter()]
        [string] $MachineType,

        [Parameter()]
        [ValidateSet('DRAFT', 'VERIFIED', 'UNVERIFIED')]
        [string] $Status,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

    $params = @{
        Type          = 'Machine'
        VenafiSession = $VenafiSession
    }

    $filters = [System.Collections.Generic.List[object]]::new()

    if ( $MachineType ) {
        $filters.Add(@('machineType', 'eq', $MachineType))
    }

    if ( $Status ) {
        $filters.Add(@('status', 'eq', $Status))
    }

    if ( $filters.Count -gt 1) {
        $filters.Insert(0, 'and')
    }

    $params.Filter = $filters

    Find-VaasObject @params
}