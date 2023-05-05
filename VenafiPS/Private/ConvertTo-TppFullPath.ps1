function ConvertTo-TppFullPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Path
    )

    begin {

    }

    process {
        if ( $Path.ToLower() -notlike '\ved*') {
            "\VED\Policy\$Path"
        }
        else {
            $Path
        }
    }

    end {

    }
}