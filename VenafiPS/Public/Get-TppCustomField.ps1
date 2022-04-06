<#
.SYNOPSIS
Get custom field details

.DESCRIPTION
Get details about custom fields

.PARAMETER Class
Class to get details on

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.
A TPP token or VaaS key can also provided.

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
Get-TppCustomField -Class 'X509 Certificate'
Get custom fields for certificates

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppCustomField/

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-GetItemsForClass.php

.NOTES
All custom fields are retrieved upon inital connect to the server and a property of VenafiSession
#>
function Get-TppCustomField {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Class,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'
    }

    process {
        $params = @{
            VenafiSession = $VenafiSession
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
