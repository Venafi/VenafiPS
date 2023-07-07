<#
.SYNOPSIS
Convert identity to standard format

.DESCRIPTION
Convert identity to standard format

.PARAMETER InputObject
Identity object

.INPUTS
InputObject

.OUTPUTS
PSCustomObject

.EXAMPLE
$identityObj | ConvertTo-TppIdentity

#>
function ConvertTo-VaasTeam {

    [CmdletBinding()]

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [PSCustomObject[]] $InputObject
    )

    begin {
    }

    process {
        $InputObject | Select-Object -Property `
        @{
            n = 'teamId'
            e = { $_.id }
        }, * -ExcludeProperty id
    }
}