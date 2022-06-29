function Import-TppCertificate {
    <#
    .SYNOPSIS
    Import one or more certificates

    .DESCRIPTION
    Import one or more certificates with or without private key.
    PowerShell v5 will execute sequentially and v7 will run in parallel.

    .PARAMETER PolicyPath
    Policy path to import the certificate to.
    \ved\policy is prepended if not provided.

    .PARAMETER CertificatePath
    Path to a certificate file.  Provide either this or CertificateData.

    .PARAMETER CertificateData
    Contents of a certificate to import.  Provide either this or CertificatePath.

    .PARAMETER EnrollmentAttribute
    A hashtable providing any CA attributes to store with the Certificate object, and then submit to the CA during enrollment

    .PARAMETER Name
    Optional name for the certificate object.
    If not provided, the certificate Common Name (CN) is used.
    The derived certificate object name references an existing object (of any class).
    If another certificate has the same CN, a dash (-) integer appends to the CertificateDN. For example, test.venafi.example - 3.
    If not provided and the CN is also missing, the name becomes the first Domain Name System (DNS) Subject Alternative Name (SAN).
    Finally, if none of the above are found, the serial number is used.

    .PARAMETER PrivateKey
    Private key data; requires a value for Password.
    For a PEM certificate, the private key is in either the RSA or PKCS#8 format.
    Do not provide for a PKCS#12 certificate as the private key is already included.

    .PARAMETER Password
    Password required if the certificate has a private key.

    .PARAMETER Reconcile
    Controls certificate and corresponding private key replacement.
    By default, this function will import and replace the certificate regardless of whether a past, future, or same version of the certificate exists in Trust Protection Platform.
    By using this parameter, this function will import, but use newest. Only import the certificate when no Certificate object exists with a past, present, or current version of the imported certificate.
    If a match is found between the Certificate object and imported certificate, activate the certificate with the most current 'Valid From' date.
    Archive the unused certificate, even if it is the imported certificate, to the History tab.
    See https://docs.venafi.com/Docs/currentSDK/TopNav/Content/CA/c-CA-Import-ReconciliationRules-tpp.php for a flowchart of the reconciliation algorithm.

    .PARAMETER ThrottleLimit
    Number of threads when using parallel processing.  The default is 100.
    Applicable to PS v6+ only.

    .PARAMETER PassThru
    Return a TppObject representing the newly imported object.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .EXAMPLE
    Import-TppCertificate -PolicyPath \ved\policy\mycerts -CertificatePath c:\www.VenafiPS.com.cer
    Import a certificate

    .EXAMPLE
    gci c:\certs | Import-TppCertificate -PolicyPath \ved\policy\mycerts
    Import multiple certificates

    .EXAMPLE
    Import-TppCertificate -PolicyPath mycerts -CertificatePath (gci c:\certs).FullName
    Import multiple certificates in parallel on PS v6+.  \ved\policy will be appended to the policy path.

    .INPUTS
    CertificatePath, CertificateData

    .OUTPUTS
    TppObject, if PassThru provided

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Import.php
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByFile')]

    param (

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $PolicyPath,

        [Parameter(Mandatory, ParameterSetName = 'ByFile', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'ByFileWithPrivateKey', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-Path ) {
                    $true
                } else {
                    throw "'$_' is not a valid path"
                }
            })]
        [Alias('FullName')]
        [String[]] $CertificatePath,

        [Parameter(Mandatory, ParameterSetName = 'ByData', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'ByDataWithPrivateKey', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String[]] $CertificateData,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Hashtable] $EnrollmentAttribute,

        [Parameter(Mandatory, ParameterSetName = 'ByFileWithPrivateKey')]
        [Parameter(Mandatory, ParameterSetName = 'ByDataWithPrivateKey')]
        [ValidateNotNullOrEmpty()]
        [String] $PrivateKey,

        [Parameter(ParameterSetName = 'ByFile')]
        [Parameter(ParameterSetName = 'ByData')]
        [Parameter(Mandatory, ParameterSetName = 'ByFileWithPrivateKey')]
        [Parameter(Mandatory, ParameterSetName = 'ByDataWithPrivateKey')]
        [ValidateNotNullOrEmpty()]
        [SecureString] $Password,

        [Parameter()]
        [switch] $Reconcile,

        [Parameter()]
        [int32] $ThrottleLimit = 100,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP' -AuthType 'token'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriLeaf       = 'certificates/import'
            Body          = @{
                PolicyDN = $PolicyPath
            }
        }

        if ( $params.Body.PolicyDN.ToLower() -notlike '\ved\*') {
            $params.Body.PolicyDN = Join-Path -Path '\ved\policy' -ChildPath $PolicyPath
        }

        if ( $PSBoundParameters.ContainsKey('EnrollmentAttribute') ) {
            $updatedAttribute = @($EnrollmentAttribute.GetEnumerator() | ForEach-Object { @{'Name' = $_.name; 'Value' = $_.value } })
            $params.Body.CASpecificAttributes = $updatedAttribute
        }

        if ( $Reconcile ) {
            $params.Body.Reconcile = 'true'
        }

        if ( $PSBoundParameters.ContainsKey('Name') ) {
            $params.Body.ObjectName = $Name
        }

        if ( $PSBoundParameters.ContainsKey('Password') ) {
            $params.Body.Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
        }

        if ( $PSBoundParameters.ContainsKey('PrivateKey') ) {
            $params.Body.PrivateKeyData = $PrivateKey
        }
    }

    process {

        Write-Verbose $PSCmdlet.ParameterSetName

        $certInfo = if ( $PSCmdlet.ParameterSetName -like 'ByFile*' ) {
            $CertificatePath
        } else {
            $CertificateData
        }

        if ($PSVersionTable.PSVersion.Major -lt 6) {

            foreach ($thisCertInfo in $certInfo) {

                $thisCertData = if ( $PSCmdlet.ParameterSetName -like 'ByFile*' ) {
                    $cert = Get-Content $thisCertInfo -Encoding Byte
                    [System.Convert]::ToBase64String($cert)
                } else {
                    $thisCertInfo
                }

                $params.Body.CertificateData = $thisCertData

                try {
                    $response = Invoke-VenafiRestMethod @params

                    Write-Verbose ('Successfully imported {0}' -f $response.CertificateDN)

                    if ( $PassThru ) {
                        Get-TppObject -Guid $response.Guid
                    }
                } catch {
                    Write-Error $_
                }
            }
        } else {

            $certInfo | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {

                $thisCertInfo = $_

                Import-Module VenafiPS
                # create session without call to server
                New-VenafiSession -Server ($using:VenafiSession).Server -AccessToken ($using:VenafiSession).Token.AccessToken

                # figure out if we're working with a cert path or data directly
                $thisCertData = if ( Test-Path -Path $thisCertInfo ) {
                    $cert = Get-Content $thisCertInfo -AsByteStream
                    [System.Convert]::ToBase64String($cert)
                } else {
                    $thisCertInfo
                }

                $params = $using:params
                # session was set in params for ps v6, but as we recreated in this thread it needs to be set again
                $params.VenafiSession = $VenafiSession
                $params.Body.CertificateData = $thisCertData

                try {
                    $response = Invoke-VenafiRestMethod @params

                    if ( $using:PassThru ) {
                        Get-TppObject -Guid $response.Guid
                    }
                } catch {
                    Write-Error $_
                }
            }
        }
    }
}
