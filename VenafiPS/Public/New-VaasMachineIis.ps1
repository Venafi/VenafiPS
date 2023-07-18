function New-VaasMachineIis {
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
    #>

    [CmdletBinding()]

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

        [Parameter()]
        [int] $Port,

        [Parameter()]
        [switch] $UseTls,

        [Parameter()]
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

    $machineTypeId = 'c1521d80-db7a-11ec-b79a-f3ded6c9808c'

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
        $connectionDetails.protocolWinRm.port = $Port
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