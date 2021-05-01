function Get-EnumValues {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string] $EnumName
    )

    process {
        [enum]::GetValues([type]$EnumName).ForEach{
            @{$_ = $_.value__}
        }
    }
}
