<#
.SYNOPSIS
Get different types of objects from VaaS

.DESCRIPTION
Get 1 or all objects from VaaS.
You can retrieve teams, applications, machines, machine identities, tags, issuing templates, and vsatellites.
Where applicable, associated additional data will be retrieved and appended to the response.
For example, when getting tags their values will be provided.

.PARAMETER TeamID
Team ID or name

.PARAMETER ApplicationID
Application ID or name

.PARAMETER MachineID
Machine ID or name.  Name is case sensitive.

.PARAMETER MachineIdentityID
Machine Identity ID or name

.PARAMETER TagID
Tag name

.PARAMETER ConnectorID
Connector ID or name

.PARAMETER IssuingTemplateID
Issuing template ID or name

.PARAMETER VSatelliteID
VSatellite ID or name

.PARAMETER TeamAll
Get all teams

.PARAMETER ApplicationAll
Get all applications

.PARAMETER MachineAll
Get all machines

.PARAMETER MachineIdentityAll
Get all machine identities

.PARAMETER TagID
Get all tags and their values

.PARAMETER ConnectorAll
Get all connectors

.PARAMETER IssuingTemplateAll
Get all issuing templates

.PARAMETER VSatelliteAll
Get all VSatellites and their encryption keys

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A VaaS key can also provided.

.INPUTS
TeamID, ApplicationID, MachineID, MachineIdentityID, TagName, ConnectorID, IssuingTemplateID, VSatelliteID

.EXAMPLE
Get-VaasObject -ApplicationID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'

Get a single object by ID

.EXAMPLE
Get-VaasObject -ApplicationID 'My Awesome App'

Get a single object by name.  The name is case sensitive.

.EXAMPLE
Get-VaasObject -ConnectorAll | Remove-VaasObject

Get all connectors and remove them all

