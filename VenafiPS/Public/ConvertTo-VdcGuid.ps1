function ConvertTo-VdcGuid {
    <#
    .SYNOPSIS
    Convert DN path to GUID

    .DESCRIPTION
    Convert DN path to GUID

    .PARAMETER Path
    DN path representing an object

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    Path

    .OUTPUTS
    Guid

    .EXAMPLE
    ConvertTo-VdcGuid -Path '\ved\policy\convertme'

    #>

    [CmdletBinding()]
    [OutputType([System.Guid])]
    [Alias('ConvertTo-VdcGuid')]

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
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

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

        $response = Invoke-VenafiRestMethod @params

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