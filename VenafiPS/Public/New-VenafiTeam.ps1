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

.PARAMETER Product
1 or more product names, 'TLS', 'SSH', and/or 'Code Signing'.  TPP only.

.PARAMETER Description
Team description or purpose.  TPP only.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.EXAMPLE
New-VenafiTeam -Name 'My New Team' -Member 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Owner @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4') -Role 'System Admin'

Create a new VaaS team

.EXAMPLE
New-VenafiTeam -Name 'My New Team' -Member 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Owner 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}' -Product 'TLS'

Create a new TPP team

.LINK
https://api.venafi.cloud/webjars/swagger-ui/index.html#/Teams/create_1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Teams.php
#>
function New-VenafiTeam {

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

        [Parameter(Mandatory, ParameterSetName = 'TPP')]
        [ValidateSet('TLS', 'SSH', 'Code Signing')]
        [string[]] $Product,

        [Parameter(ParameterSetName = 'TPP')]
        [string[]] $Description,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    $VenafiSession.Validate($PSCmdlet.ParameterSetName)

    $params = @{
        VenafiSession = $VenafiSession
    }

    if ( $VenafiSession.Platform -eq 'VaaS' ) {

        $params.Method = 'Post'
        $params.UriLeaf = "teams"
        $params.Body = @{
            'name'              = $Name
            'role'              = $Role.Replace(' ', '_').ToUpper()
            'members'           = @($Member)
            'owners'            = @($Owner)
            'userMatchingRules' = @()
        }

        $response = Invoke-VenafiRestMethod @params

    }
    else {

        $members = foreach ($thisMember in $Member) {
            if ( $thisMember.StartsWith('local') ) {
                $memberIdentity = Get-VenafiIdentity -ID $thisMember -VenafiSession $VenafiSession
                @{
                    'PrefixedName'      = $memberIdentity.FullName
                    'PrefixedUniversal' = $memberIdentity.ID
                }
            }
            else {
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
            }
            else {
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

        if ( $Description ) {
            $params.Body.Add('Description', $Description)
        }

        $response = Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty ID | ConvertTo-TppIdentity
    }

    if ( $PassThru ) {
        $response
    }
}
