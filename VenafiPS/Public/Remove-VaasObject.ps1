function Remove-VaasObject {
    <#
    .SYNOPSIS
    Remove an object from VaaS

    .DESCRIPTION
    Remove a certificate, team, application, machine, machine identity, tag, connector or issuing template.
    Use PowerShell v7+ to speed up the process.

    .PARAMETER CertificateID
    Certificate ID of a certificate that has been retired

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

    .PARAMETER IssuingTemplateID
    Issuing template ID

    .PARAMETER ThrottleLimit
    Control the number of parallel threads.  Default is 20.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .INPUTS
    CertificateID, TeamID, ApplicationID, MachineID, MachineIdentityID, TagName, ConnectorID, IssuingTemplateID

    .EXAMPLE
    Remove-VaasObject -TeamID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'

    Remove a single object by ID

    .EXAMPLE
    Find-VaasObject -Type Machine -Filter @('machineName','find','BadMachine') | Remove-VaasObject

    Remove multiple objects based on a search

    .EXAMPLE
    Get-VaasConnector -All | Remove-VaasObject

    Remove all connectors

    .EXAMPLE
    Remove-VaasObject -TeamID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Confirm:$false

    Remove an object bypassing the confirmation prompt

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'Certificate', ValueFromPipelineByPropertyName)]
        [string] $CertificateID,

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

        [Parameter(Mandatory, ParameterSetName = 'IssuingTemplate', ValueFromPipelineByPropertyName)]
        [string] $IssuingTemplateID,

        [Parameter()]
        [int] $ThrottleLimit = 20,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Delete'
        }

        $allObjects = [System.Collections.Generic.List[object]]::new()
        $allCerts = [System.Collections.Generic.List[object]]::new()
    }

    process {

        $thisObject = switch ($PSCmdlet.ParameterSetName) {

            'Team' {
                @{
                    UriLeaf = "teams/$TeamID"
                }
            }

            'Application' {
                @{
                    UriRoot = 'outagedetection/v1'
                    UriLeaf = "applications/$ApplicationID"
                }
            }

            'Machine' {
                @{
                    UriLeaf = "machines/$MachineID"
                }
            }

            'MachineIdentity' {
                @{
                    UriLeaf = "machineidentities/$MachineIdentityID"
                }
            }

            'Tag' {
                @{
                    UriLeaf = "tags/$TagName"
                }
            }

            'Connector' {
                @{
                    UriLeaf = "connectors/$ConnectorID"
                }
            }

            'IssuingTemplate' {
                @{
                    UriLeaf = "certificateissuingtemplates/$IssuingTemplateID"
                }
            }
        }

        if ( $PSCmdlet.ParameterSetName -eq 'Certificate' ) {
            if ( $PSCmdlet.ShouldProcess($CertificateID, "Delete Certificate") ) {
                $allCerts.Add($CertificateID)
            }
        }
        else {
            if ( $PSCmdlet.ShouldProcess($thisObject.UriLeaf.Split('/')[-1], "Delete $($PSCmdlet.ParameterSetName)") ) {
                $allObjects.Add($thisObject)
            }
        }
    }

    end {

        # handle certs differently since you send them all in 1 call
        # and parallel functionality not needed
        if ( $allCerts ) {
            $params = @{
                Method  = 'Post'
                UriRoot = 'outagedetection/v1'
                UriLeaf = 'certificates/deletion'
                Body    = @{
                    certificateIds = $allCerts
                }
            }
            $null = Invoke-VenafiRestMethod @params
        }
        else {
            Invoke-VenafiParallel -InputObject $allObjects -ScriptBlock {
                $null = Invoke-VenafiRestMethod -Method 'Delete' @PSItem
            } -ThrottleLimit $ThrottleLimit -VenafiSession $VenafiSession
        }

    }
}
