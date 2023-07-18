function Get-VaasMachine {
    <#
    .SYNOPSIS
    Get machine info

    .DESCRIPTION
    Get info for either a specific machine or all.

    .PARAMETER ID
    Name or uuid to get info for a specific machine

    .PARAMETER All
    Get all machines

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .INPUTS
    ID

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-VaasMachine -ID 'c1'

    companyId         : 09b24f81-b22b-11ea-91f3-ebd6dea5452e
    name              : c1
    machineType       : Citrix ADC
    pluginId          : ff645e14-bd1a-11ed-a009-ce063932f86d
    integrationId     : d68a571d-24df-11ee-a0ae-f24d11bc4208
    edgeInstanceId    : 79fe96d0-0b93-11ee-8894-cb74b07067e5
    creationDate      : 7/17/2023 4:23:49 PM
    modificationDate  : 7/17/2023 4:32:48 PM
    status            : VERIFIED
    owningTeamId      : 59920180-a3e2-11ec-8dcd-3fcbf84c7da7
    connectionDetails : @{credentialType=local; hostnameOrAddress=1.2.3.4; password=RpSYhMjqxRr1QPROGqH4bKa1b3AQoik=;
                        username=7sEvTe9CAEmXB/tKwF3NLCMFFWCv3+}
    machineId         : d68c7420-24df-11ee-9c2f-49251618e0a7

    Get info for a specific machine by name

    .EXAMPLE
    Get-VaasMachine -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'

    Get info for a specific machine by ID

    .EXAMPLE
    Get-VaasMachine -All

    companyId        : 09b24f81-b22b-11ea-91f3-ebd6dea5452e
    name             : c1
    machineType      : Citrix ADC
    pluginId         : ff645e14-bd1a-11ed-a009-ce063932f86d
    integrationId    : d68a571d-24df-11ee-a0ae-f24d11bc4208
    edgeInstanceId   : 79fe96d0-0b93-11ee-8894-cb74b07067e5
    creationDate     : 7/17/2023 4:23:49 PM
    modificationDate : 7/17/2023 4:32:48 PM
    status           : VERIFIED
    owningTeamId     : 59920180-a3e2-11ec-8dcd-3fcbf84c7da7
    machineId        : d68c7420-24df-11ee-9c2f-49251618e0a7

    Get info for all machines.  -All does not retrieve connectionDetails.
    To get all machines including connectionDetails, pipe the output back into Get-VaasMachine.
    Eg. Get-VaasMachine -All | Get-VaasMachine.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ID')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ID', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('machineId')]
        [string] $ID,

        [Parameter(ParameterSetName = 'All', Mandatory)]
        [switch] $All,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Get'
        }
    }

    process {

        if ( $PSCmdlet.ParameterSetName -eq 'All' ) {
            $params.UriLeaf = 'machines'
            $response = Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty machines
        }
        else {
            if ( [guid]::TryParse($ID, $([ref][guid]::Empty)) ) {
                $guid = [guid] $ID
                $params.UriLeaf = 'machines/{0}' -f $guid.ToString()
                $response = Invoke-VenafiRestMethod @params
            }
            else {
                # machine name
                return Find-VaasObject -Type 'Machine' -Filter @('machineName', 'eq', $ID) -VenafiSession $VenafiSession | Get-VaasMachine -VenafiSession $VenafiSession
            }
        }

        if ( -not $response ) {
            continue
        }

        $response | Select-Object *,
        @{
            'n' = 'machineId'
            'e' = {
                $_.Id
            }
        } -ExcludeProperty Id
    }
}
