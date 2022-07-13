function Test-TppIdentity {
    <#
    .SYNOPSIS
    Test if an identity exists

    .DESCRIPTION
    Provided with a prefixed universal id, find out if an identity exists.

    .PARAMETER Identity
    The id that represents the user or group.

    .PARAMETER ExistOnly
    Only return boolean instead of ID and Exists list.  Helpful when validating just 1 identity.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    Identity

    .OUTPUTS
    PSCustomObject will be returned with properties 'ID', a System.String, and 'Exists', a System.Boolean.

    .EXAMPLE
    'local:78uhjny657890okjhhh', 'AD+mydomain.com:azsxdcfvgbhnjmlk09877654321' | Test-TppIdentity

    Test multiple identities

    .EXAMPLE
    Test-TppIdentity -Identity 'AD+mydomain.com:azsxdcfvgbhnjmlk09877654321' -ExistOnly

    Retrieve existence for only one identity, returns boolean

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Test-TppIdentity/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Test-TppIdentity.ps1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Validate.php

    #>

    [CmdletBinding()]

    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript( {
                if ( $_ | Test-TppIdentityFormat ) {
                    $true
                } else {
                    throw "'$_' is not a valid Prefixed Universal Id format.  See https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-IdentityInformation.php."
                }
            })]
        [Alias('PrefixedUniversal', 'Contact', 'IdentityId', 'FullName')]
        [string[]] $ID,

        [Parameter()]
        [Switch] $ExistOnly,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriLeaf       = 'Identity/Validate'
        }
    }

    process {

        foreach ( $thisID in $ID ) {

            $params.Body = @{
                'ID' = @{}
            }

            if ( Test-TppIdentityFormat -ID $thisID -Format 'Universal' ) {
                $params.Body.ID.PrefixedUniversal = $thisId
            } else {
                $params.Body.ID.PrefixedName = $thisId
            }

            $response = Invoke-VenafiRestMethod @params

            if ( $ExistOnly ) {
                $null -ne $response.Id
            } else {
                [PSCustomObject] @{
                    Identity = $thisId
                    Exists   = ($null -ne $response.Id)
                }
            }
        }
    }
}
