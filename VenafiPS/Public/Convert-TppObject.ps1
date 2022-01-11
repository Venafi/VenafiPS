<#
.SYNOPSIS
Change the class/object type of an existing object

.DESCRIPTION
Change the class/object type of an existing object

.PARAMETER Path
Path to the object

.PARAMETER Class
New class/type

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Path

.OUTPUTS
None

.EXAMPLE
Convert-TppObject -Path '\ved\policy\' -Class 'X509 Device Certificate'
Convert an object to a different type

#>
function Convert-TppObject {

    [CmdletBinding()]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid path"
                }
            })]
        [String] $Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Class,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {

        $VenafiSession.Validate('tpp') | Out-Null

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriLeaf       = 'config/MutateObject'
            Body          = @{
                Class = $Class
            }
        }
    }

    process {

        $params.Body.ObjectDN = $Path

        $response = Invoke-TppRestMethod @params

        if ( $response.Result -ne [TppConfigResult]::Success ) {
            throw $response.Error
        }
    }
}