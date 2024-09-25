function Import-VdcCertificate {
    <#
    .SYNOPSIS
    Import one or more certificates

    .DESCRIPTION
    Import one or more certificates with or without private key.
    PowerShell v5 will execute sequentially and v7 will run in parallel.

    .PARAMETER Path
    Path to a certificate file.  Provide either this or -Data.

    .PARAMETER Data
    Contents of a certificate to import.  Provide either this or -Path.

    .PARAMETER PolicyPath
    Policy path to import the certificate to.
    \ved\policy is prepended if not provided.

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
    Private key data; requires a value for PrivateKeyPassword.
    For a PEM certificate, the private key is in either the RSA or PKCS#8 format.
    Do not provide for a PKCS#12 certificate as the private key is already included.

    .PARAMETER PrivateKeyPassword
    Password required if providing a private key.
    You can either provide a String, SecureString, or PSCredential.

    .PARAMETER Reconcile
    Controls certificate and corresponding private key replacement.
    By default, this function will import and replace the certificate regardless of whether a past, future, or same version of the certificate exists in Trust Protection Platform.
    By using this parameter, this function will import, but use newest. Only import the certificate when no Certificate object exists with a past, present, or current version of the imported certificate.
    If a match is found between the Certificate object and imported certificate, activate the certificate with the most current 'Valid From' date.
    Archive the unused certificate, even if it is the imported certificate, to the History tab.
    See https://docs.venafi.com/Docs/currentSDK/TopNav/Content/CA/c-CA-Import-ReconciliationRules-tpp.php for a flowchart of the reconciliation algorithm.

    .PARAMETER ThrottleLimit
    Limit the number of threads when running in parallel; the default is 100.
    Setting the value to 1 will disable multithreading.
    On PS v5 the ThreadJob module is required.  If not found, multithreading will be disabled.


    .PARAMETER PassThru
    Return a TppObject representing the newly imported object.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

    .EXAMPLE
    Import-VdcCertificate -PolicyPath \ved\policy\mycerts -Path c:\www.VenafiPS.com.cer

    Import a certificate

    .EXAMPLE
    gci c:\certs | Import-VdcCertificate -PolicyPath \ved\policy\mycerts

    Import multiple certificates.  On PS v7+, the certificates will be imported in parallel.

    .EXAMPLE
    Import-VdcCertificate -PolicyPath mycerts -Data $certData

    Import a certificate from data instead of a path

    .INPUTS
    Path, Data

    .OUTPUTS
    TppObject, if PassThru provided

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Import.php
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByFile')]
    [Alias('Import-TppCertificate')]

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
                }
                else {
                    throw "'$_' is not a valid path"
                }
            })]
        [Alias('FullName')]
        [String] $Path,

        [Parameter(Mandatory, ParameterSetName = 'ByData', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'ByDataWithPrivateKey', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String] $Data,

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
        [ValidateScript(
            {
                if ( $_ -is [string] -or $_ -is [securestring] -or $_ -is [pscredential] ) {
                    $true
                }
                else {
                    throw 'Unsupported type.  Provide either a String, SecureString, or PSCredential.'
                }
            }
        )]
        [psobject] $PrivateKeyPassword,

        [Parameter()]
        [switch] $Reconcile,

        [Parameter()]
        [int32] $ThrottleLimit = 100,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VDC'
        $allCerts = [System.Collections.Generic.List[hashtable]]::new()

        $params = @{

            Method  = 'Post'
            UriLeaf = 'certificates/import'
            Body    = @{
                PolicyDN = $PolicyPath | ConvertTo-VdcFullPath
            }
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

        if ( $PSBoundParameters.ContainsKey('PrivateKeyPassword') ) {
            $params.Body.PrivateKeyPassword = $PrivateKeyPassword | ConvertTo-PlaintextString
        }

        if ( $PSBoundParameters.ContainsKey('PrivateKey') ) {
            $params.Body.PrivateKeyData = $PrivateKey
        }
    }

    process {
        $allCerts.Add(
            @{
                InvokeParams = $params
                Data         = $Data
                Path         = $Path
            }
        )
    }

    end {
        Invoke-VenafiParallel -InputObject $allCerts -ScriptBlock {

            $certData = $PSItem.Data
            if ( $PSItem.Path ) {
                if ((([System.IO.Path]::GetExtension($PSItem.Path)) -in '.pfx', '.p12') -and $PSItem.InvokeParams.Body.PrivateKeyPassword ) {

                    # tpp won't accept a p12 and password so use this workaround to decrypt first
                    $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($PSItem.Path, $PSItem.InvokeParams.Body.PrivateKeyPassword, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
                    $certData = [System.Convert]::ToBase64String( $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12))

                }
                else {

                    if ($PSVersionTable.PSVersion.Major -lt 6) {
                        $cert = Get-Content $PSItem.Path -Encoding Byte
                    }
                    else {
                        $cert = Get-Content $PSItem.Path -AsByteStream
                    }
                    $certData = [System.Convert]::ToBase64String($cert)
                }

            }

            $params = $PSItem.InvokeParams
            $params.Body.CertificateData = $certData

            try {
                $response = Invoke-VenafiRestMethod @params

                if ( $using:PassThru ) {
                    Get-VdcObject -Guid $response.Guid.trim('{}')
                }
            }
            catch {
                Write-Error $_
            }
        } -ThrottleLimit $ThrottleLimit -ProgressTitle 'Importing certificates'
    }
}
