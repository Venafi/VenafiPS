function Get-VcApplication {
    <#
    .SYNOPSIS
    Get application info

    .DESCRIPTION
    Get 1 or more applications.

    .PARAMETER ID
    Application ID or name

    .PARAMETER All
    Get all applications

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .INPUTS
    ID

    .EXAMPLE
    Get-VcApplication -ApplicationID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'

    applicationId              : 96fc9310-67ec-11eb-a8a7-794fe75a8e6f
    certificateIssuingTemplate : @{Name=MyTemplate; id=7fb6af20-b22e-11ea-9a24-930fb5d2b247}
    companyId                  : 09b24f81-b22b-11ea-91f3-ebd6dea5452e
    name                       : myapp
    description                :
    ownerIdsAndTypes           : {@{ownerId=0a2adae0-b22b-11ea-91f3-ebd6dea5452f; ownerType=TEAM}}
    fullyQualifiedDomainNames  : {}
    ipRanges                   : {}
    ports                      : {}
    modificationDate           : 6/8/2023 11:06:43 AM
    creationDate               : 2/5/2021 2:59:00 PM
    ownership                  : @{owningUsers=System.Object[]}

    Get a single object by ID

    .EXAMPLE
    Get-VcApplication -ID 'My Awesome App'

    Get a single object by name.  The name is case sensitive.

    .EXAMPLE
    Get-VcApplication -All

    Get all applications

    #>

    [CmdletBinding(DefaultParameterSetName = 'ID')]
    [Alias('Get-VaasApplication')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('applicationId')]
        [string] $ID,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch] $All,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'
    }

    process {

        $params = @{
            UriRoot = 'outagedetection/v1'
            UriLeaf = 'applications'
        }

        if ( $PSBoundParameters.ContainsKey('ID') ) {
            if ( Test-IsGuid($ID) ) {
                $params.UriLeaf += "/{0}" -f $ID
            }
            else {
                # search by name
                $params.UriLeaf += "/name/$ID"
            }
        }

        try {
            $response = Invoke-VenafiRestMethod @params
        }
        catch {
            if ( $_.Exception.Response.StatusCode.value__ -eq 404 ) {
                # not found, return nothing
                return
            }
            else {
                throw $_
            }
        }

        if ( $response.PSObject.Properties.Name -contains 'applications' ) {
            $applications = $response | Select-Object -ExpandProperty applications
        }
        else {
            $applications = $response
        }

        if ( $applications ) {
            $applications | Select-Object @{'n' = 'applicationId'; 'e' = { $_.Id } },
            @{
                'n' = 'issuingTemplate'
                'e' = {
                    $_.certificateIssuingTemplateAliasIdMap.psobject.Properties | Select-Object @{'n' = 'name'; 'e' = { $_.Name } }, @{'n' = 'issuingTemplateId'; 'e' = { $_.Value } }
                }
            }, * -ExcludeProperty Id, certificateIssuingTemplateAliasIdMap
        }
    }
}
