function Find-VcCertificate {
    <#
    .SYNOPSIS
    Find certificates in TLSPC

    .DESCRIPTION
    Find certificates based on various attributes.
    If -First not provided, the default return is 1000 records.

    .PARAMETER Filter
    Array or multidimensional array of fields and values to filter on.
    Each array should be of the format @(field, comparison operator, value).
    To combine filters use the format @('operator', @(field, comparison operator, value), @(field2, comparison operator2, value2)).
    Nested filters are supported.
    Field names and values are case sensitive.
    For a complete list of comparison operators, see https://docs.venafi.cloud/api/about-api-search-operators/.

    .PARAMETER Order
    Array of fields to order on.
    For each item in the array, you can provide a field name by itself; this will default to ascending.
    You can also provide a hashtable with the field name as the key and either asc or desc as the value.

    .PARAMETER SavedSearchName
    Find certificates based on a saved search, see https://docs.venafi.cloud/vaas/certificates/saving-certificate-filters

    .PARAMETER First
    Only retrieve this many records

    .PARAMETER IncludeVaasOwner
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

    Find first 1000 certificates

    .EXAMPLE
    Find-VcCertificate | Get-VcCertificate

    Get detailed certificate info

    .EXAMPLE
    Find-VcCertificate -First 500

    Find the first 500 certificates

    .EXAMPLE
    Find-VcCertificate -Filter @('fingerprint', 'EQ', '075C43428E70BCF941039F54B8ED78DE4FACA87F')

    Find TLSPC certificates matching a single value

    .EXAMPLE
    Find-VcCertificate -Filter ('and', @('validityEnd','GTE',(get-date)), @('validityEnd','LTE',(get-date).AddDays(30)))

    Find TLSPC certificates matching multiple values.  In this case, find all certificates expiring in the next 30 days.

    .EXAMPLE
    Find-VcCertificate -Filter ('and', @('validityEnd','GTE',(get-date)), @('validityEnd','LTE',(get-date).AddDays(30))) | Invoke-VcCertificateAction -Renew

    Find all certificates expiring in the next 30 days and renew them

    .EXAMPLE
    Find-VcCertificate -IncludeVaasOwner

    Include user/team owner information.
    This will make additional api calls and will increase the response time.

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Certificates/certificates_search_getByExpressionAsCsv

    #>

    [CmdletBinding(DefaultParameterSetName = 'TLSPC')]

    param (

        [Parameter(ParameterSetName = 'TLSPC')]
        [System.Collections.ArrayList] $Filter,

        [parameter(ParameterSetName = 'TLSPC')]
        [psobject[]] $Order,

        [parameter(Mandatory, ParameterSetName = 'VaasSavedSearch')]
        [string] $SavedSearchName,

        [Parameter()]
        [switch] $IncludeVaasOwner,

        [Parameter()]
        [int] $First,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TLSPC'

        $toRetrieveCount = if ($PSBoundParameters.ContainsKey('First') ) {
            $First
        }
        else {
            1000 # default to max page size allowed
        }

        $queryParams = @{
            Filter = $Filter
            Order  = $Order
            First  = $toRetrieveCount
        }

        $body = New-VcSearchQuery @queryParams

        if ( $PSBoundParameters.ContainsKey('SavedSearchName') ) {
            # get saved search data and update payload
            $thisSavedSearch = Invoke-VenafiRestMethod -UriRoot 'outagedetection/v1' -UriLeaf 'savedsearches' | Select-Object -ExpandProperty savedSearchInfo | Where-Object { $_.name -eq $SavedSearchName }
            if ( $thisSavedSearch ) {
                $body.expression = $thisSavedSearch.searchDetails.expression
                $body.ordering = $thisSavedSearch.searchDetails.ordering
            }
            else {
                throw "The saved search name $SavedSearchName does not exist"
            }
        }

        $params = @{
            Method  = 'Post'
            UriRoot = 'outagedetection/v1'
            UriLeaf = 'certificatesearch?ownershipTree=true'
            Body    = $body
            # ensure we get json back otherwise we might get csv
            Header  = @{'Accept' = 'application/json' }
        }

        $apps = [System.Collections.Generic.List[object]]::new()
        $appOwners = [System.Collections.Generic.List[object]]::new()

    }

    process {

        do {

            $response = Invoke-VenafiRestMethod @params
            $response.certificates | Select-Object @{
                'n' = 'certificateId'
                'e' = {
                    $_.Id
                }
            },
            @{
                'n' = 'application'
                'e' = {
                    foreach ($thisAppId in $_.applicationIds) {
                        $thisApp = $apps | Where-Object { $_.applicationId -eq $thisAppId }
                        if ( -not $thisApp ) {
                            $thisApp = $thisAppId | Get-VcApplication | Select-Object -Property * -ExcludeProperty ownerIdsAndTypes, ownership
                            $apps.Add($thisApp)
                        }
                        $thisApp
                    }
                }
            },
            @{
                'n' = 'owner'
                'e' = {
                    if ( $IncludeVaasOwner ) {

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
            },
            * -ExcludeProperty Id, applicationIds, instances, totalInstanceCount, ownership

            $body.paging.pageNumber += 1

            # if ( -not $PSCmdlet.PagingParameters.IncludeTotalCount ) {
            $toRetrieveCount -= $response.'count'

            if ( $toRetrieveCount -le 0 ) {
                break
            }

            if ( $toRetrieveCount -lt $body.paging.pageSize ) {
                # if what's left to retrieve is less than the page size
                # adjust to just retrieve the remaining amount
                $body.paging.pageSize = $toRetrieveCount
            }
            # }

        } until (
            $response.'count' -eq 0 -or $response.'count' -lt $body.paging.pageSize
        )

    }
}