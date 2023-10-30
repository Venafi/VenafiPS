function ConvertTo-VdcPath {
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
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named TLSPDC_SERVER must also be set.

    .INPUTS
    Guid

    .OUTPUTS
    String representing the Path

    .EXAMPLE
    ConvertTo-VdcPath -Guid [guid]'xyxyxyxy-xyxy-xyxy-xyxy-xyxyxyxyxyxy'

    #>

    [CmdletBinding()]
    [Alias('ConvertTo-TppPath')]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Guid] $Guid,

        [Parameter()]
        [switch] $IncludeType,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TLSPDC'

        $params = @{

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