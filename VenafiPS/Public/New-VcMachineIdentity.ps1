function New-VcMachineIdentity {
    <#
    .SYNOPSIS
    Create a new machine identity (installation)

    .DESCRIPTION
    Generic function to create machine identities.
    This can be used if you are aware of the keystore and binding requirements or a dedicated function is not available.
    To determine the binding and keystore requirements, create a machine identity in the UI and use Get-VcMachineIdentity to view the details.

    .PARAMETER Machine
    Machine ID or name to be associated.
    If a name is provided and multiple  are found, they will all be associated.

    .PARAMETER Certificate
    Certificate ID or name to be associated.
    If a name is provided and multiple certificates are found, they will all be associated.

    .PARAMETER Application
    One or more application IDs or names.
    Tab completion can be used for a list of application names.

    .PARAMETER NoOverwrite
    Append to existing applications as opposed to overwriting

    .PARAMETER PassThru
    Return the newly updated certificate object(s)

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    Certificate

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Add-VcCertificateAssociation -Certificate '7ac56ec0-2017-11ee-9417-a17dd25b82f9' -Application '96fc9310-67ec-11eb-a8a7-794fe75a8e6f'

    Associate a certificate to an application

    .EXAMPLE
    Add-VcCertificateAssociation -Certificate '7ac56ec0-2017-11ee-9417-a17dd25b82f9' -Application '96fc9310-67ec-11eb-a8a7-794fe75a8e6f', 'a05013bd-921d-440c-bc22-c9ead5c8d548'

    Associate a certificate to multiple applications

    .EXAMPLE
    Find-VcCertificate -First 5 | Add-VcCertificateAssociation -Application 'My Awesome App'

    Associate multiple certificates to 1 application by name

    .EXAMPLE
    Add-VcCertificateAssociation -Certificate 'www.barron.com' -Application '96fc9310-67ec-11eb-a8a7-794fe75a8e6f' -NoOverwrite

    Associate a certificate, by name, to another application, keeping the existing
    #>

    [CmdletBinding()]

    param (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('machineID')]
        [string] $Machine,

        [Parameter(Mandatory)]
        [Alias('certificateID')]
        [string] $Certificate,

        [Parameter()]
        [psobject] $Keystore,

        [Parameter()]
        [psobject] $Binding,

        [Parameter()]
        [switch] $Provision,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [Alias('Key')]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'

        $certId = Get-VcData -InputObject $Certificate -Type 'Certificate'

        $params = @{
            Method  = 'Post'
            UriLeaf = 'machineidentities'
            Body    = @{
                certificateId = $certId
            }
        }

        if ( $Keystore ) {
            $params.Body.keystore = $Keystore
        }

        if ( $Binding ) {
            $params.Body.binding = $Binding
        }
    }

    process {

        $thisMachineId = Get-VcData -InputObject $thisMachine -Type 'Machine'
        $params.Body.machineId = $thisMachineId

        $response = Invoke-VenafiRestMethod @params

        if ( $Provision ) {
            $provisionResponse = Invoke-VcWorkflow -ID $response.id -Workflow 'Provision'
        }

        if ( $PassThru ) {
            $out = $response | Select-Object @{
                'n' = 'machineIdentityId'
                'e' = { $_.id }
            }, * -ExcludeProperty id

            if ( $Provision ) {
                $out | Add-Member @{ 'provisionResponse' = $provisionResponse }
            }

            $out
        }
    }

    end {
    }
}
