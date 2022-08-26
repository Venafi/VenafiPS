<#
.SYNOPSIS
Perform an action against a certificate on TPP or VaaS

.DESCRIPTION
One stop shop for basic certificate actions against either TPP or VaaS.
When supported by the platform, you can Retire, Reset, Renew, Push, Validate, Revoke, or Delete.

.PARAMETER CertificateID
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

.PARAMETER Delete
Delete a certificate.

.PARAMETER AdditionalParameters
Additional items specific to the action being taken, if needed.
See the api documentation for appropriate items, many are in the links in this help.

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
CertificateID

.OUTPUTS
PSCustomObject with the following properties:
    CertificateID - Certificate path (TPP) or Guid (VaaS)
    Success - A value of true indicates that the action was successful
    Error - Indicates any errors that occurred. Not returned when Success is true

.EXAMPLE
Invoke-VenafiCertificateAction -CertificateID '\VED\Policy\My folder\app.mycompany.com' -Revoke

Perform an action

.EXAMPLE
Invoke-VenafiCertificateAction -CertificateID '\VED\Policy\My folder\app.mycompany.com' -Delete -Confirm:$false

Perform an action bypassing the confirmation prompt.  Only applicable to revoke and delete.

.EXAMPLE
Invoke-VenafiCertificateAction -CertificateID 'b7f1ab29-34a0-49ba-b801-cc9cd855fd24' -Revoke -Confirm:$false | Invoke-VenafiCertificateAction -Delete -Confirm:$false

Chain multiple actions together

.EXAMPLE
Invoke-VenafiCertificateAction -CertificateID '\VED\Policy\My folder\app.mycompany.com' -Revoke -AdditionalParameters @{'Comments'='Key compromised'}

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

.LINK
https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Certificates/certificateretirement_deleteCertificates
#>
function Invoke-VenafiCertificateAction {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Params being used in paramset check, not by variable')]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('Path', 'id')]
        [string] $CertificateID,

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

        [Parameter(Mandatory, ParameterSetName = 'Delete')]
        [switch] $Delete,

        [Parameter()]
        [hashtable] $AdditionalParameters,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        $platform = Test-VenafiSession -VenafiSession $VenafiSession -PassThru

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
        }

    }

    process {

        $returnObject = [PSCustomObject]@{
            CertificateID = $CertificateID
            Success       = $true
            Error         = $null
        }

        # at times, we don't want to call an api in the process block
        $performInvoke = $true

        switch ($platform) {
            'VaaS' {

                $params.UriRoot = 'outagedetection/v1'

                if ( $PSCmdLet.ParameterSetName -in 'Reset', 'Push', 'Revoke' ) {
                    throw ('{0} action is not supported on VaaS' -f $PSCmdLet.ParameterSetName)
                }

                switch ($PSCmdLet.ParameterSetName) {
                    'Retire' {
                        $params.UriLeaf = "certificates/retirement"
                        $params.Body = @{"certificateIds" = @($CertificateID) }
                    }

                    'Renew' {
                        $params.UriLeaf = "certificaterequests"
                        $params.Body = @{"existingCertificateId" = $CertificateID }
                    }

                    'Validate' {
                        $params.UriLeaf = "certificates/validation"
                        $params.Body = @{"certificateIds" = @($CertificateID) }
                    }

                    'Delete' {
                        if ( $PSCmdlet.ShouldProcess($CertificateID, 'Delete certificate') ) {
                            $params.UriLeaf = "certificates/deletion"
                            $params.Body = @{"certificateIds" = @($CertificateID) }
                        } else {
                            $performInvoke = $false
                            $returnObject.Success = $false
                            $returnObject.Error = 'User cancelled'
                        }
                    }
                }
            }

            Default {

                #TPP

                switch ($PSCmdLet.ParameterSetName) {
                    'Retire' {
                        $performInvoke = $false

                        try {
                            Set-TppAttribute -Path $CertificateID -Attribute @{ 'Disabled' = '1' } -VenafiSession $VenafiSession
                        } catch {
                            $returnObject.Success = $false
                            $returnObject.Error = $_
                        }
                    }

                    'Reset' {
                        $params.UriLeaf = 'Certificates/Reset'
                        $params.Body = @{
                            CertificateDN = $CertificateID
                        }
                    }

                    'Renew' {
                        $params.UriLeaf = 'Certificates/Renew'
                        $params.Body = @{
                            CertificateDN = $CertificateID
                        }
                    }

                    'Push' {
                        $params.UriLeaf = 'Certificates/Push'
                        $params.Body = @{
                            CertificateDN = $CertificateID
                        }
                    }

                    'Validate' {
                        $params.UriLeaf = 'Certificates/Validate'
                        $params.Body = @{
                            CertificateDNs = @($CertificateID)
                        }
                    }

                    'Revoke' {
                        $params.UriLeaf = 'Certificates/Revoke'
                        $params.Body = @{
                            CertificateDN = $CertificateID
                        }
                        if ( -not $PSCmdlet.ShouldProcess($CertificateID, 'Revoke certificate') ) {
                            $performInvoke = $false
                            $returnObject.Success = $false
                            $returnObject.Error = 'User cancelled'
                        }
                    }

                    'Delete' {
                        $performInvoke = $false
                        if ( $PSCmdlet.ShouldProcess($CertificateID, 'Delete certificate') ) {
                            Remove-TppCertificate -Path $CertificateID -VenafiSession $VenafiSession -Confirm:$false
                        } else {
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

        if ( $performInvoke ) {
            try {
                Invoke-VenafiRestMethod @params -FullResponse -Verbose | Out-Null
            } catch {
                $returnObject.Success = $false
                $returnObject.Error = $_
            }
        }

        # return path so another function can be called
        $returnObject
    }
}
