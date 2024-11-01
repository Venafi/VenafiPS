function Get-VcData {

    <#
    .SYNOPSIS
        Helper function to get data from Venafi Cloud
    #>


    [CmdletBinding(DefaultParameterSetName = 'ID')]
    param (
        [parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'ID', Position = '0')]
        [parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Name', Position = '0')]
        [parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Object', Position = '0')]
        [AllowEmptyString()]
        [string] $InputObject,

        [parameter(Mandatory)]
        [ValidateSet('Application', 'MachineType', 'VSatellite', 'Certificate', 'IssuingTemplate', 'Team', 'Machine', 'Tag')]
        [string] $Type,

        # [parameter()]
        # [ValidateSet('InputObject', 'Name', 'Object', 'First')]
        # [string] $OutType = 'InputObject',

        [parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Name')]
        [switch] $Name,

        [parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Object')]
        [switch] $Object,

        [parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'First')]
        [switch] $First,

        [parameter()]
        [switch] $FailOnMultiple,

        [parameter()]
        [switch] $FailOnNotFound
    )

    begin {

    }

    process {

        # if we already have a guid, just return it
        if ( $PSCmdlet.ParameterSetName -eq 'ID' -and (Test-IsGuid($InputObject)) ) {
            return $InputObject
        }

        switch ($Type) {
            'Application' {

                # if ( -not $script:vcApplication ) {
                # $script:vcApplication = Get-VcApplication -All | Sort-Object -Property name
                # }

                # $allObject = $script:vcApplication
                # $thisObject = $script:vcApplication | Where-Object { $InputObject -in $_.name, $_.applicationId }

                $allObject = Get-VcApplication -All | Sort-Object -Property name
                $thisObject = $allObject | Where-Object { $InputObject -in $_.name, $_.applicationId }
            }

            'VSatellite' {

                # if ( -not $script:vcVSatellite ) {
                #     $script:vcVSatellite = Get-VcSatellite -All | Sort-Object -Property name
                # }

                # $allObject = $script:vcVSatellite
                # $thisObject = $script:vcVSatellite | Where-Object { $InputObject -in $_.name, $_.vsatelliteId }

                $allObject = Get-VcSatellite -All | Where-Object { $_.edgeStatus -eq 'ACTIVE' } | Sort-Object -Property name
                $thisObject = $allObject | Where-Object { $InputObject -in $_.name, $_.vsatelliteId }
            }

            'IssuingTemplate' {
                # if ( -not $script:vcIssuingTemplate ) {
                #     $script:vcIssuingTemplate = Get-VcIssuingTemplate -All | Sort-Object -Property name
                # }
                # $allObject = $script:vcIssuingTemplate
                # $thisObject = $script:vcIssuingTemplate | Where-Object { $InputObject -in $_.name, $_.issuingTemplateId }

                $allObject = Get-VcIssuingTemplate -All | Sort-Object -Property name
                $thisObject = $allObject | Where-Object { $InputObject -in $_.name, $_.issuingTemplateId }
            }

            'Team' {
                # if ( -not $script:vcTeam ) {
                #     $script:vcTeam = Get-VcTeam -All | Sort-Object -Property name
                # }
                # $allObject = $script:vcTeam
                # $thisObject = $script:vcTeam | Where-Object { $InputObject -in $_.name, $_.teamId }

                $allObject = Get-VcTeam -All | Sort-Object -Property name
                $thisObject = $allObject | Where-Object { $InputObject -in $_.name, $_.teamId }
            }

            'MachineType' {
                # if ( -not $script:vcMachineType ) {
                #     $script:vcMachineType = Invoke-VenafiRestMethod -UriLeaf 'machinetypes' |
                #     Select-Object -ExpandProperty machineTypes |
                #     Select-Object -Property @{'n' = 'machineTypeId'; 'e' = { $_.Id } }, * -ExcludeProperty id |
                #     Sort-Object -Property machineType
                # }
                # $allObject = $script:vcMachineType
                # $thisObject = $script:vcMachineType | Where-Object { $InputObject -in $_.machineType, $_.machineTypeId }

                $allObject = Invoke-VenafiRestMethod -UriLeaf 'machinetypes' |
                Select-Object -ExpandProperty machineTypes |
                Select-Object -Property @{'n' = 'machineTypeId'; 'e' = { $_.Id } }, * -ExcludeProperty id |
                Sort-Object -Property machineType
                $thisObject = $allObject | Where-Object { $InputObject -in $_.machineType, $_.machineTypeId }
            }

            'Certificate' {
                $thisObject = Find-VcCertificate -Name $InputObject
            }

            'Machine' {
                $thisObject = Find-VcMachine -Name $InputObject
            }

            'Tag' {
                try {

                    if ( $InputObject.Contains(':') ) {
                        $tagName, $tagValue = $InputObject.Split(':')
                    }
                    else {
                        $tagName = $InputObject
                    }
                    $tag = Invoke-VenafiRestMethod -UriLeaf "tags/$tagName" |
                    Select-Object -Property @{'n' = 'tagId'; 'e' = { $_.Id } }, @{'n' = 'values'; 'e' = { $null } }, * -ExcludeProperty id

                    if ( $tag ) {
                        $values = Invoke-VenafiRestMethod -UriLeaf "tags/$($tag.name)/values"

                        if ( $values.values ) {
                            $tag.values = ($values.values | Select-Object id, @{'n' = 'name'; 'e' = { $_.value } })

                            # make sure the value, if provided, is valid
                            if ( $tagValue -and $tagValue -notin $tag.values.name ) {
                                $tag = $null
                            }
                        }
                        else {
                            if ( $tagValue ) {
                                # the tag name exists, but the value does not
                                $tag = $null
                            }
                        }
                    }

                    $thisObject = $tag
                }
                catch {
                    $thisObject = $null
                }
            }
        }

        if ( $FailOnMultiple -and @($thisObject).Count -gt 1 ) {
            throw "Multiple $Type found"
        }

        if ( $FailOnNotFound -and -not $thisObject ) {
            throw "'$InputObject' of type $Type not found"
        }

        switch ($PSCmdlet.ParameterSetName) {
            'ID' {
                if ( $thisObject ) {
                    $thisObject."$("$Type")id"
                }
                else {
                    return $null
                }

            }

            'Name' {
                switch ($Type) {
                    'Tag' { $InputObject }
                }
            }

            'Object' {
                $thisObject
            }

            'First' {
                $allObject | Select-Object -First 1
            }
        }
    }

    end {

    }
}