function Find-VaasMachine {
    <#
    .SYNOPSIS
    Find machine info

    .DESCRIPTION
    Find machine info based on type and/or status.
    Multiple filters will be additive.

    .PARAMETER MachineType
    Machine type to retrieve.  Use tab-ahead for complete list.

    .PARAMETER Status
    Status of machine, either 'DRAFT', 'VERIFIED', or 'UNVERIFIED'

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Find-VaasMachine -MachineType 'Citrix ADC'

    Get machines of a specific type

    .EXAMPLE
    Find-VaasMachine -Status 'VERIFIED'

    Get machines with a specific status
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