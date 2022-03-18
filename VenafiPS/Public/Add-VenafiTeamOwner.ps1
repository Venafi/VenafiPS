<#
.SYNOPSIS
Add owners to a team

.DESCRIPTION
Add owners to either a VaaS or TPP team

.PARAMETER ID
Team ID.
For VaaS, this is the unique guid obtained from Get-VenafiTeam.
For TPP, this is the ID property from Find-TppIdentity or Get-VenafiTeam.

.PARAMETER Owner
1 or more owners to add to the team
For VaaS, this is the unique guid obtained from Get-VenafiIdentity.
For TPP, this is the identity ID property from Find-TppIdentity or Get-VenafiIdentity.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
ID

.EXAMPLE
Add-VenafiTeamOwner -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Owner @('ca7ff555-88d2-4bfc-9efa-2630ac44c1f3', 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f4')

Add owners to a VaaS team

.EXAMPLE
Add-VenafiTeamOwner -ID 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}' -Owner 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e7}'

Add owners to a TPP team

.LINK
https://api.venafi.cloud/webjars/swagger-ui/index.html?configUrl=%2Fv3%2Fapi-docs%2Fswagger-config&urls.primaryName=outagedetection-service#/Teams/addOwner

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-PUT-Teams-AddTeamOwners.php
#>
function Add-VenafiTeamOwner {

    [CmdletBinding()]
    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $ID,

        [Parameter(Mandatory)]
        [string[]] $Owner,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate()

        $params = @{
            VenafiSession = $VenafiSession
        }
    }

    process {

        if ( $VenafiSession.Platform -eq 'VaaS' ) {

            $params.Method = 'Post'
            $params.UriLeaf = "teams/$ID/owners"
            $params.Body = @{
                'owners' = @($Owner)
            }
        }
        else {
            $teamName = Get-VenafiIdentity -ID $ID -VenafiSession $VenafiSession | Select-Object -ExpandProperty FullName
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
            $params.Method = 'Put'
            $params.UriLeaf = 'Teams/AddTeamOwners'
            $params.Body = @{
                'Team'   = @{'PrefixedName' = $teamName }
                'Owners' = @($owners)
            }
        }

        Invoke-VenafiRestMethod @params | Out-Null
    }
}
