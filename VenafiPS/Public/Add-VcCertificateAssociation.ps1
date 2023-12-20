function Add-VcCertificateAssociation {
    <#
    .SYNOPSIS
    Associate certificates with applications

    .DESCRIPTION
    Associate one or more certificates with one or more applications.
    The associated applications can either replace or be added to existing.
    By default, applications will be replaced.

    .PARAMETER Certificate
    Certificate ID or name to be associated.
    If a name is provided and multiple certificates are found, they will all be associated.
    Tab completion can be used for a list of certificate names to choose from.
    Type 3 or more characters for tab completion to work.

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
    [Alias('Set-VaasCertificateAssignment')]

    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('CertificateID')]
        [string] $Certificate,

        [Parameter(Mandatory)]
        [Alias('ApplicationID')]
        [string[]] $Application,

        [Parameter()]
        [switch] $NoOverwrite,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [Alias('Key')]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'

        $apps = $Application | Get-VcData -Type 'Application'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Patch'
            UriRoot       = 'outagedetection/v1'
            UriLeaf       = 'applications/certificates'
            Body          = @{
                action                 = 'REPLACE'
                targetedApplicationIds = @($apps)
            }
        }

        if ( $NoOverwrite ) {
            $params.Body.action = 'ADD'
        }

        $allCerts = [System.Collections.Generic.List[string]]::new()
    }

    process {
        $certIDs = Get-VcData -InputObject $Certificate -Type 'Certificate'
        foreach ($certID in @($certIDs)) {
            $allCerts.Add($certID)
        }
    }

    end {
        $params.Body.certificateIds = $allCerts

        $response = Invoke-VenafiRestMethod @params

        if ( $PassThru ) {
            $response.certificates
        }

    }
}
