function New-VaasMachine {

    <#
    .SYNOPSIS
        Generic function to create machines in VaaS

    .DESCRIPTION
        Base function used to create machines in VaaS.
        It can be used for creating machines for 'simple' machine types, eg. F5 and Citrix, where hostname, credential and optionally port are used.
        It can also be used for machine types which require more details, but these will typically have dedicated functions, eg. New-VaasMachineIis.

    .PARAMETER Name
    Machine name

    .PARAMETER MachineType
    Machine type by either ID or name

    .PARAMETER VSatellite

    .PARAMETER DekID

    .PARAMETER Owner

    .PARAMETER Hostname

    .PARAMETER Credential

    .PARAMETER Port

    .PARAMETER ConnectionDetails

    .PARAMETER Tag

    .PARAMETER Status

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


    [CmdletBinding(DefaultParameterSetName = 'Values')]

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $MachineType,

        [Parameter()]
        [string] $VSatellite,

        [Parameter(ParameterSetName = 'ConnectionDetails')]
        [string] $DekID,

        [Parameter(Mandatory)]
        [String] $Owner,

        [Parameter(ParameterSetName = 'Values')]
        [string] $Hostname,

        [Parameter(ParameterSetName = 'Values', Mandatory)]
        [pscredential] $Credential,

        [Parameter(ParameterSetName = 'Values')]
        [string] $Port,

        [Parameter(ParameterSetName = 'ConnectionDetails')]
        [hashtable] $ConnectionDetails,

        [Parameter()]
        [string[]] $Tag,

        [Parameter()]
        [ValidateSet('DRAFT', 'VERIFIED', 'UNVERIFIED')]
        [string] $Status,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        if ( $VenafiSession.MachineType ) {
            $machineTypes = $VenafiSession.MachineType
        }
        else {
            # session is just key, get machine types and validate value
            $machineTypes = Invoke-VenafiRestMethod -UriLeaf 'machinetypes' -VenafiSession $VenafiSession | Select-Object -ExpandProperty machineTypes
        }
        $thisMachineType = $machineTypes | Where-Object { $_.machineTypeId -eq $MachineType -or $_.machineType -eq $MachineType }
        if ( -not $thisMachineType ) {
            throw "$MachineType is not a valid machine type id or name"
        }

        $thisOwner = Get-VenafiTeam -ID $Owner
        if ( -not $thisOwner ) {
            throw "$Owner is a valid team id or name"
        }

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

        $params = @{
            Method  = 'Post'
            UriLeaf = 'machines'
            Body    = @{
                edgeInstanceId    = $thisVsat.vsatelliteId
                dekId             = $DekID
                machineTypeId     = $thisMachineType.machineTypeId
                pluginId          = $thisMachineType.pluginId
                owningTeamId      = $thisOwner.teamId
                connectionDetails = $ConnectionDetails
            }
        }

        if ( $Tag ) {
            $params.Body.tags = $Tag
        }

        if ( $Status ) {
            $params.Body.status = $Status
        }

        if ( $PSCmdlet.ParameterSetName -eq 'Values' ) {
            $userEnc = ConvertTo-SodiumEncryptedString -text $Credential.UserName -PublicKey $thisVsat.encryptionKey
            $pwEnc = ConvertTo-SodiumEncryptedString -text $Credential.GetNetworkCredential().Password -PublicKey $thisVsat.encryptionKey

            $params.Body.dekId = $thisVsat.encryptionKeyId

            $params.Body.connectionDetails = @{
                username = $userEnc
                password = $pwEnc
            }

            if ( $Port ) {
                $params.Body.connectionDetails.port = $Port
            }
        }

    }

    process {

        $params.Body.name = $Name

        if ( $PSCmdlet.ParameterSetName -eq 'Values' ) {
            $params.Body.connectionDetails.hostnameOrAddress = if ($Hostname) { $Hostname } else { $Name }
        }

        $response = Invoke-VenafiRestMethod @params

        if ( $PassThru ) {
            $response | Select-Object @{
                'n' = 'machineId'
                'e' = {
                    $_.Id
                }
            }, * -ExcludeProperty id
        }
    }
}