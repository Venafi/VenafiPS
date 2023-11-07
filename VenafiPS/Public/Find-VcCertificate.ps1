function Find-VcCertificate {
    <#
    .SYNOPSIS
    Find certificates in TLSPC

    .DESCRIPTION
    Find certificates based on various attributes.

    .PARAMETER Filter
    Array or multidimensional array of fields and values to filter on.
    Each array should be of the format @(field, comparison operator, value).
    To combine filters, use the format @('operator', @(field, comparison operator, value), @(field2, comparison operator2, value2)).
    Nested filters are supported.
    Field names and values are case sensitive.

    Operator    |	Name                    |	Description and Usage
    -----------------------------------------------------------------
    EQ              Equal operator              The search result is equal to the specified value. Valid for numeric or Boolean fields.
    FIND            Find operator               The search result is based on the value of all or part of one or more strings. You can also use Regular Expressions (regex).
    GT              Greater than                The search result has a higher numeric value than the specified value.
    GTE             Greater than or equal to    The search result is equal or has a higher numeric value than the specified value.
    IN              In clause                   The search result matches one of the values in an array.
    LT              Less Than                   The search result has a lower value than the specified value.
    LTE             Less than or equal to       The search result is equal or less than the specified value.
    MATCH           Match operator              The search result includes a string value from the supplied list. You can also use regex for your search.

    For more info comparison operators, see https://docs.venafi.cloud/api/about-api-search-operators/.

    .PARAMETER Order
    1 or more fields to order on.
    For each item in the array, you can provide a field name by itself; this will default to ascending.
    You can also provide a hashtable with the field name as the key and either asc or desc as the value.

    .PARAMETER Name
    Certificate name to find via regex match

    .PARAMETER KeyLength
    Certificate key length

    .PARAMETER Serial
    Serial number

    .PARAMETER Fingerprint
    Fingerprint

    .PARAMETER IsSelfSigned
    Only find self signed certificates

    .PARAMETER SavedSearchName
    Find certificates based on a saved search, see https://docs.venafi.cloud/vaas/certificates/saving-certificate-filters

    .PARAMETER First
    Only retrieve this many records

    .PARAMETER ApplicationDetail
    Retrieve detailed application info.
    This will cause additional api calls to be made and take longer.

    .PARAMETER OwnerDetail
    Retrieve detailed user/team owner info.
    This will cause additional api calls to be made and take longer.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    None

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Find-VcCertificate

    Find all certificates

    .EXAMPLE
    Find-VcCertificate -First 500

    Find the first 500 certificates

    .EXAMPLE
    Find-VcCertificate -Name 'mycert.company.com'

    Find certificates matching all of part of the name

    .EXAMPLE
    Find-VcCertificate -Filter @('fingerprint', 'EQ', '075C43428E70BCF941039F54B8ED78DE4FACA87F')

    Find certificates matching a single value

    .EXAMPLE
    Find-VcCertificate -Filter ('and', @('validityEnd','GTE',(get-date)), @('validityEnd','LTE',(get-date).AddDays(30)))

    Find certificates matching multiple values.  In this case, find all certificates expiring in the next 30 days.

    .EXAMPLE
    Find-VcCertificate -Filter ('and', @('validityEnd','GTE',(get-date)), @('validityEnd','LTE',(get-date).AddDays(30))) | Invoke-VcCertificateAction -Renew

    Find all certificates expiring in the next 30 days and renew them

    .EXAMPLE
    Find-VcCertificate -ApplicatonDetail

    Include application details, not just the ID.
    This will make additional api calls and will increase the response time.

    .EXAMPLE
    Find-VcCertificate -OwnerDetail

    Include user/team owner details, not just the ID.
    This will make additional api calls and will increase the response time.

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Certificates/certificates_search_getByExpressionAsCsv

    #>

    [CmdletBinding(DefaultParameterSetName = 'All')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'Filter')]
        [System.Collections.ArrayList] $Filter,

        [Parameter(ParameterSetName = 'All')]
        [Parameter(ParameterSetName = 'Filter')]
        [psobject[]] $Order,

        [Parameter(ParameterSetName = 'All')]
        [string] $Name,

        [Parameter(ParameterSetName = 'All')]
        [int] $KeyLength,

        [Parameter(ParameterSetName = 'All')]
        [string] $Serial,

        [Parameter(ParameterSetName = 'All')]
        [string] $Fingerprint,

        [Parameter(ParameterSetName = 'All')]
        [switch] $IsSelfSigned,

        [parameter(Mandatory, ParameterSetName = 'SavedSearch')]
        [string] $SavedSearchName,

        [Parameter()]
        [switch] $ApplicationDetail,

        [Parameter()]
        [Alias('IncludeVaasOwner')]
        [switch] $OwnerDetail,

        [Parameter()]
        [int] $First,

        [Parameter()]
        [psobject] $VenafiSession
    )

    Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'

    $apps = [System.Collections.Generic.List[object]]::new()
    $appOwners = [System.Collections.Generic.List[object]]::new()

    $params = @{
        Type  = 'Certificate'
        First = $First
    }

    if ( $Order ) { $params.Order = $Order }

    switch ($PSCmdlet.ParameterSetName) {
        'Filter' {
            $params.Filter = $Filter
        }

        'All' {
            $newFilter = [System.Collections.ArrayList]@('AND')

            switch ($PSBoundParameters.Keys) {
                'Name' { $null = $newFilter.Add(@('certificateName', 'FIND', $Name)) }
                'Status' { $null = $newFilter.Add(@('certificateStatus', 'EQ', $Status.ToUpper())) }
                'KeyLength' { $null = $newFilter.Add(@('keyStrength', 'EQ', $KeyLength.ToString())) }
                'Serial' { $null = $newFilter.Add(@('serialNumber', 'EQ', $Serial)) }
                'Fingerprint' { $null = $newFilter.Add(@('fingerprint', 'EQ', $Fingerprint)) }
                'IsSelfSigned' { $null = $newFilter.Add(@('selfSigned', 'EQ', $IsSelfSigned.IsPresent.ToString())) }
            }

            if ( $newFilter.Count -gt 1 ) { $params.Filter = $newFilter }
        }

        'SavedSearch' {
            $params.SavedSearchName = $SavedSearchName
        }
    }

    $response = Find-VcObject @params

    $response | Select-Object *,
    @{
        'n' = 'application'
        'e' = {
            if ( $ApplicationDetail ) {
                foreach ($thisAppId in $_.applicationIds) {
                    $thisApp = $apps | Where-Object { $_.applicationId -eq $thisAppId }
                    if ( -not $thisApp ) {
                        $thisApp = Get-VcApplication -ID $thisAppId | Select-Object -Property * -ExcludeProperty ownerIdsAndTypes, ownership
                        $apps.Add($thisApp)
                    }
                    $thisApp
                }
            }
            else {
                $_.applicationIds
            }
        }
    },
    @{
        'n' = 'owner'
        'e' = {
            if ( $OwnerDetail ) {

                # this scriptblock requires ?ownershipTree=true be part of the url
                foreach ( $thisOwner in $_.ownership.owningContainers.owningUsers ) {
                    $thisOwnerDetail = $appOwners | Where-Object { $_.id -eq $thisOwner }
                    if ( -not $thisOwnerDetail ) {
                        $thisOwnerDetail = Get-VcIdentity -ID $thisOwner | Select-Object firstName, lastName, emailAddress,
                        @{
                            'n' = 'status'
                            'e' = { $_.userStatus }
                        },
                        @{
                            'n' = 'role'
                            'e' = { $_.systemRoles }
                        },
                        @{
                            'n' = 'type'
                            'e' = { 'USER' }
                        },
                        @{
                            'n' = 'userId'
                            'e' = { $_.id }
                        }

                        $appOwners.Add($thisOwnerDetail)

                    }
                    $thisOwnerDetail
                }

                foreach ($thisOwner in $_.ownership.owningContainers.owningTeams) {
                    $thisOwnerDetail = $appOwners | Where-Object { $_.id -eq $thisOwner }
                    if ( -not $thisOwnerDetail ) {
                        $thisOwnerDetail = Get-VcTeam -ID $thisOwner | Select-Object name, role, members,
                        @{
                            'n' = 'type'
                            'e' = { 'TEAM' }
                        },
                        @{
                            'n' = 'teamId'
                            'e' = { $_.id }
                        }

                        $appOwners.Add($thisOwnerDetail)
                    }
                    $thisOwnerDetail
                }
            }
            else {
                $_.ownership.owningContainers | Select-Object owningUsers, owningTeams
            }
        }
    },
    @{
        'n' = 'instance'
        'e' = { $_.instances }
    } -ExcludeProperty applicationIds, instances, totalInstanceCount, ownership
}