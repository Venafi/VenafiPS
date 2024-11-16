function Set-VcMachineIdentity {
    <#
    .SYNOPSIS
    Update machine identity details

    .DESCRIPTION
    Update a machine identity's certificate, status, keystore, or binding

    .PARAMETER MachineIdentity
    Machine identity GUID to be updated

    .PARAMETER Certificate
    Certificate GUID to replace the existing certificate associated with the machine identity

    .PARAMETER Status
    Set the current status, defaults to NEW

    .PARAMETER Keystore
    Update the keystore

    .PARAMETER Binding
    Update the binding

    .PARAMETER Provision
    Trigger the provisioning workflow after the update is complete

    .PARAMETER PassThru
    Return the newly updated machine identity object

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    MachineIdentity

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Set-VcMachineIdentity -MachineIdentity 'f4cb1e86-ea80-4974-b966-86e853e1e5c2' -Certificate '7ac56ec0-2017-11ee-9417-a17dd25b82f9'

    Associate a new certificate to a machine identity

    .EXAMPLE
    Set-VcMachineIdentity -MachineIdentity 'f4cb1e86-ea80-4974-b966-86e853e1e5c2' -Certificate '7ac56ec0-2017-11ee-9417-a17dd25b82f9' -Provision

    Associate a new certificate to a machine identity and trigger provisioning to push the new certificate

    .EXAMPLE
    Find-VcMachineIdentity -Filter @('certificateId', 'eq', 'e79ce2db-7d9e-48f6-8492-d3ab0be804cf') | Set-VcMachineIdentity -Certificate '7ac56ec0-2017-11ee-9417-a17dd25b82f9'

    Find all machine identities with a specific certificate and update the certificate
    #>

    [CmdletBinding()]

    param (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('machineIdentityID')]
        [ValidateScript({ Test-IsGuid $_ })]
        [string] $MachineIdentity,

        [Parameter(Mandatory)]
        [Alias('certificateID')]
        [ValidateScript({ Test-IsGuid $_ })]
        [string] $Certificate,

        [Parameter()]
        [ValidateSet('NEW', 'PENDING', 'INSTALLED', 'DISCOVERED', 'VALIDATED', 'MISSING', 'FAILED')]
        [string] $Status = 'NEW',

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


        $params = @{
            Method = 'Patch'
            Body   = @{
                status = $Status
            }
        }

        if ( $Certificate ) {
            $certId = Get-VcData -InputObject $Certificate -Type 'Certificate'
            $params.Body.certificateId = $certId
        }

        if ( $Keystore ) {
            $params.Body.keystore = $Keystore
        }

        if ( $Binding ) {
            $params.Body.binding = $Binding
        }
    }

    process {
        $params.UriLeaf = 'machineidentities/{0}' -f $MachineIdentity

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
