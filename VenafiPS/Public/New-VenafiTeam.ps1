function New-VenafiTeam {
    <#
    .SYNOPSIS
    Create a new team

    .DESCRIPTION
    Create a new VaaS or TPP team

    .PARAMETER Name
    Team name

    .PARAMETER Owner
    1 or more owners for the team
    For VaaS, this is the unique guid obtained from Get-VenafiIdentity.
    For TPP, this is the identity ID property from Find-TppIdentity or Get-VenafiIdentity.

    .PARAMETER Member
    1 or more members for the team
    For VaaS, this is the unique guid obtained from Get-VenafiIdentity.
    For TPP, this is the identity ID property from Find-TppIdentity or Get-VenafiIdentity.

    .PARAMETER Role
    Team role, either 'System Admin', 'PKI Admin', 'Resource Owner' or 'Guest'.  VaaS only.

    .PARAMETER UserMatchingRule
    If SSO is enabled, build your team membership rules to organize your users into teams automatically.
    If more than 1 rule is configured, they must all be met for a user to meet the criteria.
    Each rule should be of the format @('claim name', 'operator', 'value')
    where operator can be equals, not_equals, contains, not_contains, starts_with, or ends_with.

    .PARAMETER Policy
    1 or more policy folder paths this team manages.  TPP only.

    .PARAMETER Product
    1 or more product names, 'TLS', 'SSH', and/or 'Code Signing'.  TPP only.

    .PARAMETER Description
    Team description or purpose.  TPP only.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .EXAMPLE
    New-VenafiTeam -Name 'My New Team' -Member 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Owner @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4') -Role 'System Admin'

    Create a new VaaS team

    .EXAMPLE
    New-VenafiTeam -Name 'My New Team' -Member 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Owner @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4') -Role 'System Admin' -UserMatchingRule @('MyClaim', 'CONTAINS', 'Group')

    Create a new VaaS team with user matching rule

    .EXAMPLE
    New-VenafiTeam -Name 'My New Team' -Member 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Owner @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4') -Role 'System Admin' -PassThru

    id                : a7d60730-a967-11ec-8832-4d051bf6d0b4
    name              : My New Team
    systemRoles       : {SYSTEM_ADMIN}
    productRoles      :
    role              : SYSTEM_ADMIN
    members           : {443de910-a6cc-11ec-ad22-018e33741844}
    owners            : {0a2adae0-b22b-11ea-91f3-ebd6dea5452e}
    companyId         : 09b24f81-b22b-11ea-91f3-ebd6dea5452e
    userMatchingRules : {}
    modificationDate  : 3/21/2022 6:38:40 PM

    Create a new VaaS team returning the new team

    .EXAMPLE
    New-VenafiTeam -Name 'My New Team' -Member 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Owner 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}' -Product 'TLS'

    Create a new TPP team

    .EXAMPLE
    New-VenafiTeam -Name 'My New Team' -Member 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Owner 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}' -Product 'TLS' -Policy '\ved\policy\myfolder'

    Create a new TPP team and assign it to a policy

    .EXAMPLE
    New-VenafiTeam -Name 'My New Team' -Member 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Owner 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}' -Product 'TLS' -Description 'One amazing team'

    Create a new TPP team with optional description

    .EXAMPLE
    New-VenafiTeam -Name 'My New Team' -Member 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Owner 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}' -Product 'TLS' -PassThru

    Name     : My New Team
    ID       : local:{a6053090-e309-49d9-98a7-28cbe7896c27}
    Path     : \VED\Identity\My New Team
    FullName : local:My New Team
    IsGroup  : True
    Members  : @{Name=sample-user; ID=local:{6baad36c-7cac-48c8-8e54-000cc22ad88f};
               Path=\VED\Identity\sample-user; FullName=local:sample-user; IsGroup=False}
    Owners   : @{Name=sample-owner; ID=local:{d1a76bc7-d3a6-431b-9bea-d2d8780ecd86};
               Path=\VED\Identity\sample-owner; FullName=local:sample-owner; IsGroup=False}

    Create a new TPP team returning the new team

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html#/Teams/create_1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Teams.php

    .LINK
    https://docs.venafi.cloud/vcs-platform/creating-new-teams/
    #>

    [CmdletBinding()]

    param (

        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string[]] $Owner,

        [Parameter(Mandatory)]
        [string[]] $Member,

        [Parameter(Mandatory, ParameterSetName = 'VaaS')]
        [ValidateSet('System Admin', 'PKI Admin', 'Resource Owner', 'Guest')]
        [string] $Role,

        [Parameter(ParameterSetName = 'VaaS')]
        [System.Collections.Generic.List[array]] $UserMatchingRule,

        [Parameter(ParameterSetName = 'TPP')]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                } else {
                    throw "'$_' is not a valid policy path"
                }
            })]
        [string[]] $Policy,

        [Parameter(Mandatory, ParameterSetName = 'TPP')]
        [ValidateSet('TLS', 'SSH', 'Code Signing')]
        [string[]] $Product,

        [Parameter(ParameterSetName = 'TPP')]
        [string] $Description,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        $platform = Test-VenafiSession -VenafiSession $VenafiSession -Platform $PSCmdlet.ParameterSetName -PassThru
    }

    process {

        $params = @{
            VenafiSession = $VenafiSession
        }

        if ( $platform -eq 'VaaS' ) {

            $rules = foreach ($rule in $UserMatchingRule) {

                if ( $rule.Count -ne 3 ) {
                    throw 'Each rule must contain a claim name, operator, and value'
                }

                if ( $rule[1].ToUpper() -notin 'EQUALS', 'NOT_EQUALS', 'CONTAINS', 'NOT_CONTAINS', 'STARTS_WITH', 'ENDS_WITH') {
                    throw 'Valid values for operator are EQUALS, NOT_EQUALS, CONTAINS, NOT_CONTAINS, STARTS_WITH, ENDS_WITH'
                }

                @{
                    'claimName' = $rule[0]
                    'operator'  = $rule[1].ToUpper()
                    'value'     = $rule[2]
                }
            }

            $params.Method = 'Post'
            $params.UriLeaf = "teams"
            $params.Body = @{
                'name'              = $Name
                'role'              = $Role.Replace(' ', '_').ToUpper()
                'members'           = @($Member)
                'owners'            = @($Owner)
                'userMatchingRules' = @($rules)
            }

            $response = Invoke-VenafiRestMethod @params

        } else {

            $members = foreach ($thisMember in $Member) {
                if ( $thisMember.StartsWith('local') ) {
                    $memberIdentity = Get-VenafiIdentity -ID $thisMember -VenafiSession $VenafiSession
                    @{
                        'PrefixedName'      = $memberIdentity.FullName
                        'PrefixedUniversal' = $memberIdentity.ID
                    }
                } else {
                    @{'PrefixedUniversal' = $thisMember }
                }
            }
            $owners = foreach ($thisOwner in $Owner) {
                if ( $thisOwner.StartsWith('local') ) {
                    $ownerIdentity = Get-VenafiIdentity -ID $thisOwner -VenafiSession $VenafiSession
                    @{
                        'PrefixedName'      = $ownerIdentity.FullName
                        'PrefixedUniversal' = $ownerIdentity.ID
                    }
                } else {
                    @{'PrefixedUniversal' = $thisOwner }
                }
            }
            $params.Method = 'Post'
            $params.UriLeaf = 'Teams/'
            $params.Body = @{
                'Name'     = @{'PrefixedName' = "local:$Name" }
                'Members'  = @($members)
                'Owners'   = @($owners)
                'Products' = @($Product)
            }

            if ( $Policy ) {
                $params.Body.Add('Assets', @($Policy))
            }

            if ( $Description ) {
                $params.Body.Add('Description', $Description)
            }

            $response = Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty ID
        }

        if ( $PassThru ) {
            $response | Get-VenafiTeam -VenafiSession $VenafiSession
        }
    }
}
