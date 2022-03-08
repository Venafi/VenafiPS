<#
.SYNOPSIS
Get custom field details

.DESCRIPTION
Get details about custom fields

.PARAMETER Class
Class to get details on

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

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
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-GetItemsForClass.php?tocpath=Web%20SDK%7CMetadata%20custom%20fields%20programming%20interface%7C_____10

.NOTES
All custom fields are retrieved upon inital connect to the server and a property of VenafiSession
#>
function Get-TppCustomField {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Class,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate() | Out-Null
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
