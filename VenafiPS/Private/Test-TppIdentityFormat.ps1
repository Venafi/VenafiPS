function Test-TppIdentityFormat {

    [CmdletBinding()]
    [OutputType([System.Boolean])]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Identity,

        [Parameter()]
        [ValidateSet('Name', 'Universal')]
        [string] $Type = 'Universal'
    )

    process {

        if ( $Type -eq 'Universal' ) {
            $Identity -match '^(AD|LDAP)+.+:\w{32}$' -or $Identity -match '^local:\{?\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\}?$'
        } else {
            #TODO
        }
    }
}