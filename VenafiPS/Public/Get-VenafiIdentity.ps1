<#
.SYNOPSIS
Get user and group details

.DESCRIPTION
Returns user/group information for VaaS and TPP.
For VaaS, this returns user information.
For TPP, this returns individual identity, group identity, or distribution groups from a local or non-local provider such as Active Directory.

.PARAMETER ID
For TPP this is the individual identity, group identity, or distribution group prefixed universal id.  To search, use Find-TppIdentity.
For VaaS this can either be the user id (guid) or username which is the email address.

.PARAMETER IncludeAssociated
Include all associated identity groups and folders.  TPP only.

.PARAMETER IncludeMembers
Include all individual members if the ID is a group.  TPP only.

.PARAMETER Me
Returns the identity of the authenticated/current user

.PARAMETER All
Return a complete list of users.  VaaS only.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

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

    param (
        [Parameter(Mandatory, ParameterSetName = 'Id', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String[]] $ID,

        [Parameter(ParameterSetName = 'Id')]
        [Switch] $IncludeAssociated,

        [Parameter(ParameterSetName = 'Id')]
        [Switch] $IncludeMembers,

        [Parameter(Mandatory, ParameterSetName = 'Me')]
        [Switch] $Me,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [Switch] $All,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate()

        Write-Verbose ('{0} : {1} : Parameterset {2}' -f $PsCmdlet.MyInvocation.MyCommand, $VenafiSession.Platform, $PsCmdlet.ParameterSetName)

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Get'
        }

    }

    process {

        if ( $VenafiSession.Platform -eq 'VaaS' ) {
            Switch ($PsCmdlet.ParameterSetName)	{
                'Id' {
                    # can search by user id (guid) or username
                    try {
                        $guid = [guid] $ID
                        $params.UriLeaf = 'users/{0}' -f $guid.ToString()
                        Invoke-VenafiRestMethod @params
                    }
                    catch {
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
        }
        else {

            Switch ($PsCmdlet.ParameterSetName)	{
                'Id' {

                    $params.Method = 'Post'
                    $params.UriLeaf = 'Identity/Validate'
                    $params.Add('Body', @{'ID' = @{'PrefixedUniversal' = '' } })

                    $idOut = foreach ( $thisId in $ID ) {

                        $params.Body.Id.PrefixedUniversal = $thisId

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

                        $response
                    }
                }

                'Me' {
                    $params.UriLeaf = 'Identity/Self'
                    $response = Invoke-VenafiRestMethod @params

                    $idOut = $response.Identities | Select-Object -First 1
                }

                'All' {
                    # no built-in api for this, get group objects and then get details
                    $identities = Find-TppObject -Path '\VED\Identity' -Recursive -Class 'User', 'Group' -VenafiSession $VenafiSession
                    foreach ($identity in $identities ) {
                        Get-VenafiIdentity -ID ('local:{{{0}}}' -f $identity.guid) -VenafiSession $VenafiSession
                    }
                }
            }

            if ( $idOut ) {
                $idOut | ConvertTo-TppIdentity
            }
        }
    }
}