<#
.SYNOPSIS
Remove an object from VaaS

.DESCRIPTION
Remove a team, application, machine, machine identity, tag, or connector

.PARAMETER TeamID
Team ID

.PARAMETER ApplicationID
Application ID

.PARAMETER MachineID
Machine ID

.PARAMETER MachineIdentityID
Machine Identity ID

.PARAMETER TagName
Name of the tag to be removed

.PARAMETER ConnectorID
Connector ID

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A VaaS key can also provided.

.INPUTS
TeamID, ApplicationID, MachineID, MachineIdentityID, TagName, ConnectorID

.EXAMPLE
Remove-VaasObject -TeamID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Remove a VaaS team

.EXAMPLE
Get-VenafiTeam -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' | Remove-VaasObject
Remove a VaaS team

.EXAMPLE
Get-VaasConnector | Remove-VaasObject
Remove all connectors

.EXAMPLE
Remove-VaasObject -TeamID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Confirm:$false
Remove a team bypassing the confirmation prompt

#>
function Remove-VaasObject {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'Team', ValueFromPipelineByPropertyName)]
        [string] $TeamID,

        [Parameter(Mandatory, ParameterSetName = 'Application', ValueFromPipelineByPropertyName)]
        [string] $ApplicationID,

        [Parameter(Mandatory, ParameterSetName = 'Machine', ValueFromPipelineByPropertyName)]
        [string] $MachineID,

        [Parameter(Mandatory, ParameterSetName = 'MachineIdentity', ValueFromPipelineByPropertyName)]
        [string] $MachineIdentityID,

        [Parameter(Mandatory, ParameterSetName = 'Tag', ValueFromPipelineByPropertyName)]
        [string] $TagName,

        [Parameter(Mandatory, ParameterSetName = 'Connector', ValueFromPipelineByPropertyName)]
        [string] $ConnectorID,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Delete'
        }
    }

    process {

        switch ($PSCmdlet.ParameterSetName) {
            'Team' {
                $params.UriLeaf = "teams/$TeamID"
            }

            'Application' {
                $params.UriRoot = 'outagedetection/v1'
                $params.UriLeaf = "applications/$ApplicationID"
            }

            'Machine' {
                $params.UriLeaf = "machines/$MachineID"
            }

            'MachineIdentity' {
                $params.UriLeaf = "machineidentities/$MachineIdentityID"
            }

            'Tag' {
                $params.UriLeaf = "tags/$TagName"
            }

            'Connector' {
                $params.UriLeaf = "connectors/$ConnectorID"
            }
        }

        if ( $PSCmdlet.ShouldProcess($params.UriLeaf.Split('/')[-1], "Delete $($PSCmdlet.ParameterSetName)") ) {
            $null = Invoke-VenafiRestMethod @params
        }
    }
}
