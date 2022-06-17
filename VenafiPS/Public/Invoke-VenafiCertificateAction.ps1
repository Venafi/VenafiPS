<#
.SYNOPSIS
Perform an action against a certificate on TPP or VaaS

.DESCRIPTION
One stop shop for basic certificate actions against either TPP or VaaS.
When supported by the platform, you can Retire, Reset, Renew, Push, Validate, or Revoke.

.PARAMETER CertificateId
Certificate identifier.  For Venafi as a Service, this is the unique guid.  For TPP, use the full path.

.PARAMETER Retire
Retire/disable a certificate

.PARAMETER Reset
Reset the state of a certificate and its associated applications.  TPP only.

.PARAMETER Renew
Requests immediate renewal for an existing certificate

.PARAMETER Push
Provisions the same certificate and private key to one or more devices or servers.
The certificate must be associated with one or more Application objects.
TPP only.

.PARAMETER Validate
Initiates SSL/TLS network validation

.PARAMETER Revoke
Sends a revocation request to the certificate CA.  TPP only.

.PARAMETER AdditionalParameters
Additional items specific to the action being taken, if needed.
See the api documentation for appropriate items, many are in the links in this help.

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
CertificateId

.OUTPUTS
PSCustomObject with the following properties:
    CertificateId - Certificate path (TPP) or Guid (VaaS)
    Success - A value of true indicates that the action was successful
    Error - Indicates any errors that occurred. Not returned when Success is true

.EXAMPLE
Invoke-VenafiCertificateAction -CertificateId '\VED\Policy\My folder\app.mycompany.com' -Revoke
Perform an action

.EXAMPLE
Invoke-VenafiCertificateAction -CertificateId '\VED\Policy\My folder\app.mycompany.com' -Revoke -AdditionalParameters @{'Comments'='Key compromised'}
Perform an action sending additional parameters.

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Invoke-TppCertificateRenewal/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Invoke-TppCertificateRenewal.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Reset.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-renew.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Push.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Validate.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-revoke.php

.LINK
https://api.venafi.cloud/webjars/swagger-ui/index.html?configUrl=%2Fv3%2Fapi-docs%2Fswagger-config&urls.primaryName=outagedetection-service

#>
function Invoke-VenafiCertificateAction {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Params being used in paramset check, not by variable')]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('Path', 'id')]
        [string] $CertificateId,

        [Parameter(Mandatory, ParameterSetName = 'Retire')]
        [switch] $Retire,

        [Parameter(Mandatory, ParameterSetName = 'Reset')]
        [switch] $Reset,

        [Parameter(Mandatory, ParameterSetName = 'Renew')]
        [switch] $Renew,

        [Parameter(Mandatory, ParameterSetName = 'Push')]
        [switch] $Push,

        [Parameter(Mandatory, ParameterSetName = 'Validate')]
        [switch] $Validate,

        [Parameter(Mandatory, ParameterSetName = 'Revoke')]
        [switch] $Revoke,

        [Parameter()]
        [hashtable] $AdditionalParameters,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        $platform = Test-VenafiSession -VenafiSession $VenafiSession -PassThru
    }

    process {

        $returnObject = [PSCustomObject]@{
            CertificateId = $CertificateId
            Success       = $true
            Error         = $null
        }

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
        }

        switch ($platform) {
            'VaaS' {

                $params.UriRoot = 'outagedetection/v1'

                if ( $PSCmdLet.ParameterSetName -in 'Reset', 'Push', 'Revoke' ) {
                    throw ('{0} action is not supported on VaaS' -f $PSCmdLet.ParameterSetName)
                }

                switch ($PSCmdLet.ParameterSetName) {
                    'Retire' {
                        $params.UriLeaf = "certificates/retirement"
                        $params.Body = @{"certificateIds" = @($CertificateId) }
                    }

                    'Renew' {
                        $params.UriLeaf = "certificaterequests"
                        $params.Body = @{"existingCertificateId" = $CertificateId }
                    }

                    'Validate' {
                        $params.UriLeaf = "certificates/validation"
                        $params.Body = @{"certificateIds" = @($CertificateId) }
                    }
                }
            }

            Default {

                $performInvoke = $true

                switch ($PSCmdLet.ParameterSetName) {
                    'Retire' {
                        $performInvoke = $false

                        try {
                            Set-TppAttribute -Path $CertificateId -Attribute @{ 'Disabled' = '1' } -VenafiSession $VenafiSession
                        }
                        catch {
                            $returnObject.Success = $false
                            $returnObject.Error = $_
                        }
                    }

                    'Reset' {
                        $params.UriLeaf = 'Certificates/Reset'
                        $params.Body = @{
                            CertificateDN = $CertificateId
                        }
                    }

                    'Renew' {
                        $params.UriLeaf = 'Certificates/Renew'
                        $params.Body = @{
                            CertificateDN = $CertificateId
                        }
                    }

                    'Push' {
                        $params.UriLeaf = 'Certificates/Push'
                        $params.Body = @{
                            CertificateDN = $CertificateId
                        }
                    }

                    'Validate' {
                        $params.UriLeaf = 'Certificates/Validate'
                        $params.Body = @{
                            CertificateDNs = @($CertificateId)
                        }
                    }

                    'Revoke' {
                        $params.UriLeaf = 'Certificates/Revoke'
                        $params.Body = @{
                            CertificateDN = $CertificateId
                        }
                        if ( -not $PSCmdlet.ShouldProcess($CertificateId, 'Revoke certificate') ) {
                            $performInvoke = $false
                            $returnObject.Success = $false
                            $returnObject.Error = 'User cancelled'
                        }
                    }
                }
            }
        }

        if ( $AdditionalParameters ) {
            $params.Body += $AdditionalParameters
        }

        try {
            if ( $performInvoke ) {
                Invoke-VenafiRestMethod @params -FullResponse | Out-Null
            }
        }
        catch {
            $returnObject.Success = $false
            $returnObject.Error = $_
        }

        # return path so another function can be called
        $returnObject

    }
}
