function Set-VaasTeam {
    <#
    .SYNOPSIS
    Update an existing team

    .DESCRIPTION
    Update name, role, and/or user matching rules for existing teams.

    .PARAMETER ID
    Team ID.  Provide this or -Name.

    .PARAMETER Name
    Team name.  This should be the complete name of the team.
    Provide this or -ID.

    .PARAMETER NewName
    Provide a new name for the team if you wish to change it.

    .PARAMETER NewRole
    Provide a new role for the team if you wish to change it.
    Accepted values are 'System Admin', 'PKI Admin', 'Resource Owner', or 'Guest'

    .PARAMETER NewUserMatchingRule
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
    A VaaS key can also provided.

    .INPUTS
    ID, Name

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Set-VaasTeam -Name 'MyTeam' -NewName 'ThisTeamIsBetter'

    Rename an existing team

    .EXAMPLE
    Set-VaasTeam -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Role 'PKI Admin'

    Change the role for an existing team

    .EXAMPLE
    Set-VaasTeam -Name 'MyTeam' -NewUserMatchingRule @{'ClaimName'='MyClaim';'Operator'='equals';'ClaimValue'='matchme'}

    Replace a teams user matching rules

    .EXAMPLE
    Set-VaasTeam -Name 'MyTeam' -NewUserMatchingRule @{'ClaimName'='MyClaim';'Operator'='equals';'ClaimValue'='matchme'} -NoOverwrite

    Update a teams user matching rules, appending instead of overwriting

    .EXAMPLE
    Set-VaasTeam -Name 'MyTeam' -NewName 'ThisTeamIsBetter' -PassThru

    Rename an existing team and return the updated team object

    .EXAMPLE
    Get-VenafiTeam -All | Where-Object {$_.name -like '*shouldnt be sysadmin*'} | Set-VaasTeam -NewRole 'PKI Admin'

    Update many teams
    #>

    [CmdletBinding()]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipelineByPropertyName)]
        [Alias('teamId')]
        [string] $ID,

        [Parameter(Mandatory, ParameterSetName = 'Name', ValueFromPipeline)]
        [string] $Name,

        [Parameter()]
        [string] $NewName,

        [Parameter()]
        [ValidateSet('System Admin', 'PKI Admin', 'Resource Owner', 'Guest')]
        [string] $NewRole,

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
        [hashtable[]] $NewUserMatchingRule,

        [Parameter()]
        [switch] $NoOverwrite,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [Alias('Key')]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Patch'
            Body          = @{}
        }
    }

    process {

        $thisID = $ID
        if ( $PSCmdlet.ParameterSetName -eq 'Name' ) {
            $matchingTeams = Get-VenafiTeam -All | Where-Object { $_.name -eq $Name }
            switch ($matchingTeams.count) {
                0 {
                    Write-Error "$Name team name not found"
                    Continue
                }

                1 {
                    $thisID = $matchingTeams.teamId
                }

                Default {
                    Write-Error "Multiple teams named $Name found.  Provide -ID instead of -Name."
                    Continue
                }
            }
        }

        $params.UriLeaf = "teams/$thisID"

        if ( $NewName ) {
            $params.Body.name = $NewName
        }

        if ( $NewRole ) {
            $params.Body.role = $NewRole.Replace(' ', '_').ToUpper()
        }

        if ( $NewUserMatchingRule ) {
            [array]$params.Body.userMatchingRules = foreach ($rule in $NewUserMatchingRule) {
                @{
                    claimName = $rule.ClaimName
                    operator  = $rule.Operator.Replace(' ', '_').ToUpper()
                    value     = $rule.ClaimValue
                }
            }
            if ( $NoOverwrite ) {
                # get existing rules so we can append to the new ones
                $existingTeam = Get-VenafiTeam -ID $thisID -VenafiSession $VenafiSession
                $params.Body.userMatchingRules += $existingTeam.userMatchingRules
            }
        }

        $response = Invoke-VenafiRestMethod @params

        if ( $PassThru ) {
            $response | ConvertTo-VaasTeam
        }
    }
}
