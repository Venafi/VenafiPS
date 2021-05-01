<#
.SYNOPSIS
Convert datetime to UTC ISO 8601 format

.DESCRIPTION
Convert datetime to UTC ISO 8601 format

.PARAMETER InputObject
DateTime object

.INPUTS
InputObject

.OUTPUTS
System.String

.EXAMPLE
(get-date) | ConvertTo-UtcIso8601

#>
function ConvertTo-UtcIso8601 {

    [CmdletBinding()]

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [DateTime] $InputObject
    )

    begin {
    }

    process {
        $InputObject.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
    }
}