#>
function Get-VaasObject {

    [CmdletBinding()]

    param (

        [Parameter(Mandatory, ParameterSetName = 'TeamID', ValueFromPipelineByPropertyName)]
        [string] $TeamID,

        [Parameter(Mandatory, ParameterSetName = 'ApplicationID', ValueFromPipelineByPropertyName)]
        [string] $ApplicationID,

        [Parameter(Mandatory, ParameterSetName = 'MachineID', ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'MachineIdentityID', ValueFromPipelineByPropertyName)]
        [string] $MachineID,

        [Parameter(Mandatory, ParameterSetName = 'MachineIdentityID', ValueFromPipelineByPropertyName)]
        [string] $MachineIdentityID,

        [Parameter(Mandatory, ParameterSetName = 'TagID', ValueFromPipelineByPropertyName)]
        [Alias('tagName')]
        [string] $TagID,

        [Parameter(Mandatory, ParameterSetName = 'ConnectorID', ValueFromPipelineByPropertyName)]
        [string] $ConnectorID,

        [Parameter(Mandatory, ParameterSetName = 'IssuingTemplateID', ValueFromPipelineByPropertyName)]
        [string] $IssuingTemplateID,

        [Parameter(Mandatory, ParameterSetName = 'VSatelliteID', ValueFromPipelineByPropertyName)]
        [string] $VSatelliteID,

        [Parameter(Mandatory, ParameterSetName = 'TeamAll')]
        [switch] $TeamAll,

        [Parameter(Mandatory, ParameterSetName = 'ApplicationAll')]
        [switch] $ApplicationAll,

        [Parameter(Mandatory, ParameterSetName = 'MachineAll')]
        [switch] $MachineAll,

        [Parameter(Mandatory, ParameterSetName = 'MachineIdentityAll')]
        [switch] $MachineIdentityAll,

        [Parameter(Mandatory, ParameterSetName = 'TagAll')]
        [switch] $TagAll,

        [Parameter(Mandatory, ParameterSetName = 'ConnectorAll')]
        [switch] $ConnectorAll,

        [Parameter(Mandatory, ParameterSetName = 'IssuingTemplateAll')]
        [switch] $IssuingTemplateAll,

        [Parameter(Mandatory, ParameterSetName = 'VSatelliteAll')]
        [switch] $VSatelliteAll,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'
    }

    process {

        switch -Wildcard ($PSCmdlet.ParameterSetName) {

            'Team*' {
                $params = @{ UriLeaf = 'teams' }

                if ( $PSCmdlet.ParameterSetName -eq 'TeamID' ) {
                    if ( Test-IsGuid($TeamID) ) {
                        $guid = [guid] $TeamID
                        $params.UriLeaf = 'teams/{0}' -f $guid.ToString()
                    }
                    else {
                        # assume team name
                        return Get-VaasObject -TeamAll | Where-Object { $_.name -eq $TeamID }
                    }
                }

                $response = Invoke-VenafiRestMethod @params

                if ( $response.PSObject.Properties.Name -contains 'teams' ) {
                    $response | Select-Object -ExpandProperty teams | ConvertTo-VaasTeam
                }
                else {
                    $response | ConvertTo-VaasTeam
                }
            }

            'Application*' {
                $params = @{
                    UriRoot = 'outagedetection/v1'
                    UriLeaf = 'applications'
                }

                if ( $PSBoundParameters.ContainsKey('ApplicationID') ) {
                    if ( Test-IsGuid($ApplicationID) ) {
                        $guid = [guid] $ApplicationID
                        $params.UriLeaf += "/{0}" -f $guid.ToString()
                    }
                    else {
                        # search by name
                        $params.UriLeaf += "/name/$ApplicationID"
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
                    $applications | Select-Object *,
                    @{
                        'n' = 'applicationId'
                        'e' = {
                            $_.Id
                        }
                    },
                    @{
                        'n' = 'certificateIssuingTemplate'
                        'e' = {
                            $_.certificateIssuingTemplateAliasIdMap.psobject.Properties | Select-Object name, @{'n' = 'id'; 'e' = { $_.Value } }
                        }
                    } -ExcludeProperty Id, certificateIssuingTemplateAliasIdMap
                }
            }

            'MachineIdentity*' {
                if ( $PSCmdlet.ParameterSetName -eq 'MachineIdentityAll' ) {

                    $params = @{
                        InputObject = Find-VaasObject -Type MachineIdentity | Select-Object -Property machineIdentityId
                        ScriptBlock = { $PSItem | Get-VaasObject }
                    }
                    return Invoke-VenafiParallel @params
                }
                else {
                    if ( Test-IsGuid($MachineIdentityID) ) {
                        $guid = [guid] $MachineIdentityID
                        $response = Invoke-VenafiRestMethod -UriLeaf ('machineidentities/{0}' -f $guid.ToString())
                    }
                    else {
                        # no lookup by name directly.  search for it and then get details
                        Find-VaasObject -Type 'MachineIdentity' -Name $MachineIdentityID | Get-VaasObject
                    }
                }

                if ( $response ) {
                    $response | Select-Object @{ 'n' = 'machineIdentityId'; 'e' = { $_.Id } }, * -ExcludeProperty Id
                }

                break
            }

            'Machine*' {
                # ensure this is below MachineIdentity* otherwise this will pick up both
                if ( $PSCmdlet.ParameterSetName -eq 'MachineAll' ) {

                    $params = @{
                        InputObject = Find-VaasObject -Type Machine
                        ScriptBlock = { $PSItem | Get-VaasObject }
                    }
                    return Invoke-VenafiParallel @params
                }
                else {
                    if ( Test-IsGuid($MachineID) ) {
                        $guid = [guid] $MachineID
                        try {
                            $response = Invoke-VenafiRestMethod -UriLeaf ('machines/{0}' -f $guid.ToString())
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
                    }
                    else {
                        # no lookup by name directly.  search for it and then get details
                        Find-VaasObject -Type 'Machine' -Name $MachineID | Get-VaasObject
                    }
                }

                if ( $response ) {
                    $response | Select-Object @{ 'n' = 'machineId'; 'e' = { $_.Id } }, * -ExcludeProperty Id
                }

            }

            'Tag*' {

                if ( $PSCmdlet.ParameterSetName -eq 'TagAll' ) {
                    $values = Invoke-VenafiRestMethod -UriLeaf 'tags/values' | Select-Object -ExpandProperty values
                    $response = Invoke-VenafiRestMethod -UriLeaf 'tags' | Select-Object -ExpandProperty tags
                }
                else {
                    $response = Invoke-VenafiRestMethod -UriLeaf "tags/$TagID"
                    $values = Invoke-VenafiRestMethod -UriLeaf "tags/$TagID/values" | Select-Object -ExpandProperty values
                }

                if ( $response ) {
                    $response | Select-Object @{'n' = 'tagId'; 'e' = { $_.name } },
                    @{
                        'n' = 'value'
                        'e' = {
                            $thisId = $_.id
                            , @(($values | Where-Object { $_.tagId -eq $thisId }).value)
                        }
                    }, * -ExcludeProperty id, name
                }
            }

            'Connector*' {
                $params = @{
                    UriLeaf = 'connectors'
                }

                if ( $PSBoundParameters.ContainsKey('ConnectorID') ) {
                    if ( Test-IsGuid($ConnectorID) ) {
                        $guid = [guid] $ConnectorID
                        $params.UriLeaf += "/{0}" -f $guid.ToString()
                    }
                    else {
                        # search by name
                        return Get-VaasObject -ConnectorAll | Where-Object { $_.name -eq $ConnectorID }
                    }
                }

                $response = Invoke-VenafiRestMethod @params

                if ( $response.PSObject.Properties.Name -contains 'connectors' ) {
                    $connectors = $response | Select-Object -ExpandProperty connectors
                }
                else {
                    $connectors = $response
                }

                if ( $connectors ) {
                    $connectors | Select-Object @{ 'n' = 'connectorId'; 'e' = { $_.Id } }, * -ExcludeProperty Id
                }
            }

            'IssuingTemplate*' {
                $params = @{
                    UriLeaf = 'certificateissuingtemplates'
                }

                if ( $PSBoundParameters.ContainsKey('IssuingTemplateID') ) {
                    if ( Test-IsGuid($IssuingTemplateID) ) {
                        $guid = [guid] $IssuingTemplateID
                        $params.UriLeaf += "/{0}" -f $guid.ToString()
                    }
                    else {
                        # search by name
                        return Get-VaasObject -IssuingTemplateAll | Where-Object { $_.name -eq $IssuingTemplateID }
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

                if ( $response.PSObject.Properties.Name -contains 'certificateissuingtemplates' ) {
                    $templates = $response | Select-Object -ExpandProperty certificateissuingtemplates
                }
                else {
                    $templates = $response
                }

                if ( $templates ) {
                    $templates | Select-Object -Property @{'n' = 'certificateIssuingTemplateId'; 'e' = { $_.id } }, * -ExcludeProperty id
                }
            }

            'VSatellite*' {
                $allKeys = Invoke-VenafiRestMethod -UriLeaf 'edgeencryptionkeys' | Select-Object -ExpandProperty encryptionKeys

                if ( $PSCmdlet.ParameterSetName -eq 'VSatelliteAll' ) {
                    $response = Invoke-VenafiRestMethod -UriLeaf 'edgeinstances' | Select-Object -ExpandProperty edgeinstances
                }
                else {
                    if ( Test-IsGuid($VSatelliteID) ) {
                        $guid = [guid] $VSatelliteID
                        $response = Invoke-VenafiRestMethod -UriLeaf ('edgeinstances/{0}' -f $guid.ToString())
                    }
                    else {
                        # get all and match by name since another method doesn't exist
                        return Get-VaasObject -VSatelliteAll | Where-Object { $_.name -eq $VSatelliteID }
                    }
                }

                if ( -not $response ) {
                    $response | Select-Object @{'n' = 'vsatelliteId'; 'e' = { $_.Id } },
                    @{
                        'n' = 'encryptionKey'
                        'e' = {
                            $thisId = $_.encryptionKeyId
                                ($allKeys | Where-Object { $_.id -eq $thisId }).key
                        }
                    },
                    @{
                        'n' = 'encryptionKeyAlgorithm'
                        'e' = {
                            $thisId = $_.encryptionKeyId
                                ($allKeys | Where-Object { $_.id -eq $thisId }).KeyAlgorithm
                        }
                    }, * -ExcludeProperty Id
                }
            }
        }
    }
}
