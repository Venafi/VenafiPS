<#
.SYNOPSIS
Convert code sign certificate environment to something powershell friendly

.DESCRIPTION
Convert code sign certificate environment to something powershell friendly

.PARAMETER InputObject
Code sign certificate environment object

.INPUTS
InputObject

.OUTPUTS
PSCustomObject

.EXAMPLE
$envObj | ConvertTo-TppCodeSignEnvironment

#>
function ConvertTo-TppIdentity {

    [CmdletBinding()]

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject[]] $InputObject
    )

    begin {
    }

    process {
        $InputObject | Select-Object -Property `
        @{
            n = 'Name'
            e = { $_.Name }
        },
        @{
            n = 'ID'
            e = { $_.PrefixedUniversal }
        },
        @{
            n = 'Path'
            e = { $_.FullName }
        },
        @{
            n = 'FullName'
            e = { $_.PrefixedName }
        },
        @{
            n = 'IsGroup'
            e = { $_.Type -ne 1 }
        } -ExcludeProperty PrefixedUniversal, FullName, Prefix, PrefixedName, Type, Universal, IsGroup
    }
}