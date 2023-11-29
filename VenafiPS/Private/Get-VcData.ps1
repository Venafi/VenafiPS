function Get-VcData {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyString()] # providing empty string allows us to preload the script var
        [string] $ID,

        [parameter(Mandatory)]
        [ValidateSet('Application', 'MachineType', 'VSatellite', 'Certificate')]
        [string] $Type,

        [parameter()]
        [ValidateSet('ID', 'Name', 'Object')]
        [string] $OutType = 'ID',

        [parameter()]
        [switch] $FailOnMultiple
    )

    begin {

    }

    process {
        if ( $OutType -eq 'ID' -and $ID | Test-IsGuid ) {
            return $ID
        }

        switch ($Type) {
            'Application' {

                if ( -not $script:vcApplication ) {
                    $script:vcApplication = Get-VcApplication -All | Sort-Object -Property name
                }

                $thisObject = $script:vcApplication | Where-Object { $ID -in $_.name, $_.applicationId }
            }

            'VSatellite' {

                if ( -not $script:vcSatellite ) {
                    $script:vcSatellite = Get-VcSatellite -All | Sort-Object -Property name
                }

                $thisObject = $script:vcSatellite | Where-Object { $ID -in $_.name, $_.vsatelliteId }
            }

            'MachineType' {
                if ( -not $script:vcMachineType ) {
                    $script:vcMachineType = Invoke-VenafiRestMethod -UriLeaf 'machinetypes' |
                    Select-Object -ExpandProperty machineTypes |
                    Select-Object -Property @{'n' = 'machineTypeId'; 'e' = { $_.Id } }, * -ExcludeProperty id |
                    Sort-Object -Property machineType
                }
                $thisObject = $script:vcMachineType | Where-Object { $ID -in $_.machineType, $_.machineTypeId }
            }

            'Certificate' {
                $thisObject = Find-VcCertificate -Name $ID
            }
        }

        if ( $FailOnMultiple -and @($thisObject).Count -gt 1 ) {
            throw "Multiple $Type found"
        }

        switch ($OutType) {
            'ID' {
                if ( $thisObject ) {
                    $thisObject."$("$Type")id"
                }
                else {
                    if ( $ID ) {
                        throw "$Type '$ID' does not exist"
                    }
                }
            }

            'Name' {
                # TODO
            }

            'Object' {
                $thisObject
            }
        }
    }

    end {

    }
}