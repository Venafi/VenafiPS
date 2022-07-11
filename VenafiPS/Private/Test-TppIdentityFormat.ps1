function Test-TppIdentityFormat {

    <#
    .SYNOPSIS
        Validate identity formats
    .DESCRIPTION
        Validate the format for identities prefixed name, prefixed universal, and local.
        As these formats are often interchangeable with api calls, you can validate multiple formats at once.
        By default, prefixed name and prefixed universal will be validated.
    .PARAMETER Identity
        The identity string to be validated
    .PARAMETER Format
        Format to validate, Name, Universal, and/or Local.
    .EXAMPLE
        Test-TppIdentityFormat -ID "AD+BigSur:cypher"

        Test the identity against all formats.  This would succeed for Name, but fail on Universal
    .EXAMPLE
        Test-TppIdentityFormat -ID "AD+BigSur:cypher" -Format Name

        Test the identity against a specific format.
    #>

    [CmdletBinding()]
    [OutputType([System.Boolean])]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $ID,

        [Parameter()]
        [ValidateSet('Name', 'Universal', 'Local')]
        [string[]] $Format = @('Name', 'Universal')
    )

    begin {

        # https://docs.microsoft.com/en-US/troubleshoot/windows-server/identity/naming-conventions-for-computer-domain-site-ou#domain-names
        $prefixRegex = '(?im)^(local|(AD|LDAP)\+[a-z0-9\-]{1,15}):'
        $localPrefixRegex = '(?im)^local:'
        $nameRegex = '.+$'
        $universalRegex = '\{?([0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12})\}?$'

        $success = $false
    }
    process {

        foreach ($thisType in $Format) {
            switch ($thisType) {

                'Name' {
                    $thisMatch = $ID -match ($prefixRegex + $nameRegex)
                    if ( $thisMatch ) {
                        Write-Verbose "$ID is a valid name identity"
                    }
                }

                'Universal' {
                    $thisMatch = $ID -match ($prefixRegex + $universalRegex)
                    if ( $thisMatch ) {
                        Write-Verbose "$ID is a valid universal identity"
                    }
                }

                'Local' {
                    $thisMatch = $ID -match ($localPrefixRegex + $nameRegex) -or $ID -match ($localPrefixRegex + $universalRegex)
                    if ( $thisMatch ) {
                        Write-Verbose "$ID is a valid local identity"
                    }
                }
            }

            if ( $thisMatch ) {
                $success = $true
            }
        }
    }

    end {
        $success
    }
}