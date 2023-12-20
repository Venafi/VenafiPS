function Get-VcData {
    [CmdletBinding(DefaultParameterSetName = 'ID')]
    param (
        [parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'ID', Position = '0')]
        [parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Name', Position = '0')]
        [parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Object', Position = '0')]
        [AllowEmptyString()]
        [string] $InputObject,

        [parameter(Mandatory)]
        [ValidateSet('Application', 'MachineType', 'VSatellite', 'Certificate', 'IssuingTemplate', 'Team')]
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
        [switch] $FailOnMultiple
    )

    begin {

    }

    process {
        # Write-Verbose $PSCmdlet.ParameterSetName
        # Write-Verbose ($InputObject | Test-IsGuid)
        # if ( ($PSCmdlet.ParameterSetName -eq 'ID') -and ($InputObject | Test-IsGuid) ) {
        #     return $InputObject
        # }

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
        }

        if ( $FailOnMultiple -and @($thisObject).Count -gt 1 ) {
            throw "Multiple $Type found"
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