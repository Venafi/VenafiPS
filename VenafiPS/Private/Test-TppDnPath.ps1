function Test-TppDnPath {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Path,

        [Parameter()]
        [switch] $AllowRoot
    )

    process {
        if ( $AllowRoot ) {
            $_ -imatch '^[\\|\\\\]+ved([\\|\\\\]+.+)*$'
        }
        else {
            $_ -imatch '^[\\|\\\\]+ved([\\|\\\\]+.+)+$'
        }
    }
}