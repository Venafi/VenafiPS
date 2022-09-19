function ConvertTo-TppFullPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Path
    )

    begin {

    }

    process {
        $pathOut = $Path
        if ( $Path.ToLower() -notlike '\ved\*') {
            $pathOut = Join-Path -Path '\VED\Policy' -ChildPath $Path
        }
        $pathOut
    }

    end {

    }
}