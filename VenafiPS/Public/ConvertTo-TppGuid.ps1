<#
.SYNOPSIS
Convert DN path to GUID

.DESCRIPTION
Convert DN path to GUID

.PARAMETER Path
DN path representing an object

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Path

.OUTPUTS
Guid

.EXAMPLE
ConvertTo-TppGuid -Path '\ved\policy\convertme'

#>
function ConvertTo-TppGuid {

    [CmdletBinding()]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                } else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('DN')]
        [String] $Path,

        [Parameter()]
        [switch] $IncludeType,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        # $VenafiSession.Validate()

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'config/DnToGuid'
            Body       = @{
                ObjectDN = ''
            }
        }
    }

    process {

        $params.Body.ObjectDN = $Path

        $response = Invoke-TppRestMethod @params

        if ( $response.Result -eq [TppConfigResult]::Success ) {
            if ( $IncludeType ) {
                [PSCustomObject] @{
                    Guid     = [Guid] $response.Guid
                    TypeName = $response.ClassName
                }
            } else {
                [Guid] $response.Guid
            }
        } else {
            throw $response.Error
        }
    }
}