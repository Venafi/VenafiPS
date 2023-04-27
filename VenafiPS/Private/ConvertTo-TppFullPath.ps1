function ConvertTo-TppFullPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Path
    )

    begin {

    }

    process {
        # $pathOut = $Path
        if ( $Path.ToLower() -notlike '\ved*') {
            "\VED\Policy\$Path"
        } else
        {
            $Path
        }
        # $pathOut
    }

    end {

    }
}