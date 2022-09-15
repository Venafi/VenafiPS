function Find-TppEngine {
    <#
    .SYNOPSIS
    Find TPP engines using an optional pattern

    .DESCRIPTION
    Find TPP engines using an optional pattern.
    This function is an engine wrapper for Find-TppObject.

    .PARAMETER Pattern
    Filter against engine names using asterisk (*) and/or question mark (?) wildcard characters.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token can also provided, but this requires an environment variable TPP_SERVER to be set.

    .INPUTS
    Pattern

    .OUTPUTS
    TppObject

    .EXAMPLE
    Find-TppEngine -Pattern '*partialname*'

    Get engines whose name matches the supplied pattern

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppEngine/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppEngine.ps1
    #>

    [CmdletBinding()]

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String] $Pattern,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'
    }

    process {
        $params = @{
            VenafiSession = $VenafiSession
            Class         = 'Venafi Platform'
            Path          = '\VED\Engines'
            Pattern       = $Pattern
        }

        Find-TppObject @params
    }
}