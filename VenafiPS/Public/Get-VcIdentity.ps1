function Get-VcIdentity {
    <#
    .SYNOPSIS
    Get user and group details

    .DESCRIPTION
    Returns user/group information for TLSPC.

    .PARAMETER ID
    Either be the user id (guid) or username which is the email address.

    .PARAMETER Me
    Returns the identity of the authenticated/current user

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
    Get-VcIdentity -ID 9e9db8d6-234a-409c-8299-e3b81ce2f916

    Get identity details from an id

    .EXAMPLE
    Get-VcIdentity -ID me@x.com

    Get identity details from a username

    .EXAMPLE
    Get-VcIdentity -Me

    Get identity details for authenticated/current user

    .EXAMPLE
    Get-VcIdentity -All

    Get all users

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Users/users_getByUsername
    #>

    [CmdletBinding(DefaultParameterSetName = 'Id')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = "Parameter is used")]

    param (
        [Parameter(Mandatory, ParameterSetName = 'Id', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('Guid', 'FullName')]
        [String] $ID,

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
                # can search by user id (guid) or username
                try {
                    $guid = [guid] $ID
                    $params.UriLeaf = 'users/{0}' -f $guid.ToString()
                    $response = Invoke-VenafiRestMethod @params
                }
                catch {
                    $params.UriLeaf = 'users/username/{0}' -f $ID
                    $response = Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty users
                }

            }

            'Me' {
                $params.UriLeaf = 'useraccounts'
                $response = Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty user
            }

            'All' {
                $params.UriLeaf = 'users'
                $response = Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty users
            }
        }
    }
}