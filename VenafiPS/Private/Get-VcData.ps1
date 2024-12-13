function Get-VcData {

    <#
    .SYNOPSIS
        Helper function to get data from Venafi Cloud
    #>


    [CmdletBinding(DefaultParameterSetName = 'ID')]
    param (
        [parameter(ValueFromPipeline, ParameterSetName = 'ID', Position = '0')]
        [parameter(ValueFromPipeline, ParameterSetName = 'Name', Position = '0')]
        [parameter(ValueFromPipeline, ParameterSetName = 'Object', Position = '0')]
        [string] $InputObject,

        [parameter(Mandatory)]
        [ValidateSet('Application', 'VSatellite', 'Certificate', 'IssuingTemplate', 'Team', 'Machine', 'Tag', 'MachinePlugin', 'CaPlugin', 'TppPlugin')]
        [string] $Type,

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
        $idNameQuery = 'query MyQuery {{ {0} {{ nodes {{ id name }} }} }}'
    }

    process {

        # if we already have a guid and are just looking for the ID, return it
        if ( $PSCmdlet.ParameterSetName -eq 'ID' -and (Test-IsGuid($InputObject)) ) {
            return $InputObject
        }

        if ( $PSCmdlet.ParameterSetName -in 'ID', 'Name' ) {
            switch ($Type) {
                { $_ -in 'Application', 'Team' } {
                    $gqltype = '{0}s' -f $Type.ToLower()
                    $allObject = (Invoke-VcGraphQL -Query ($idNameQuery -f $gqltype)).$gqltype.nodes
                    $thisObject = $allObject | Where-Object { $InputObject -in $_.name, $_.id }
                    break
                }
            }
        }
        else {
            # object or first
            switch ($Type) {
                'Application' {
                    $allObject = Get-VcApplication -All
                    $thisObject = $allObject | Where-Object { $InputObject -in $_.name, $_.applicationId }
                    break
                }
                'Team' {
                    $allObject = Get-VcTeam -All | Sort-Object -Property name
                    $thisObject = $allObject | Where-Object { $InputObject -in $_.name, $_.teamId }
                    break
                }
            }
        }

        switch ($Type) {
            'VSatellite' {
                $allObject = Get-VcSatellite -All | Where-Object { $_.edgeStatus -eq 'ACTIVE' } | Sort-Object -Property name
                $thisObject = $allObject | Where-Object { $InputObject -in $_.name, $_.vsatelliteId }
                break
            }

            'IssuingTemplate' {
                $allObject = Get-VcIssuingTemplate -All | Sort-Object -Property name
                $thisObject = $allObject | Where-Object { $InputObject -in $_.name, $_.issuingTemplateId }
                break
            }

            { $_ -match 'Plugin$' } {
                # for machine, ca, tpp, etc plugins
                $pluginType = $_.Replace('Plugin', '').ToUpper()
                
                $allObject = Invoke-VenafiRestMethod -UriLeaf "plugins?pluginType=$pluginType" |
                Select-Object -ExpandProperty plugins |
                Select-Object -Property @{'n' = ('{0}Id' -f $Type); 'e' = { $_.Id } }, * -ExcludeProperty id

                $thisObject = $allObject | Where-Object { $InputObject -in $_.name, $_.('{0}Id' -f $Type) }
                break
            }

            'Certificate' {
                $thisObject = Find-VcCertificate -Name $InputObject
                break
            }

            'Machine' {
                $thisObject = Find-VcMachine -Name $InputObject
                break
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
                break
            }
        }

        $returnObject = if ( $InputObject ) {
            $thisObject
        }
        else {
            $allObject
        }
        
        if ( $FailOnMultiple -and @($returnObject).Count -gt 1 ) {
            throw "Multiple $Type found"
        }

        if ( $FailOnNotFound -and -not $returnObject ) {
            throw "$Type '$InputObject' not found"
        }

        switch ($PSCmdlet.ParameterSetName) {
            'ID' {
                if ( $returnObject ) {
                    if ( $returnObject.id ) {
                        # for the new graphql queries
                        $returnObject.id
                    }
                    else {
                        $returnObject."$("$Type")id"
                    }
                }
                else {
                    return $null
                }

                break
            }

            'Name' {
                switch ($Type) {
                    'Tag' { $InputObject }
                    { $_ -in 'Application', 'Team' } {
                        $returnObject.name
                    }
                }
                break
            }

            'Object' {
                $returnObject
                break
            }

            'First' {
                $returnObject | Select-Object -First 1
                break
            }
        }
    }

    end {

    }
}