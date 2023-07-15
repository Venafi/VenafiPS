function Set-VaasCertificateAssignment {
    <#
    .SYNOPSIS
    Associate certificates with applications

    .DESCRIPTION
    Associate one or more certificates with one or more applications.
    The associated applications can either replace or be added to existing.
    By default, applications will be replaced.

    .PARAMETER CertificateID
    Certificate ID to be associated

    .PARAMETER ApplicationID
    One or more application IDs

    .PARAMETER NoOverwrite
    Append to existing applications as opposed to overwriting

    .PARAMETER PassThru
    Return the newly updated certificate object(s)

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .INPUTS
    CertificateID

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Set-VaasCertificateAssignment -CertificateID '7ac56ec0-2017-11ee-9417-a17dd25b82f9' -ApplicationID '96fc9310-67ec-11eb-a8a7-794fe75a8e6f'

    Associate a certificate to an application

    .EXAMPLE
    Set-VaasCertificateAssignment -CertificateID '7ac56ec0-2017-11ee-9417-a17dd25b82f9' -ApplicationID '96fc9310-67ec-11eb-a8a7-794fe75a8e6f', 'a05013bd-921d-440c-bc22-c9ead5c8d548'

    Associate a certificate to multiple applications

    .EXAMPLE
    Find-VenafiCertificate -First 5 | Set-VaasCertificateAssignment -ApplicationID '96fc9310-67ec-11eb-a8a7-794fe75a8e6f'

    Associate multiple certificates to 1 application

    .EXAMPLE
    Set-VaasCertificateAssignment -CertificateID '7ac56ec0-2017-11ee-9417-a17dd25b82f9' -ApplicationID '96fc9310-67ec-11eb-a8a7-794fe75a8e6f' -NoOverwrite

    Associate a certificate to another application, keeping the existing
    #>

    [CmdletBinding()]

    param (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $CertificateID,

        [Parameter(Mandatory)]
        [string[]] $ApplicationID,

        [Parameter()]
        [switch] $NoOverwrite,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [Alias('Key')]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Patch'
            UriRoot       = 'outagedetection/v1'
            UriLeaf       = 'applications/certificates'
            Body          = @{
                action                 = 'REPLACE'
                targetedApplicationIds = $ApplicationID
            }
        }

        if ( $NoOverwrite ) {
            $params.Body.action = 'ADD'
        }

        $allCerts = [System.Collections.Generic.List[object]]::new()
    }

    process {
        $allCerts.Add($CertificateID)
    }

    end {
        $params.Body.certificateIds = $allCerts

        $response = Invoke-VenafiRestMethod @params

        if ( $PassThru ) {
            $response.certificates
        }

    }
}
