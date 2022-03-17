<#
.SYNOPSIS
Get Team info

.DESCRIPTION
Get info for a VaaS or TPP team including members and owners.
For VaaS, you can retrieve info on all teams as well.

.PARAMETER ID
Team ID, required for TPP.
For VaaS, this is the team guid.
For TPP, this is the local prefixed universal ID.  You can find the group ID with Find-TppIdentity.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
ID

.OUTPUTS
PSCustomObject

.EXAMPLE
Get-VenafiTeam -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Get info for a VaaS team

.EXAMPLE
Get-VenafiTeam -ID 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}'
Get info for a TPP team

.EXAMPLE
Get-VenafiTeam -All
Get info for all teams.  VaaS only.

.LINK
https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Teams/get_2

.LINK
https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=account-service#/Teams/get_1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Teams-prefix-universal.php
#>
function Get-VenafiTeam {

    [CmdletBinding()]
    param (

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $ID,

        [Parameter(Mandatory, ParameterSetName='All')]
        [switch] $All,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate()

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Get'
        }
    }

    process {

        if ( $VenafiSession.Platform -eq 'VaaS' ) {

            if ( $Id ) {
                $params.UriLeaf = "teams/$ID"
            }
            else {
                $params.UriLeaf = 'teams'
            }

            $response = Invoke-VenafiRestMethod @params

            if ( $response.PSObject.Properties.Name -contains 'teams' ) {
                $response | Select-Object -ExpandProperty teams
            }
            else {
                $response
            }
        }
        else {
            if ( $PSCmdlet.ParameterSetName -eq 'All' ) {
                throw "-All not supported for TPP"
            }

            # check if just a guid or prefixed universal id
            if ( Test-TppIdentityFormat -Identity $ID ) {
                $guid = [guid]($ID.Replace('local:', ''))
            }
            else {
                try {
                    $guid = [guid] $ID
                }
                catch {
                    Write-Error "$ID is not a valid team id"
                    Continue
                }
            }
            $params.UriLeaf = ('Teams/local/{{{0}}}' -f $guid.ToString())

            $response = Invoke-VenafiRestMethod @params

            $out = [pscustomobject] ($response.ID | ConvertTo-TppIdentity)
            $out | Add-Member @{
                Members = $response.Members | ConvertTo-TppIdentity
                Owners  = $response.Owners | ConvertTo-TppIdentity
            }
            $out
        }
    }
}
