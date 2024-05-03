function New-VcMachineIis {
    <#
    .SYNOPSIS
    Create a new IIS machine

    .DESCRIPTION
    Create a new IIS machine with either basic or kerberos authentication.
    By default, the machine details will be verified by performing a test connection; this can be turned off with -NoVerify.
    Creation will occur in parallel and PowerShell v7+ is required.

    .PARAMETER Name
    Machine name

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
    Optional WinRM port.  The default is 5985.

    .PARAMETER UseTls
    Connect over HTTPS as opposed to the default of HTTP

    .PARAMETER SkipCertificateCheck
    If connecting over HTTPS and you wish to bypass certificate validation

    .PARAMETER DomainName
    Machine domain name

    .PARAMETER KeyDistributionCenter
    Address or hostname of the key distribution center

    .PARAMETER SPN
    Service Principal Name, eg. WSMAN/server.company.com

    .PARAMETER Status
    Set the machine status to either 'DRAFT', 'VERIFIED', or 'UNVERIFIED'.
    This optional field has been added for flexibility, but should not be needed under typical usage.
    The platform will handle changing the status to the appropriate value.
    Setting this to a value other than VERIFIED will affect the ability to initiate workflows.

    .PARAMETER NoVerify
    By default a connection to the host will be attempted.
    Use this switch to turn off this behavior.
    Not recommended.

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
        Name = 'iis1'
        Owner = 'MyTeam'
        Hostname = 'iis1.company.com'
        Credential = $cred
        DomainName = 'company.com'
        KeyDistributionCenter = '1.2.3.4'
        SPN = 'WSMAN/iis1.company.com'
    }
    New-VcMachineIis @params

    machineId        : 55e054d0-2b2a-11ee-9546-5136c4b21504
    testConnection   : @{Success=True; Error=; WorkflowID=c39310ee-51fc-49f3-8b5b-e504e1bc43d2}
    companyId        : 20b24f81-b22b-11ea-91f3-ebd6dea5453f
    name             : iis1
    machineType      : Microsoft IIS
    pluginId         : be453281-d080-11ec-a07a-6d5bc1b54078
    integrationId    : 55df8877-2b2a-11ee-9264-9e16d4b8a8c9
    edgeInstanceId   : 0bc771e1-7abe-4339-9fcd-93fffe9cba7f
    creationDate     : 7/25/2023 4:32:12 PM
    modificationDate : 7/25/2023 4:32:12 PM
    status           : UNVERIFIED
    owningTeamId     : 59920180-a3e2-11ec-8dcd-3fcbf84c7da7

    Create a new machine with Kerberos authentication

    .NOTES
    This function requires the use of sodium encryption.
    .net standard 2.0 or greater is required via PS Core (recommended) or supporting .net runtime.
    On Windows, the latest Visual C++ redist must be installed.  See https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist.
    #>

    [CmdletBinding(DefaultParameterSetName = 'WinrmBasic')]
    [Alias('New-VaasMachineIis')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'IIS is not plural')]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $VSatellite,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [String] $Owner,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Hostname,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [pscredential] $Credential,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]] $Tag,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('DRAFT', 'VERIFIED', 'UNVERIFIED')]
        [string] $Status,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int] $Port,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch] $UseTls,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch] $SkipCertificateCheck,

        [Parameter(ParameterSetName = 'WinrmKerberos', Mandatory, ValueFromPipelineByPropertyName)]
        [string] $DomainName,

        [Parameter(ParameterSetName = 'WinrmKerberos', Mandatory, ValueFromPipelineByPropertyName)]
        [string] $KeyDistributionCenter,

        [Parameter(ParameterSetName = 'WinrmKerberos', Mandatory, ValueFromPipelineByPropertyName)]
        [string] $SPN,

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

        $allMachines = [System.Collections.Generic.List[pscustomobject]]::new()
        $machineTypeId = 'c1521d80-db7a-11ec-b79a-f3ded6c9808c'

        Initialize-PSSodium
    }

    process {

        # need vsat to get dek for encrypting username/password
        if ( $VSatellite ) {
            $vSat = Get-VcData -InputObject $VSatellite -Type 'VSatellite' -Object
            if ( -not $vSat ) {
                throw "'$VSatellite' is either not a valid VSatellite id or name or it is not active"
            }
        }
        else {
            $vSat = Get-VcData -Type 'VSatellite' -First
            if ( -not $vSat ) {
                throw "An active VSatellite could not be found"
            }
        }

        $userEnc = ConvertTo-SodiumEncryptedString -text $Credential.UserName -PublicKey $vSat.encryptionKey
        $pwEnc = ConvertTo-SodiumEncryptedString -text $Credential.GetNetworkCredential().Password -PublicKey $vSat.encryptionKey

        switch ($PSCmdlet.ParameterSetName) {
            'WinrmBasic' {
                $connectionDetails = @{
                    hostnameOrAddress  = if ($Hostname) { $Hostname } else { $Name }
                    authenticationType = "basic"
                    credentialType     = 'local'
                    username           = $userEnc
                    password           = $pwEnc
                }
            }

            'WinrmKerberos' {
                $connectionDetails = @{
                    hostnameOrAddress  = if ($Hostname) { $Hostname } else { $Name }
                    authenticationType = 'kerberos'
                    credentialType     = 'local'
                    username           = $userEnc
                    password           = $pwEnc
                    kerberos           = @{
                        domain                = "$DomainName"
                        keyDistributionCenter = "$KeyDistributionCenter"
                        servicePrincipalName  = "$SPN"
                    }
                }
            }
        }

        if ( $Port ) {
            $connectionDetails.protocolWinRm.port = $Port
        }

        if ( $UseTls ) {
            $connectionDetails.protocolWinRm.https = $true
            if ( $SkipCertificateCheck ) {
                $connectionDetails.protocolWinRm.skipTlsVerify = $true
            }
        }

        $params = @{
            Name             = $Name
            MachineType      = $machineTypeId
            VSatellite       = $vSat.vsatelliteId
            DekID            = $vSat.encryptionKeyId
            Owner            = $Owner
            ConnectionDetail = $connectionDetails
        }

        if ( $Tag ) {
            $params.Tag = $Tag
        }

        if ( $Status ) {
            $params.Status = $Status
        }

        $allMachines.Add( [pscustomobject]$params )
    }

    end {

        $newParams = @{

            NoVerify      = $NoVerify
            ThrottleLimit = $ThrottleLimit
            PassThru      = $true
        }

        $response = $allMachines | New-VcMachine @newParams

        if ( $PassThru ) {
            $response
        }
    }
}
