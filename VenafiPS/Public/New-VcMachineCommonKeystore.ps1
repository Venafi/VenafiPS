function New-VcMachineCommonKeystore {
    <#
    .SYNOPSIS
    Create a new common keystore machine

    .DESCRIPTION
    Create a new common keystore, PEM/JKS/PKCS#12, machine.
    SSH and WinRM are both supported in addition to different authentication types.
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

    .PARAMETER Status
    Set the machine status to either 'DRAFT', 'VERIFIED', or 'UNVERIFIED'.
    This optional field has been added for flexibility, but should not be needed under typical usage.
    The platform will handle changing the status to the appropriate value.
    Setting this to a value other than VERIFIED will affect the ability to initiate workflows.

    .PARAMETER SshPassword
    Connect to the target machine over SSH with username and password

    .PARAMETER SshKey
    Connect to the target machine over SSH with username and private key

    .PARAMETER WinrmBasic
    Connect to the target machine over WinRM with Basic authentication

    .PARAMETER WinrmKerberos
    Connect to the target machine over WinRM with Kerberos authentication

    .PARAMETER Hostname
    IP or fqdn of the machine.
    If this is to be the same value as -Name, this parameter can be ommitted.

    .PARAMETER Credential
    Username/password to access the machine.
    If using key-based authentication over SSH, set the password to the private key.

    .PARAMETER Port
    Optional SSH/WinRM port.
    The default for SSH is 22 and WinRM is 5985.

    .PARAMETER UseTls
    Connect with WinRM over HTTPS as opposed to the default of HTTP

    .PARAMETER SkipCertificateCheck
    If connecting with WinRM over HTTPS and you wish to bypass certificate validation

    .PARAMETER DomainName
    Machine domain name for WinRM

    .PARAMETER KeyDistributionCenter
    Address or hostname of the key distribution center for WinRM

    .PARAMETER SPN
    Service Principal Name, eg. WSMAN/server.company.com, for WinRM

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

    .OUTPUTS
    PSCustomObject, if PassThru provided

    .EXAMPLE
    New-VcMachineCommonKeystore -Name 'ck1' -Owner 'MyTeam' -Hostname 'ck1.company.com' -Credential $cred -SshPassword

    machineId        : a9b60a70-2b28-11ee-b5b5-4b044579acad
    testConnection   : @{Success=True; Error=; WorkflowID=c14e181b-82ea-423a-b0fd-c3fe9b218a64}
    companyId        : 20b24f81-b22b-11ea-91f3-ebd6dea5453f
    name             : ck1
    machineType      : Common KeyStore (PEM, JKS, PKCS#12)
    pluginId         : 0e565e41-dd31-11ec-841d-a7d91c5a907c
    integrationId    : a9b5b842-2b28-11ee-9263-9e16d4b8a8c9
    edgeInstanceId   : 0bc771e1-7abe-4339-9fcd-93fffe9cba7f
    creationDate     : 7/25/2023 4:20:14 PM
    modificationDate : 7/25/2023 4:20:14 PM
    status           : UNVERIFIED
    owningTeamId     : 59920180-a3e2-11ec-8dcd-3fcbf84c7da7

    Create a new machine with SSH password authentication
    #>

    [CmdletBinding(DefaultParameterSetName = 'SshPassword')]
    [Alias('New-VaasMachineCommonKeystore')]

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

        [Parameter(ParameterSetName = 'SshPassword', Mandatory, ValueFromPipelineByPropertyName)]
        [switch] $SshPassword,

        [Parameter(ParameterSetName = 'SshKey', Mandatory, ValueFromPipelineByPropertyName)]
        [switch] $SshKey,

        [Parameter(ParameterSetName = 'WinrmBasic', Mandatory, ValueFromPipelineByPropertyName)]
        [switch] $WinrmBasic,

        [Parameter(ParameterSetName = 'WinrmKerberos', Mandatory, ValueFromPipelineByPropertyName)]
        [switch] $WinrmKerberos,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int] $Port,

        [Parameter(ParameterSetName = 'WinrmBasic', ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'WinrmKerberos', ValueFromPipelineByPropertyName)]
        [switch] $UseTls,

        [Parameter(ParameterSetName = 'WinrmBasic', ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'WinrmKerberos', ValueFromPipelineByPropertyName)]
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
        $machineTypeId = '575389b0-e6be-11ec-9172-d3c56ea8bcf6'

    }

    process {

        # need vsat to get dek for encrypting username/password
        if ( -not $allVsat ) {
            $allVsat = Get-VcSatellite -All -IncludeKey
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

        $userEnc = ConvertTo-SodiumEncryptedString -text $Credential.UserName -PublicKey $thisVsat.encryptionKey
        $pwEnc = ConvertTo-SodiumEncryptedString -text $Credential.GetNetworkCredential().Password -PublicKey $thisVsat.encryptionKey

        switch ($PSCmdlet.ParameterSetName) {
            'SshPassword' {
                $connectionDetails = @{
                    protocol    = 'ssh2'
                    protocolSsh = @{
                        hostnameOrAddress = if ($Hostname) { $Hostname } else { $Name }
                        sshAuthentication = 'password'
                        sshPassword       = @{
                            credentialType = 'local'
                            username       = $userEnc
                            password       = $pwEnc
                        }
                    }
                }
            }

            'SshKey' {
                $connectionDetails = @{
                    protocol    = 'ssh2'
                    protocolSsh = @{
                        hostnameOrAddress = if ($Hostname) { $Hostname } else { $Name }
                        sshAuthentication = "key"
                        sshPrivateKey     = @{
                            credentialType = 'local'
                            username       = $userEnc
                            privateKey     = $pwEnc
                        }
                    }
                }
            }

            'WinrmBasic' {
                $connectionDetails = @{
                    protocol      = 'winrm2'
                    protocolWinRm = @{
                        hostnameOrAddress  = if ($Hostname) { $Hostname } else { $Name }
                        authenticationType = "basic"
                        credentialType     = 'local'
                        username           = $userEnc
                        password           = $pwEnc
                    }
                }
            }

            'WinrmKerberos' {
                $connectionDetails = @{
                    protocol      = 'winrm2'
                    protocolWinRm = @{
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
            VSatellite       = $thisVsat.vsatelliteId
            DekID            = $thisVsat.encryptionKeyId
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
