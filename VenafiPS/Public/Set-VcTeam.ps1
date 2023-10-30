﻿function Set-VcTeam {
    <#
    .SYNOPSIS
    Update an existing team

    .DESCRIPTION
    Update name, role, and/or user matching rules for existing teams.

    .PARAMETER ID
    Team ID or name

    .PARAMETER Name
    Provide a new name for the team if you wish to change it.

    .PARAMETER Role
    Provide a new role for the team if you wish to change it.
    Accepted values are 'System Admin', 'PKI Admin', 'Resource Owner', or 'Guest'

    .PARAMETER UserMatchingRule
    Rule(s) for user membership which matches SSO claim data.
    Each rule has 3 parts, ClaimName, Operator, and ClaimValue, in the form of a hashtable.
    A list/array of hashtables is supported.
    For a singlepart claim, the operator can be 'equals', 'does not equal', 'starts with', or 'ends with'.
    For a multivalue claim where ClaimValue will be an array, the operator can be 'contains' or 'does not contain'.
    ClaimName and ClaimValue are case sensitive.
    When providing user AD groups or other groups they are most commonly provided as multivalue claims.
    This parameter will overwrite existing rules by default.  To append use -NoOverwrite.

    .PARAMETER NoOverwrite
    Append to existing user matching rules as opposed to overwriting

    .PARAMETER PassThru
    Return the newly updated team object

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    ID

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Set-VcTeam -ID 'MyTeam' -Name 'ThisTeamIsBetter'

    Rename an existing team

    .EXAMPLE
    Set-VcTeam -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Role 'PKI Admin'

    Change the role for an existing team

    .EXAMPLE
    Set-VcTeam -ID 'MyTeam' -UserMatchingRule @{'ClaimName'='MyClaim';'Operator'='equals';'ClaimValue'='matchme'}

    Replace a teams user matching rules

    .EXAMPLE
    Set-VcTeam -ID 'MyTeam' -UserMatchingRule @{'ClaimName'='MyClaim';'Operator'='equals';'ClaimValue'='matchme'} -NoOverwrite

    Update a teams user matching rules, appending instead of overwriting

    .EXAMPLE
    Set-VcTeam -ID 'MyTeam' -Name 'ThisTeamIsBetter' -PassThru

    Rename an existing team and return the updated team object

    .EXAMPLE
    Get-VcTeam -All | Where-Object {$_.name -like '*shouldnt be sysadmin*'} | Set-VcTeam -NewRole 'PKI Admin'

    Update many teams
    #>

    [CmdletBinding()]
    [Alias('Set-VaasTeam')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipelineByPropertyName)]
        [Alias('teamId')]
        [string] $ID,

        [Parameter()]
        [string] $Name,

        [Parameter()]
        [ValidateSet('System Admin', 'PKI Admin', 'Resource Owner', 'Guest')]
        [string] $Role,

        [Parameter()]
        [ValidateScript({
                foreach ($rule in $_) {
                    if ( $rule.Keys -contains 'ClaimName' -and $rule.Keys -contains 'Operator' -and $rule.Keys -contains 'ClaimValue' ) {
                        if ( $rule.Operator.Replace(' ', '_').ToUpper() -notin 'EQUALS', 'NOT_EQUALS', 'CONTAINS', 'NOT_CONTAINS', 'STARTS_WITH', 'ENDS_WITH') {
                            throw 'Operator must be one of the following: Equals, Not Equals, Contains, Not Contains, Starts With, or Ends With'
                        }
                        $true
                    }
                    else {
                        throw 'NewUserMatchingRule is an array of hashtables where each hashtable must contain keys ''ClaimName'', ''Operator'', and ''ClaimValue''.'
                    }
                }
            })]
        [hashtable[]] $UserMatchingRule,

        [Parameter()]
        [switch] $NoOverwrite,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [Alias('Key')]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Patch'
            Body          = @{}
        }
    }

    process {

        $thisID = if ( Test-IsGuid($ID) ) {
            $ID
        }
        else {
            if ( -not $allTeams ) {
                $allTeams = Get-VcTeam -All
            }
            $allTeams | Where-Object { $_.name -ieq $ID } | Select-Object -ExpandProperty teamId
        }

        if ( -not $thisID ) {
            # process the next one in the pipeline if we don't have a valid ID this time
            Write-Error "Team $ID does not exist"
            Continue
        }

        $params.UriLeaf = "teams/$thisID"

        if ( $Name ) {
            $params.Body.name = $Name
        }

        if ( $Role ) {
            $params.Body.role = $Role.Replace(' ', '_').ToUpper()
        }

        if ( $UserMatchingRule ) {
            [array]$params.Body.userMatchingRules = foreach ($rule in $UserMatchingRule) {
                @{
                    claimName = $rule.ClaimName
                    operator  = $rule.Operator.Replace(' ', '_').ToUpper()
                    value     = $rule.ClaimValue
                }
            }

            if ( $NoOverwrite ) {
                # get existing rules so we can append to the new ones
                if ( -not $allTeams ) {
                    $allTeams = Get-VcTeam -All
                }
                $params.Body.userMatchingRules += $allTeams | Where-Object { $_.name -eq $ID } | Select-Object -ExpandProperty userMatchingRules
            }
        }

        $response = Invoke-VenafiRestMethod @params

        if ( $PassThru ) {
            $response | ConvertTo-VcTeam
        }
    }
}
