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
        if ( $PSBoundParameters.ContainsKey('AllowRoot') ) {
            $_ -match '^[\\|//]VED([\\|//].+)*$'
        }
        else {
            $_ -match '^[\\|//]VED([\\|//].+)+$'
        }
    }
}