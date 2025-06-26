function Get-VcTag {
    <#
    .SYNOPSIS
    Get tags from TLSPC

    .DESCRIPTION
    Get 1 or all tags.
    Tag values will be provided.

    .PARAMETER Tag
    Tag name

    .PARAMETER All
    Get all tags

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.key can also provided.

    .INPUTS
    Name

    .EXAMPLE
    Get-VcTag -Tag 'MyTag'

    Get a single tag

    .EXAMPLE
    Get-VcTag -All

    Get all tags

    #>

    [CmdletBinding()]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('Name')]
        [string] $Tag,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch] $All,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession $PSCmdlet.MyInvocation
    }

    process {

        if ( $PSCmdlet.ParameterSetName -eq 'All' ) {
            $values = Invoke-VenafiRestMethod -UriLeaf 'tags/values' | Select-Object -ExpandProperty values
            $response = Invoke-VenafiRestMethod -UriLeaf 'tags' | Select-Object -ExpandProperty tags
        }
        else {
            $response = Invoke-VenafiRestMethod -UriLeaf "tags/$Tag"
            $values = Invoke-VenafiRestMethod -UriLeaf "tags/$Tag/values" | Select-Object -ExpandProperty values
        }

        if ( $response ) {
            $response | Select-Object @{'n' = 'tagId'; 'e' = { $_.key } },
            @{
                'n' = 'value'
                'e' = {
                    $thisId = $_.id
                    , @(($values | Where-Object { $_.tagId -eq $thisId }).value)
                }
            }
        }
    }
}


