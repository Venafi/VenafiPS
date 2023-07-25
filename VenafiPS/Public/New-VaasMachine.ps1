function New-VaasMachine {

    <#
    .SYNOPSIS
    Create machines

    .DESCRIPTION
    Create machines in VaaS with a limited set of parameters.
    This creation function is to be used for 'simple' machine types, eg. F5 and Citrix, where hostname, credential and optionally port are used.
    Machine creation for types with additional functionality will have dedicated functions, , eg. New-VaasMachineIis.
    By default, the machine details will be verified by performing a test connection; this can be turned off with -NoVerify.
    PowerShell v7+ is required.

    .PARAMETER Name
    Machine name

    .PARAMETER MachineType
    Machine type by either ID or name, eg. 'Citrix ADC'

    .PARAMETER VSatellite
    ID or name of a vsatellite

    .PARAMETER Owner
    ID or name of a team to be the owner of the machine

    .PARAMETER Tag
    Optional list of tags to assign

    .PARAMETER Status
    Set the machine status to either 'DRAFT', 'VERIFIED', or 'UNVERIFIED'.
    This optional field has been added for flexibility, but should not be needed under typical usage.
    The platform will handle changing the status to the appropriate value.
    Setting this to a value other than VERIFIED will affect the ability to initiate workflows.

    .PARAMETER Hostname
    IP or fqdn of the machine.
    If this is to be the same value as -Name, this parameter can be ommitted.

    .PARAMETER Credential
    Username/password to access the machine

    .PARAMETER Port
    Optional port.  The default value will depend on the machine type.
    Eg. for Citrix ADC this is 443.

    .PARAMETER ConnectionDetail
    Full connection detail object to create a machine.
    This is typically for use with other machine creation functions, but here for flexibility.

    .PARAMETER DekID
    ID of the data encryption key

    .PARAMETER NoVerify
    By default a connection to the host will be attempted.
    Use this switch to turn off this behavior.
    Not recommended.

    .PARAMETER ThrottleLimit
     Max number of threads at once

    .PARAMETER PassThru
    Return newly created object

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>


    [CmdletBinding()]

    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript(
            {
                if ( $_ -in 'c1521d80-db7a-11ec-b79a-f3ded6c9808c', 'Microsoft IIS' ) { throw 'To create IIS machines, please use New-VaasMachineIis' }
                if ( $_ -in '575389b0-e6be-11ec-9172-d3c56ea8bcf6', 'Common Keystore (PEM, JKS, PKCS#12)' ) { throw 'To create Common Keystore machines, please use New-VaasMachineCommonKeystore' }
                $true
            }
        )]
        [string] $MachineType,

        [Parameter(ParameterSetName = 'BasicMachine', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'AdvancedMachine', ValueFromPipelineByPropertyName)]
        [string] $VSatellite,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [String] $Owner,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]] $Tag,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('DRAFT', 'VERIFIED', 'UNVERIFIED')]
        [string] $Status,

        [Parameter(ParameterSetName = 'BasicMachine', ValueFromPipelineByPropertyName)]
        [string] $Hostname,

        [Parameter(Mandatory, ParameterSetName = 'BasicMachine', ValueFromPipelineByPropertyName)]
        [pscredential] $Credential,

        [Parameter(ParameterSetName = 'BasicMachine', ValueFromPipelineByPropertyName)]
        [string] $Port,

        [Parameter(Mandatory, ParameterSetName = 'AdvancedMachine', ValueFromPipelineByPropertyName)]
        [hashtable] $ConnectionDetail,

        [Parameter(Mandatory, ParameterSetName = 'AdvancedMachine', ValueFromPipelineByPropertyName)]
        [string] $DekID,

        [Parameter()]
        [switch] $NoVerify,

        [Parameter()]
        [int] $ThrottleLimit = 20,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        $allMachines = [System.Collections.Generic.List[hashtable]]::new()

        $allTeam = Get-VenafiTeam -All -VenafiSession $VenafiSession
        if ( $VenafiSession.MachineType ) {
            $machineTypes = $VenafiSession.MachineType
        }
        else {
            # session is just key, get machine types
            $machineTypes = Invoke-VenafiRestMethod -UriLeaf 'machinetypes' -VenafiSession $VenafiSession | Select-Object -ExpandProperty machineTypes
        }
    }

    process {

        Write-Verbose $PSCmdlet.ParameterSetName

        $thisMachineType = $machineTypes | Where-Object { $_.machineTypeId -eq $MachineType -or $_.machineType -eq $MachineType }
        if ( -not $thisMachineType ) {
            throw "$MachineType is not a valid machine type id or name"
        }

        $thisOwner = $allTeam | Where-Object { $Owner -eq $_.teamId -or $Owner -eq $_.name }
        if ( -not $thisOwner ) {
            throw "$Owner is not a valid team id or name"
        }

        if ( $PSCmdlet.ParameterSetName -eq 'AdvancedMachine' ) {
            $thisEdgeInstanceId = $VSatellite
            $thisDekId = $DekID
            $thisConnectionDetail = $ConnectionDetail
        }
        else {
            if ( -not $allVsat ) {
                $allVsat = Get-VaasSatellite -All -IncludeKey -VenafiSession $VenafiSession
            }
            if ( $VSatellite ) {
                $thisVsat = $allVsat | Where-Object { $VSatellite -eq $_.vsatelliteId -or $VSatellite -eq $_.name }
                if ( -not $thisVsat ) {
                    throw "$VSatellite is not a valid VSatellite id or name"
                }
            }
            else {
                # choose the first vsat
                $thisVsat = $allVsat | Select-Object -First 1
            }

            $thisEdgeInstanceId = $thisVsat.vsatelliteId
            $thisDekId = $thisVsat.encryptionKeyId

            $userEnc = ConvertTo-SodiumEncryptedString -text $Credential.UserName -PublicKey $thisVsat.encryptionKey
            $pwEnc = ConvertTo-SodiumEncryptedString -text $Credential.GetNetworkCredential().Password -PublicKey $thisVsat.encryptionKey

            $thisConnectionDetail = @{
                hostnameOrAddress = if ($Hostname) { $Hostname } else { $Name }
                username          = $userEnc
                password          = $pwEnc
            }

            if ( $Port ) {
                $thisConnectionDetail.port = $Port
            }
        }

        $bodyParams = @{
            name              = $Name
            edgeInstanceId    = $thisEdgeInstanceId
            dekId             = $thisDekId
            machineTypeId     = $thisMachineType.machineTypeId
            pluginId          = $thisMachineType.pluginId
            owningTeamId      = $thisOwner.teamId
            connectionDetails = $thisConnectionDetail
        }

        if ( $Tag ) {
            $bodyParams.tags = $Tag
        }

        if ( $Status ) {
            $bodyParams.status = $Status
        }

        $allMachines.Add( $bodyParams )
    }

    end {

        $response = Invoke-VenafiParallel -InputObject $allMachines -ScriptBlock {
            $response = Invoke-VenafiRestMethod -Method 'Post' -UriLeaf 'machines' -Body $PSItem

            if ( $using:NoVerify ) {
                $response | Select-Object @{
                    'n' = 'machineId'
                    'e' = { $_.id }
                }, * -ExcludeProperty id
            }
            else {
                $workflowResponse = Invoke-VaasWorkflow -ID $response.id -Workflow 'Test'
                $response | Select-Object @{
                    'n' = 'machineId'
                    'e' = { $_.id }
                },
                @{
                    'n' = 'testConnection'
                    'e' = { $workflowResponse | Select-Object Success, Error, WorkflowID }
                }, * -ExcludeProperty id
            }
        } -VenafiSession $VenafiSession

        if ( $PassThru ) {
            $response
        }
    }
}