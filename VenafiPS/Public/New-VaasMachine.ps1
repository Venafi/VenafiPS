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
    ID or name of a vsatellite

    .PARAMETER Owner

    .PARAMETER Tag

    .PARAMETER Status

    .PARAMETER Hostname
    IP or fqdn of the machine.
    If this is the same value as -Name, this can be ommitted.

    .PARAMETER Credential
    Username/password to access the machine

    .PARAMETER Port
    Optional port.  The default value will depend on the machine type.
    Eg. for Citrix ADC this is 443.

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
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory)]
        [ValidateSet('Citrix ADC', 'F5 BIG-IP LTM')]
        [string] $MachineType,

        [Parameter()]
        [string] $VSatellite,

        [Parameter(Mandatory)]
        [String] $Owner,

        [Parameter()]
        [string[]] $Tag,

        [Parameter()]
        [ValidateSet('DRAFT', 'VERIFIED', 'UNVERIFIED')]
        [string] $Status,

        [Parameter()]
        [string] $Hostname,

        [Parameter(Mandatory)]
        [pscredential] $Credential,

        [Parameter()]
        [string] $Port,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        $params = @{
            VenafiSession = $VenafiSession
            MachineType   = $MachineType
            VSatellite    = $VSatellite
            Owner         = $Owner
            Tag           = $Tag
            Status        = $Status
            Hostname      = $Hostname
            Credential    = $Credential
            Port          = $Port
            PassThru      = $PassThru
        }
    }

    process {

        $params.Name = $Name

        $response = New-VaasMachineBase @params

        if ( $PassThru ) {
            $response
        }
    }
}