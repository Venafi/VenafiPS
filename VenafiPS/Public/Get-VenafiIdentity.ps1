<#
.SYNOPSIS
Get user and group details

.DESCRIPTION
Returns user/group information for VaaS and TPP.
For VaaS, this returns user information.
For TPP, this returns individual identity, group identity, or distribution groups from a local or non-local provider such as Active Directory.

.PARAMETER ID
For TPP this is the guid or prefixed universal id.  To search, use Find-TppIdentity.
For VaaS this can either be the user id (guid) or username which is the email address.

.PARAMETER IncludeAssociated
Include all associated identity groups and folders.  TPP only.

.PARAMETER IncludeMembers
Include all individual members if the ID is a group.  TPP only.

.PARAMETER Me
Returns the identity of the authenticated/current user

.PARAMETER All
Return a complete list of local users.

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
ID

.OUTPUTS
PSCustomObject
For TPP:
    Name
    ID
    Path
    FullName
    Associated (if -IncludeAssociated provided)
    Members (if -IncludeMembers provided)
For VaaS:
    username
    id
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
Get-VenafiIdentity -ID 'AD+myprov:asdfgadsf9g87df98g7d9f8g7'

Get TPP identity details from an id

.EXAMPLE
Get-VenafiIdentity -ID 9e9db8d6-234a-409c-8299-e3b81ce2f916

Get VaaS identity details from an id

.EXAMPLE
Get-VenafiIdentity -ID me@x.com

Get VaaS identity details from a username

.EXAMPLE
Get-VenafiIdentity -ID 'AD+myprov:asdfgadsf9g87df98g7d9f8g7' -IncludeMembers

Get TPP identity details.  If the identity is a group it will also return the members

.EXAMPLE
Get-VenafiIdentity -ID 'AD+myprov:asdfgadsf9g87df98g7d9f8g7' -IncludeAssociated

Get TPP identity details from an id and include associated groups/folders

.EXAMPLE
Get-VenafiIdentity -Me

Get identity details for authenticated/current user, TPP or VaaS

.EXAMPLE
Get-VenafiIdentity -All

Get all users (VaaS) or all users/groups (TPP)

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppIdentity/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppIdentity.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Validate.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Identity-Self.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-GetAssociatedEntries.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-GetMembers.php

.LINK
https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Users/users_getAll

.LINK
https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Users/users_getById

.LINK
https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Users/users_getByUsername
#>
function Get-VenafiIdentity {

    [CmdletBinding(DefaultParameterSetName = 'Id')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = "Parameter is used")]
    [Alias('Get-TppIdentity')]

    param (
        [Parameter(Mandatory, ParameterSetName = 'Id', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('Guid', 'FullName')]
        [String] $ID,

        [Parameter(Mandatory, ParameterSetName = 'Me')]
        [Switch] $Me,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [Switch] $All,

        [Parameter(ParameterSetName = 'Id')]
        [Parameter(ParameterSetName = 'All')]
        [Switch] $IncludeAssociated,

        [Parameter(ParameterSetName = 'Id')]
        [Parameter(ParameterSetName = 'All')]
        [Switch] $IncludeMembers,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        $platform = Test-VenafiSession -VenafiSession $VenafiSession -PassThru

        Write-Verbose ('{0} : {1} : Parameterset {2}' -f $PsCmdlet.MyInvocation.MyCommand, $platform, $PsCmdlet.ParameterSetName)

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Get'
        }

    }

    process {

        if ( $platform -eq 'VaaS' ) {

            if ( $IncludeAssociated -or $IncludeMembers ) {
                Write-Warning '-IncludeAssociated and -IncludeMembers are only applicable to TPP'
            }

            Switch ($PsCmdlet.ParameterSetName)	{
                'Id' {
                    # can search by user id (guid) or username
                    try {
                        $guid = [guid] $ID
                        $params.UriLeaf = 'users/{0}' -f $guid.ToString()
                        Invoke-VenafiRestMethod @params
                    } catch {
                        $params.UriLeaf = 'users/username/{0}' -f $ID
                        Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty users
                    }

                }

                'Me' {
                    $params.UriLeaf = 'useraccounts'
                    Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty user
                }

                'All' {
                    $params.UriLeaf = 'users'
                    Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty users
                }
            }
        } else {

            Switch ($PsCmdlet.ParameterSetName)	{
                'Id' {

                    $params.Method = 'Post'
                    $params.UriLeaf = 'Identity/Validate'
                    $params.Body = @{'ID' = @{ } }

                    if ( Test-TppIdentityFormat -ID $ID -Format 'Universal' ) {
                        $params.Body.ID.PrefixedUniversal = $ID
                    } elseif ( Test-TppIdentityFormat -ID $ID -Format 'Name' ) {
                        $params.Body.ID.PrefixedName = $ID
                    } elseif ( [guid]::TryParse($ID, $([ref][guid]::Empty)) ) {
                        $guid = [guid] $ID
                        $params.Body.ID.PrefixedUniversal = 'local:{{{0}}}' -f $guid.ToString()
                    } else {
                        Write-Error "'$ID' is not a valid identity"
                        return
                    }

                    $response = Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty ID

                    if ( $IncludeAssociated ) {
                        $assocParams = $params.Clone()
                        $assocParams.UriLeaf = 'Identity/GetAssociatedEntries'
                        $associated = Invoke-VenafiRestMethod @assocParams
                        $response | Add-Member @{ 'Associated' = $null }
                        $response.Associated = $associated.Identities | ConvertTo-TppIdentity
                    }

                    if ( $IncludeMembers ) {
                        $response | Add-Member @{ 'Members' = $null }
                        if ( $response.IsGroup ) {
                            $assocParams = $params.Clone()
                            $assocParams.UriLeaf = 'Identity/GetMembers'
                            $assocParams.Body.ResolveNested = "1"
                            $members = Invoke-VenafiRestMethod @assocParams
                            $response.Members = $members.Identities | ConvertTo-TppIdentity
                        }
                    }

                    $idOut = $response
                }

                'Me' {
                    $params.UriLeaf = 'Identity/Self'
                    $response = Invoke-VenafiRestMethod @params

                    $idOut = $response.Identities | Select-Object -First 1
                }

                'All' {
                    # no built-in api for this, get group objects and then get details
                    Find-TppObject -Path '\VED\Identity' -Class 'User', 'Group' -VenafiSession $VenafiSession | Get-VenafiIdentity -IncludeAssociated:$IncludeAssociated.IsPresent -IncludeMembers:$IncludeMembers.IsPresent -VenafiSession $VenafiSession
                }
            }

            if ( $idOut ) {
                $idOut | ConvertTo-TppIdentity
            }
        }
    }
}