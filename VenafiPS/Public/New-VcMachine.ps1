function New-VcMachine {

    <#
    .SYNOPSIS
    Create 1 or more machines

    .DESCRIPTION
    This creation function is to be used for 'simple' machine types, eg. F5 and Citrix, where hostname, credential and optionally port are used.
    Machine creation for types with additional functionality will have dedicated functions, eg. New-VcMachineIis.
    By default, the machine details will be verified by performing a test connection; this can be turned off with -NoVerify.
    Creation will occur in parallel and PowerShell v7+ is required.

    .PARAMETER Name
    Machine name

    .PARAMETER MachineType
    Machine type by either ID or name, eg. 'Citrix ADC'.
    A list can be found by create a new session and executing $VenafiSession.MachineType.

    .PARAMETER VSatellite
    ID or name of a vsatellite.
    If not provided, the first vsatellite found will be used.

    .PARAMETER Owner
    ID or name of a team to be the owner of the machine

    .PARAMETER Tag
    Optional list of tags to assign

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

    .PARAMETER Status
    Set the machine status to either 'DRAFT', 'VERIFIED', or 'UNVERIFIED'.
    This optional field has been added for flexibility, but should not be needed under typical usage.
    The platform will handle changing the status to the appropriate value.
    Setting this to a value other than VERIFIED will affect the ability to initiate workflows.

    .PARAMETER ThrottleLimit
    Limit the number of threads when running in parallel; the default is 100.  Applicable to PS v7+ only.

    .PARAMETER PassThru
    Return newly created object

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .EXAMPLE
    $params = @{
        Name = 'c1'
        MachineType = 'Citrix ADC'
        Owner = 'MyTeam'
        Hostname = 'c1.company.com'
        Credential = $cred
    }
    New-VcMachine @params

    machineId        : cf7cfdc0-2b2a-11ee-9546-5136c4b21504
    testConnection   : @{Success=True; Error=; WorkflowID=c39310ee-51fc-49f3-8b5b-e504e1bc43d2}
    companyId        : 20b24f81-b22b-11ea-91f3-ebd6dea5453f
    name             : c1
    machineType      : Citrix ADC
    pluginId         : ff645e14-bd1a-11ed-a009-ce063932f86d
    integrationId    : cf7c8014-2b2a-11ee-9a03-fa8930555887
    edgeInstanceId   : 0bc771e1-7abe-4339-9fcd-93fffe9cba7f
    creationDate     : 7/25/2023 4:35:36 PM
    modificationDate : 7/25/2023 4:35:36 PM
    status           : UNVERIFIED
    owningTeamId     : 59920180-a3e2-11ec-8dcd-3fcbf84c7da7

    Create a new Citrix machine

    .EXAMPLE
    [pscustomobject] @{
        Name = 'c1.company.com'
        MachineType = 'Citrix ADC'
        Owner = 'MyTeam'
        Credential = $cred
    } | New-VcMachine

    Use pipeline data to create a machine.
    More than 1 machine can be sent thru the pipeline and they will be created in parallel.
    You could also import a csv and pipe it to this function as well.

    .NOTES
    To see a full list of tab-completion options, be sure to set the Tab option, Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete.

    This function requires the use of sodium encryption.
    .net standard 2.0 or greater is required via PS Core (recommended) or supporting .net runtime.
    On Windows, the latest Visual C++ redist must be installed.  See https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist.
    #>


    [CmdletBinding()]
    [Alias('New-VaasMachine')]

    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
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
        [int32] $ThrottleLimit = 100,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'

        Initialize-PSSodium

        $allMachines = [System.Collections.Generic.List[hashtable]]::new()

        if ( $Credential ) {
            if ( $MachineType -in 'c1521d80-db7a-11ec-b79a-f3ded6c9808c', 'Microsoft IIS' ) { throw 'To create IIS machines, please use New-VcMachineIis' }
            if ( $MachineType -in '575389b0-e6be-11ec-9172-d3c56ea8bcf6', 'Common Keystore (PEM, JKS, PKCS#12)' ) { throw 'To create Common Keystore machines, please use New-VcMachineCommonKeystore' }
        }
    }

    process {

        Write-Verbose $PSCmdlet.ParameterSetName

        $thisMachineType = Get-VcData -InputObject $MachineType -Type 'MachineType' -Object
        if ( -not $thisMachineType ) {
            Write-Error "'$MachineType' is not a valid machine type id or name"
            return
        }

        $ownerId = Get-VcData -InputObject $Owner -Type 'Team'
        if ( -not $ownerId ) {
            Write-Error "'$Owner' is not a valid team id or name"
            return
        }

        if ( $PSCmdlet.ParameterSetName -eq 'AdvancedMachine' ) {
            $thisEdgeInstanceId = $VSatellite
            $thisDekId = $DekID
            $thisConnectionDetail = $ConnectionDetail
        }
        else {

            if ( $VSatellite ) {
                $vSat = Get-VcData -InputObject $VSatellite -Type 'VSatellite' -Object
                if ( -not $vSat ) {
                    Write-Error "'$VSatellite' is either not a valid VSatellite id or name or it is not active."
                    return
                }
            }
            else {
                $vSat = Get-VcData -Type 'VSatellite' -First
                if ( -not $vSat ) {
                    Write-Error "An active VSatellite could not be found"
                    return
                }
            }

            $thisEdgeInstanceId = $vSat.vsatelliteId
            $thisDekId = $vSat.encryptionKeyId

            $userEnc = ConvertTo-SodiumEncryptedString -text $Credential.UserName -PublicKey $vSat.encryptionKey
            $pwEnc = ConvertTo-SodiumEncryptedString -text $Credential.GetNetworkCredential().Password -PublicKey $vSat.encryptionKey

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
            owningTeamId      = $ownerId
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
                $workflowResponse = Invoke-VcWorkflow -ID $response.id -Workflow 'Test'
                $response | Select-Object @{
                    'n' = 'machineId'
                    'e' = { $_.id }
                },
                @{
                    'n' = 'testConnection'
                    'e' = { $workflowResponse | Select-Object Success, Error, WorkflowID }
                }, * -ExcludeProperty id
            }
        } -ThrottleLimit $ThrottleLimit -VenafiSession $VenafiSession

        if ( $PassThru ) {
            $response
        }
    }
}