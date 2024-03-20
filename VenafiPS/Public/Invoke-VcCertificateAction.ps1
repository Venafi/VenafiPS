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
    Requests immediate renewal for an existing certificate.
    If more than 1 application is associated with the certificate, provide -AdditionalParameters @{'Application'='application id'} to specify the id.
    Use -AdditionalParameters to provide additional parameters to the renewal request, see https://developer.venafi.com/tlsprotectcloud/reference/certificaterequests_create.

    .PARAMETER Validate
    Initiates SSL/TLS network validation

    .PARAMETER Delete
    Delete a certificate.
    As only retired certificates can be deleted, this will be performed first.

    .PARAMETER AdditionalParameters
    Additional items specific to the action being taken, if needed.
    See the api documentation for appropriate items, many are in the links in this help.

    .PARAMETER Force
    Force the operation under certain circumstances.
    - During a renewal, force choosing the first CN in the case of multiple CNs as only 1 is supported.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    ID

    .OUTPUTS
    When using retire and recover, PSCustomObject with the following properties:
        CertificateID - Certificate uuid
        Success - A value of true indicates that the action was successful

    .EXAMPLE
    Invoke-VcCertificateAction -ID '3699b03e-ff62-4772-960d-82e53c34bf60' -Retire

    Perform an action against 1 certificate

    .EXAMPLE
    Invoke-VcCertificateAction -ID '3699b03e-ff62-4772-960d-82e53c34bf60' -Renew -AdditionalParameters @{'Application'='10f71a12-daf3-4737-b589-6a9dd1cc5a97'}

    Perform an action against 1 certificate with additional parameters.
    In this case we are renewing a certificate, but the certificate has multiple applications associated with it.
    Only one certificate and application combination can be renewed at a time so provide the specific application to be renewed.

    .EXAMPLE
    Find-VcCertificate -Version CURRENT -Issuer i1 | Invoke-VcCertificateAction -Renew -AdditionalParameters @{'certificateIssuingTemplateId'='10f71a12-daf3-4737-b589-6a9dd1cc5a97'}

    Find all current certificates issued by i1 and renew them with a different issuer.

    .EXAMPLE
    Invoke-VcCertificateAction -ID '3699b03e-ff62-4772-960d-82e53c34bf60' -Renew -Force

    Renewals can only support 1 CN assigned to a certificate.  To force this function to renew and automatically select the first CN, use -Force.

    .EXAMPLE
    Invoke-VcCertificateAction -ID '3699b03e-ff62-4772-960d-82e53c34bf60' -Delete

    Delete a certificate.  As only retired certificates can be deleted, it will be retired first.

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

    .NOTES
    If performing a renewal and subjectCN has more than 1 value, only the first will be submitted with the renewal.
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

        [Parameter(ParameterSetName = 'Renew')]
        [switch] $Force,

        [Parameter()]
        [hashtable] $AdditionalParameters,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'

        $params = @{
            Method  = 'Post'
            UriRoot = 'outagedetection/v1'
        }

        $allCerts = [System.Collections.Generic.List[string]]::new()
    }

    process {

        $addThis = $true

        switch ($PSCmdlet.ParameterSetName) {
            'Delete' {
                $addThis = $PSCmdlet.ShouldProcess($ID, 'Delete certificate')
            }

            'Renew' {
                $addThis = $false

                $out = [pscustomobject] @{
                    CertificateID = $ID
                    Success       = $false
                    Error         = $null
                }

                $thisCert = Get-VcCertificate -ID $ID

                # only current certs can be renewed
                if ( $thisCert.versionType -ne 'CURRENT' ) {
                    $out.Error = 'Only certificates with a versionType of CURRENT can be renewed'
                    return $out
                }

                # multiple CN certs are supported by tlspc, but the request/renew api does not support it
                if ( $thisCert.subjectCN.count -gt 1 ) {
                    if ( -not $Force ) {
                        $out.Error = 'The certificate you are trying to renew has more than 1 common name.  You can either use -Force to automatically choose the first common name or utilize a different process to renew.'
                        return $out
                    }
                }

                switch (([array]$thisCert.application).count) {
                    1 {
                        $thisAppId = $thisCert.application.applicationId
                    }

                    0 {
                        throw 'To renew a certificate at least one application must be assigned'
                    }

                    Default {
                        # more than 1 application assigned
                        if ( $AdditionalParameters.Application ) {
                            $thisAppId = $AdditionalParameters.Application
                        }
                        else {
                            $out.Error = 'Multiple applications associated, {0}.  Only 1 application can be renewed at a time.  Rerun Invoke-VcCertificateAction and add ''-AdditionalParameter @{{''Application''=''application id''}}'' and provide the actual id you would like to renew.' -f (($thisCert.application | ForEach-Object { '{0} ({1})' -f $_.name, $_.applicationId }) -join ',')
                            return $out
                        }
                    }
                }

                $thisCertRequest = Invoke-VenafiRestMethod -UriRoot 'outagedetection/v1' -UriLeaf "certificaterequests/$($thisCert.certificateRequestId)"
                $renewParams = @{
                    existingCertificateId        = $ID
                    certificateIssuingTemplateId = $thisCertRequest.certificateIssuingTemplateId
                    applicationId                = $thisAppId
                    isVaaSGenerated              = $true
                    validityPeriod               = $thisCertRequest.validityPeriod
                    certificateOwnerUserId       = $thisCertRequest.certificateOwnerUserId
                    csrAttributes                = @{}
                }

                switch ($thisCert.PSObject.Properties.Name) {
                    'subjectCN' { $renewParams.csrAttributes.commonName = $thisCert.subjectCN[0] }
                    'subjectO' { $renewParams.csrAttributes.organization = $thisCert.subjectO }
                    'subjectOU' { $renewParams.csrAttributes.organizationalUnits = $thisCert.subjectOU }
                    'subjectL' { $renewParams.csrAttributes.locality = $thisCert.subjectL }
                    'subjectST' { $renewParams.csrAttributes.state = $thisCert.subjectST }
                    'subjectC' { $renewParams.csrAttributes.country = $thisCert.subjectC }
                    'subjectAlternativeNamesByType' {
                        $renewParams.csrAttributes.subjectAlternativeNamesByType = @{
                            'dnsNames'                   = $thisCert.subjectAlternativeNamesByType.dNSName
                            'ipAddresses'                = $thisCert.subjectAlternativeNamesByType.iPAddress
                            'rfc822Names'                = $thisCert.subjectAlternativeNamesByType.rfc822Name
                            'uniformResourceIdentifiers' = $thisCert.subjectAlternativeNamesByType.uniformResourceIdentifier
                        }
                    }
                }

                if ( $AdditionalParameters ) {
                    foreach ($key in $AdditionalParameters.Keys) {
                        $renewParams[$key] = $AdditionalParameters[$key]
                    }
                }

                try {
                    $null = Invoke-VenafiRestMethod -Method 'Post' -UriRoot 'outagedetection/v1' -UriLeaf 'certificaterequests' -Body $renewParams -ErrorAction Stop
                    $out.Success = $true
                }
                catch {
                    $out.Error = $_
                }

                return $out
            }
        }

        if ( $addThis ) { $allCerts.Add($ID) }
    }

    end {

        if ( $allCerts.Count -eq 0 ) { return }

        switch ($PSCmdLet.ParameterSetName) {
            'Retire' {
                $params.UriLeaf = "certificates/retirement"
                $params.Body = @{"certificateIds" = $allCerts }

                if ( $AdditionalParameters ) {
                    $params.Body += $AdditionalParameters
                }

                $response = Invoke-VenafiRestMethod @params

                $processedIds = $response.certificates.id

                foreach ($certId in $allCerts) {
                    [pscustomobject] @{
                        CertificateID = $certId
                        Success       = ($certId -in $processedIds)
                    }
                }
            }

            'Recover' {
                $params.UriLeaf = "certificates/recovery"
                $params.Body = @{"certificateIds" = $allCerts }

                if ( $AdditionalParameters ) {
                    $params.Body += $AdditionalParameters
                }

                $response = Invoke-VenafiRestMethod @params

                $processedIds = $response.certificates.id

                foreach ($certId in $allCerts) {
                    [pscustomobject] @{
                        CertificateID = $certId
                        Success       = ($certId -in $processedIds)
                    }
                }
            }

            'Validate' {
                $params.UriLeaf = "certificates/validation"
                $params.Body = @{"certificateIds" = $allCerts }

                $response = Invoke-VenafiRestMethod @params
            }

            'Delete' {
                $null = $allCerts | Invoke-VcCertificateAction -Retire

                $params.UriLeaf = "certificates/deletion"
                $params.Body = @{"certificateIds" = $allCerts }

                $response = Invoke-VenafiRestMethod @params
            }
        }

    }
}
