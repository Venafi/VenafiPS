function New-VaasMachineCommonKeystore {
    <#
    .SYNOPSIS
    Create a new common keystore machine

    .DESCRIPTION
    Create a new machine

    .PARAMETER Name
    Machine name

    .PARAMETER Owner

    .PARAMETER VSatellite

    .PARAMETER Hostname

    .PARAMETER Credential

    .PARAMETER Port
    Port to connect to the machine

    .PARAMETER Tag

    .PARAMETER Status

    .PARAMETER SshPassword

    .PARAMETER SshKey

    .PARAMETER WinrmBasic

    .PARAMETER WinrmKerberos

    .PARAMETER UseTls

    .PARAMETER SkipCertificateCheck

    .PARAMETER DomainName

    .PARAMETER KeyDistributionCenter

    .PARAMETER SPN

    .PARAMETER PassThru
    Return newly created object

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .OUTPUTS
    PSCustomObject, if PassThru provided

    .EXAMPLE
    New-VaasApplication -Name 'MyNewApp' -Owner '4ba1e64f-12ad-4a34-a0e2-bc4481a56f7d','greg@venafi.com'

    Create a new application

    .EXAMPLE
    New-VaasApplication -Name 'MyNewApp' -Owner '4ba1e64f-12ad-4a34-a0e2-bc4481a56f7d' -CertificateIssuingTemplate @{'9c9618e8-6b4c-4a1c-8c11-902c9b2676d3'=$null} -Description 'this app is awesome' -Fqdn 'me.com' -IPRange '1.2.3.4/24' -Port '443','9443'

    Create a new application with optional details

    .EXAMPLE
    New-VaasApplication -Name 'MyNewApp' -Owner '4ba1e64f-12ad-4a34-a0e2-bc4481a56f7d' -PassThru

    Create a new application and return the newly created application object

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/New-VaasApplication/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-VaasApplication.ps1

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Applications/applications_create

    #>

    [CmdletBinding(DefaultParameterSetName = 'SshPassword')]

    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter()]
        [string] $VSatellite,

        [Parameter(Mandatory)]
        [String] $Owner,

        [Parameter()]
        [string] $Hostname,

        [Parameter(Mandatory)]
        [pscredential] $Credential,

        [Parameter()]
        [string[]] $Tag,

        [Parameter()]
        [ValidateSet('DRAFT', 'VERIFIED', 'UNVERIFIED')]
        [string] $Status,

        [Parameter(ParameterSetName = 'SshPassword', Mandatory)]
        [switch] $SshPassword,

        [Parameter(ParameterSetName = 'SshKey', Mandatory)]
        [switch] $SshKey,

        [Parameter(ParameterSetName = 'WinrmBasic', Mandatory)]
        [switch] $WinrmBasic,

        [Parameter(ParameterSetName = 'WinrmKerberos', Mandatory)]
        [switch] $WinrmKerberos,

        [Parameter()]
        [int] $Port,

        [Parameter(ParameterSetName = 'WinrmBasic')]
        [Parameter(ParameterSetName = 'WinrmKerberos')]
        [switch] $UseTls,

        [Parameter(ParameterSetName = 'WinrmBasic')]
        [Parameter(ParameterSetName = 'WinrmKerberos')]
        [switch] $SkipCertificateCheck,

        [Parameter(ParameterSetName = 'WinrmKerberos', Mandatory)]
        [string] $DomainName,

        [Parameter(ParameterSetName = 'WinrmKerberos', Mandatory)]
        [string] $KeyDistributionCenter,

        [Parameter(ParameterSetName = 'WinrmKerberos', Mandatory)]
        [string] $SPN,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    Write-Verbose $PSCmdlet.ParameterSetName

    Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

    $machineTypeId = '575389b0-e6be-11ec-9172-d3c56ea8bcf6'

    if ( $VSatellite ) {
        $thisVsat = Get-VaasSatellite -ID $VSatellite -IncludeKey
        if ( -not $thisVsat ) {
            throw "$VSatellite is not a valid VSatellite id or name"
        }
    }
    else {
        # choose the first vsat
        $thisVsat = Get-VaasSatellite -All -IncludeKey | Select-Object -First 1
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

    $params = @{
        VenafiSession     = $VenafiSession
        Name              = $Name
        MachineType       = $machineTypeId
        VSatellite        = $thisVsat.vsatelliteId
        DekID             = $thisVsat.encryptionKeyId
        Owner             = $Owner
        PassThru          = $true
        ConnectionDetails = $connectionDetails
    }

    if ( $Port ) {
        if ( $PSCmdlet.ParameterSetName -in 'SshPassword', 'SshKey' ) {
            $connectionDetails.protocolSsh.port = $Port
        }
        else {
            $connectionDetails.protocolWinRm.port = $Port
        }
    }

    if ( $UseTls ) {
        $connectionDetails.protocolWinRm.https = $true
        if ( $SkipCertificateCheck ) {
            $connectionDetails.protocolWinRm.skipTlsVerify = $true
        }
    }

    if ( $Tag ) {
        $params.Tag = $Tag
    }

    if ( $Status ) {
        $params.Status = $Status
    }

    $response = New-VaasMachineBase @params

    if ( $PassThru ) {
        $response
    }
}