function Get-VdcCustomField {
    <#
    .SYNOPSIS
    Get custom field details

    .DESCRIPTION
    Get details about custom fields

    .PARAMETER Class
    Class to get details on

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named TLSPDC_SERVER must also be set.

    .INPUTS
    None

    .OUTPUTS
    Query returns a PSCustomObject with the following properties:
        Items
            AllowedValues
            Classes
            ConfigAttribute
            DN
            DefaultValues
            Guid
            Label
            Mandatory
            Name
            Policyable
            RenderHidden
            RenderReadOnly
            Single
            Type
        Locked
        Result

    .EXAMPLE
    Get-VdcCustomField -Class 'X509 Certificate'
    Get custom fields for certificates

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Get-VdcCustomField/

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-GetItemsForClass.php

    .NOTES
    All custom fields are retrieved upon inital connect to the server and a property of VenafiSession
    #>

    [CmdletBinding()]
    [Alias('Get-TppCustomField')]

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Class,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TLSPDC'
    }

    process {
        $params = @{
            Method     = 'Post'
            UriLeaf    = 'Metadata/GetItemsForClass'
            Body       = @{
                'ConfigClass' = $Class
            }
        }

        $response = Invoke-VenafiRestMethod @params

        if ( $response.Result -eq [TppMetadataResult]::Success ) {
            [PSCustomObject] @{
                Items  = $response.Items
                Locked = $response.Locked
            }
        } else {
            throw $response.Error
        }
    }
}
