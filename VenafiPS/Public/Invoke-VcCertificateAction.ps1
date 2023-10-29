function Invoke-VcCertificateAction {
    <#
    .SYNOPSIS
    Perform an action against one or more certificates

    .DESCRIPTION
    One stop shop for basic certificate actions.
    You can Retire, Recover, Renew, Validate, or Delete.

    .PARAMETER ID
    ID of the certificate

    .PARAMETER Retire
    Retire a certificate

    .PARAMETER Recover
    Recover a retired certificate

    .PARAMETER Renew
    Requests immediate renewal for an existing certificate

    .PARAMETER Validate
    Initiates SSL/TLS network validation

    .PARAMETER Delete
    Delete a certificate.
    As only retired certificates can be deleted, this will be performed first.

    .PARAMETER AdditionalParameters
    Additional items specific to the action being taken, if needed.
    See the api documentation for appropriate items, many are in the links in this help.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .INPUTS
    ID

    .OUTPUTS
    PSCustomObject with the following properties:
        CertificateID - Certificate uuid
        Success - A value of true indicates that the action was successful

    .EXAMPLE
    Invoke-VcCertificateAction -ID '3699b03e-ff62-4772-960d-82e53c34bf60' -Retire

    Perform an action against 1 certificate

    .EXAMPLE
    Invoke-VcCertificateAction -ID '3699b03e-ff62-4772-960d-82e53c34bf60' -Delete -Confirm:$false

    Perform an action bypassing the confirmation prompt.  Only applicable to Delete.

    .EXAMPLE
    Find-VcObject -Type Certificate -Filter @('certificateStatus','eq','retired') | Invoke-VcCertificateAction -Delete

    Search for all retired certificates and delete them

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?configUrl=%2Fv3%2Fapi-docs%2Fswagger-config&urls.primaryName=outagedetection-service

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Certificates/certificateretirement_deleteCertificates
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Params being used in paramset check, not by variable')]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('CertificateID')]
        [string] $ID,

        [Parameter(Mandatory, ParameterSetName = 'Retire')]
        [switch] $Retire,

        [Parameter(Mandatory, ParameterSetName = 'Recover')]
        [switch] $Recover,

        [Parameter(Mandatory, ParameterSetName = 'Renew')]
        [switch] $Renew,

        [Parameter(Mandatory, ParameterSetName = 'Validate')]
        [switch] $Validate,

        [Parameter(Mandatory, ParameterSetName = 'Delete')]
        [switch] $Delete,

        [Parameter()]
        [hashtable] $AdditionalParameters,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        $params = @{
            Method  = 'Post'
            UriRoot = 'outagedetection/v1'
        }

        $allCerts = [System.Collections.Generic.List[string]]::new()
    }

    process {

        $addThis = $true

        if ( $PsCmdlet.ParameterSetName -eq 'Delete' ) {
            $addThis = $PSCmdlet.ShouldProcess($ID, 'Delete certificate')
        }

        if ( $addThis ) { $allCerts.Add($ID) }
    }

    end {

        if ( $allCerts.Count -eq 0 ) { return }

        switch ($PSCmdLet.ParameterSetName) {
            'Retire' {
                $params.UriLeaf = "certificates/retirement"
                $params.Body = @{"certificateIds" = $allCerts }
            }

            'Recover' {
                $params.UriLeaf = "certificates/recovery"
                $params.Body = @{"certificateIds" = $allCerts }
            }

            'Renew' {
                $params.UriLeaf = "certificaterequests"
                $params.Body = @{"existingCertificateId" = $allCerts }
            }

            'Validate' {
                $params.UriLeaf = "certificates/validation"
                $params.Body = @{"certificateIds" = $allCerts }
            }

            'Delete' {
                $null = $allCerts | Invoke-VcCertificateAction -Retire

                $params.UriLeaf = "certificates/deletion"
                $params.Body = @{"certificateIds" = $allCerts }
            }
        }

        if ( $AdditionalParameters ) {
            $params.Body += $AdditionalParameters
        }

        $response = Invoke-VenafiRestMethod @params

        $processedIds = $response.certificates.id

        foreach ($certId in $allCerts) {
            [pscustomobject] @{
                CertificateID = $certId
                Success = ($certId -in $processedIds)
            }
        }
    }
}
