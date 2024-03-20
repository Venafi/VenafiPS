function Revoke-VdcGrant {

    <#
    .SYNOPSIS
    Revoke all grants for a specific user

    .DESCRIPTION
    Revoke all grants for a specific user.
    You must either be an administrator or oauth administrator to perform this action.
    Also, your token must have the admin:delete scope.
    Available in TLSPDC v22.3 and later.

    .PARAMETER ID
    Prefixed universal id for the user.  To search, use Find-VdcIdentity.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

    .INPUTS
    ID

    .OUTPUTS
    None

    .EXAMPLE
    Revoke-VdcGrant -ID local:{9e9db8d6-234a-409c-8299-e3b81ce2f916}

    Revoke all grants for a user

    .EXAMPLE
    Get-VdcIdentity -ID me@x.com | Revoke-VdcGrant

    Revoke all grants getting universal id from other identity functions

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Revoke-VdcGrant/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Revoke-VdcGrant.ps1

    .LINK
    https://doc.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-oauth-revokegrants.htm

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [Alias('Revoke-TppGrant')]

    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript( {
                if ( Test-VdcIdentityFormat -ID $_ -Format 'Universal' ) {
                    $true
                } else {
                    throw "'$_' is not a valid prefixed universal identity format.  See https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-IdentityInformation.php."
                }
            })]
        [Alias('PrefixedUniversalID', 'IdentityID')]
        [string[]] $ID
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VDC' -AuthType 'token'

        if ( $VenafiSessionNested.Version -lt [Version]::new('22', '3', '0') ) {
            throw 'Revoke-VdcGrant is available on TLSPDC v22.3 and greater'
        }

        $params = @{
            Method        = 'Post'
            UriLeaf       = 'oauth/revokegrants'
            Body          = @{}
            FullResponse  = $true
        }
    }

    process {

        foreach ($thisID in $ID) {
            $params.Body.GranteePrefixedUniversal = $thisID

            if ( $PSCmdlet.ShouldProcess($thisID, 'Revoke all grants') ) {
                $response = Invoke-VenafiRestMethod @params

                switch ( $response.StatusCode ) {
                    200 {
                        if ( $response.Result -eq 1 ) {
                            Write-Error 'Grant revocation was unsuccessful'
                        }
                    }

                    401 {
                        if ( $response.Error.error -eq 'insufficient_rights' ) {
                            throw 'The token user account does not have sufficient permissions for this request.  You must be an administrator or OAuth administrator.'
                        }
                    }

                    403 {
                        throw 'The access token provided does not have the admin:delete scope.  Create a new token with this scope and try again.'
                    }

                    Default {
                        throw $response.Error
                    }
                }
            }
        }
    }
}