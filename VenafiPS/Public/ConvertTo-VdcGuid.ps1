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
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

    .INPUTS
    Path

    .OUTPUTS
    Guid

    .EXAMPLE
    ConvertTo-VdcGuid -Path '\ved\policy\convertme'

    #>

    [CmdletBinding()]
    [Alias('ConvertTo-TppGuid')]
    [OutputType([System.Guid])]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
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
        Test-VenafiSession $PSCmdlet.MyInvocation

        $params = @{
            Method  = 'Post'
            UriLeaf = 'config/DnToGuid'
            Body    = @{
                ObjectDN = ''
            }
        }
    }

    process {

        $params.Body.ObjectDN = $Path

        $response = Invoke-VenafiRestMethod @params

        switch ($response.Result) {
            1 {
                # success
                if ( $IncludeType ) {
                    [PSCustomObject] @{
                        Guid     = [Guid] $response.Guid
                        TypeName = $response.ClassName
                    }
                }
                else {
                    [Guid] $response.Guid
                }
            }

            7 {
                throw [System.UnauthorizedAccessException]::new($response.Error)
            }

            400 {
                throw [System.Management.Automation.ItemNotFoundException]::new($response.Error)
            }

            Default {
                throw $response.Error
            }
        }
    }
}