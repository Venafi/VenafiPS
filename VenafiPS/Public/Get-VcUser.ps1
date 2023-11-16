function Get-VcUser {
    <#
    .SYNOPSIS
    Get user details

    .DESCRIPTION
    Returns user information for TLSPC.

    .PARAMETER ID
    Either be the user id (guid) or username which is the email address.

    .PARAMETER Me
    Returns details of the authenticated/current user

    .PARAMETER All
    Return a complete list of local users.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    ID

    .OUTPUTS
    PSCustomObject
        username
        userId
        companyId
        firstname
        lastname
        emailAddress
        userType
        userAccountType
        userStatus
        systemRoles
        productRoles
        localLoginDisabled
        hasPassword
        firstLoginDate
        creationDate
        ownedTeams
        memberedTeams

    .EXAMPLE
    Get-VcUser -ID 9e9db8d6-234a-409c-8299-e3b81ce2f916

    Get user details from an id

    .EXAMPLE
    Get-VcUser -ID 'greg.brownstein@venafi.com'

    Get user details from a username

    .EXAMPLE
    Get-VcUser -Me

    Get user details for authenticated/current user

    .EXAMPLE
    Get-VcUser -All

    Get all users

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Users/users_getByUsername
    #>

    [CmdletBinding(DefaultParameterSetName = 'Id')]
    [Alias('Get-VcIdentity')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = "Parameter is used")]

    param (
        [Parameter(Mandatory, ParameterSetName = 'Id', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('userId', 'owningUser', 'owningUsers', 'owningUserId')]
        [String[]] $ID,

        [Parameter(Mandatory, ParameterSetName = 'Me')]
        [Switch] $Me,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [Switch] $All,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'
    }

    process {

        Switch ($PsCmdlet.ParameterSetName)	{
            'Id' {
                if ( $ID.Count -gt 1 ) {
                    foreach ($teamId in $ID) {
                        Get-VcUser -ID $teamId
                    }
                }
                else {
                    $thisID = $ID[0]
                }

                # can search by user id (guid) or username
                try {
                    $guid = [guid] $thisID
                    $response = Invoke-VenafiRestMethod -UriLeaf ('users/{0}' -f $guid.ToString())
                }
                catch {
                    $response = Invoke-VenafiRestMethod -UriLeaf "users/username/$thisID" | Select-Object -ExpandProperty users
                }

            }

            'Me' {
                $response = Invoke-VenafiRestMethod -UriLeaf 'useraccounts' | Select-Object -ExpandProperty user
            }

            'All' {
                $response = Invoke-VenafiRestMethod -UriLeaf 'users' | Select-Object -ExpandProperty users
            }
        }

        $response | Select-Object @{'n' = 'userId'; 'e' = { $_.id } }, * -ExcludeProperty id
    }
}