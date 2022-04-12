<#
.SYNOPSIS
    List all attributes for a specified class
.DESCRIPTION
    List all attributes for a specified class, helpful for validation or to pass to Get-TppAttribute
.EXAMPLE
    Get-TppClassAttribute -ClassName 'X509 Server Certificate'
    Get all attributes for the specified class
.INPUTS
    ClassName
.OUTPUTS
    PSCustomObject
#>
function Get-TppClassAttribute {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $ClassName,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $allAttributes = [System.Collections.Generic.List[object]]::new()
    }

    process {

        Write-Verbose "Processing $ClassName"

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriLeaf       = 'configschema/class'
            Body          = @{
                'Class' = $ClassName
            }
        }
        $classDetails = Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty 'ClassDefinition'

        if ($ClassName -ne 'Top') {
            $recurseAttribs = $classDetails.SuperClassNames | Get-TppClassAttribute
            foreach ($item in $recurseAttribs) {
                $allAttributes.Add($item)
            }
        }

        foreach ($item in ($classDetails.OptionalNames)) {
            $allAttributes.Add(
                [pscustomobject] @{
                    'Name'  = $item
                    'Class' = $classDetails.Name
                }
            )
        }
    }

    end {
        $allAttributes | Sort-Object -Property 'Name', 'Class' -Unique
    }
}
