<#
.SYNOPSIS
Convert GUID to Path

.DESCRIPTION
Convert GUID to Path

.PARAMETER Guid
Guid type, [guid] 'xyxyxyxy-xyxy-xyxy-xyxy-xyxyxyxyxyxy'

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
Guid

.OUTPUTS
String representing the Path

.EXAMPLE
ConvertTo-TppPath -Guid [guid]'xyxyxyxy-xyxy-xyxy-xyxy-xyxyxyxyxyxy'

#>
function ConvertTo-TppPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Guid] $Guid,

        [Parameter()]
        [switch] $IncludeType,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        # Test-VenafiSession -VenafiSession $VenafiSession

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'config/GuidToDN'
            Body       = @{
                ObjectGUID = ''
            }
        }
    }

    process {

        $params.Body.ObjectGUID = "{$Guid}"

        $response = Invoke-VenafiRestMethod @params

        if ( $response.Result -eq [TppConfigResult]::Success ) {
            if ( $PSBoundParameters.ContainsKey('IncludeType') ) {
                [PSCustomObject] @{
                    Path     = $response.ObjectDN
                    TypeName = $response.ClassName
                }
            } else {
                $response.ObjectDN
            }
        } else {
            throw $response.Error
        }
    }
}