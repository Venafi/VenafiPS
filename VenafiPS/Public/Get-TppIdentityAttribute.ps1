<#
.SYNOPSIS
Get attribute values for TPP identity objects

.DESCRIPTION
Get attribute values for TPP identity objects.

.PARAMETER ID
The id that represents the user or group.  Use Find-TppIdentity to get the id.

.PARAMETER Attribute
Retrieve identity attribute values for the users and groups.
Common user attributes include Group Membership, Name, Internet Email Address, Given Name, and Surname.

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
ID

.OUTPUTS
PSCustomObject with the properties Identity and Attribute

.EXAMPLE
Get-TppIdentityAttribute -IdentityId 'AD+blah:{1234567890olikujyhtgrfedwsqa}'

Get basic attributes

.EXAMPLE
Get-TppIdentityAttribute -IdentityId 'AD+blah:{1234567890olikujyhtgrfedwsqa}' -Attribute 'Surname'

Get specific attribute for user

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppIdentityAttribute/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppIdentityAttribute.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Validate.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Readattribute.php

#>
function Get-TppIdentityAttribute {

    [CmdletBinding()]
    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('PrefixedUniversalId', 'Contact', 'IdentityId')]
        [string[]] $ID,

        [Parameter()]
        [string[]] $Attribute,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        # Test-VenafiSession -VenafiSession $VenafiSession

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'Identity/Validate'
            Body       = @{
                'ID' = @{
                    PrefixedUniversal = 'placeholder'
                }
            }
        }

        if ( $PSBoundParameters.ContainsKey('Attribute') ) {
            $params.UriLeaf = 'Identity/ReadAttribute'
            $params.Body.Add('AttributeName', 'placeholder')
        }

    }

    process {

        foreach ( $thisId in $ID ) {

            $params.Body.ID.PrefixedUniversal = $thisId

            if ( $PSBoundParameters.ContainsKey('Attribute') ) {

                $attribHash = @{ }
                foreach ( $thisAttribute in $Attribute ) {

                    $params.Body.AttributeName = $thisAttribute

                    $response = Invoke-VenafiRestMethod @params
                    if ( $response.Attributes ) {
                        $attribHash.$thisAttribute = $response.Attributes[0]
                    }
                }

                $attribsOut = [PSCustomObject] $attribHash

            } else {
                $response = Invoke-VenafiRestMethod @params
                $attribsOut = $response.Id
            }

            [PSCustomObject] @{
                ID         = $thisId
                Attributes = $attribsOut
            }
        }
    }
}
