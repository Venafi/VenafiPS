<#
.SYNOPSIS
Get certificate data

.DESCRIPTION
Get certificate data from either Venafi as a Service or TPP.

.PARAMETER CertificateId
Certificate identifier.  For Venafi as a Service, this is the unique guid.  For TPP, use the full path.

.PARAMETER Format
Certificate format.  For Venafi as a Service, you can provide either PEM or DER.  For TPP, Base64, Base64 (PKCS#8), DER, JKS, PKCS #7, or PKCS #12.

.PARAMETER OutPath
Folder path to save the certificate to.  The name of the file will be determined automatically.  TPP Only...for now.

.PARAMETER IncludeChain
Include the certificate chain with the exported certificate.  Not supported with DER format.  TPP Only.

.PARAMETER FriendlyName
Label or alias to use.  Permitted with Base64 and PKCS #12 formats.  Required when Format is JKS.  TPP Only.

.PARAMETER IncludePrivateKey
DEPRECATED. Provide a value for -PrivateKeyPassword.

.PARAMETER PrivateKeyPassword
Password required to include the private key.  Not supported with DER or PKCS #7 formats.  TPP Only.
You must adhere to the following rules:
- Password is at least 12 characters.
- Comprised of at least three of the following:
    - Uppercase alphabetic letters
    - Lowercase alphabetic letters
    - Numeric characters
    - Special characters

.PARAMETER KeystorePassword
Password required to retrieve the certificate in JKS format.  TPP Only.
You must adhere to the following rules:
- Password is at least 12 characters.
- Comprised of at least three of the following:
    - Uppercase alphabetic letters
    - Lowercase alphabetic letters
    - Numeric characters
    - Special characters

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
CertificateId/Path from TppObject

.OUTPUTS
Vaas, System.String.  TPP, PSCustomObject.

.EXAMPLE
$certId | Export-VenafiCertificate -Format PEM
Get certificate data from Venafi as a Service

.EXAMPLE
$cert | Export-VenafiCertificate -Format 'PKCS #7' -OutPath 'c:\temp'
Get certificate data and save to a file, TPP

.EXAMPLE
$cert | Export-VenafiCertificate -Format 'PKCS #7' -IncludeChain
Get one or more certificates with the certificate chain included, TPP

.EXAMPLE
$cert | Export-VenafiCertificate -Format 'PKCS #12' -PrivateKeyPassword $cred.password
Get one or more certificates with private key included, TPP

.EXAMPLE
$cert | Export-VenafiCertificate -FriendlyName 'MyFriendlyName' -KeystorePassword $cred.password
Get certificates in JKS format, TPP

#>
function Export-VenafiCertificate {

    [CmdletBinding(DefaultParameterSetName = 'Vaas')]
    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Path')]
        [string] $CertificateId,

        [Parameter(Mandatory)]
        [ValidateSet("Base64", "Base64 (PKCS #8)", "DER", "JKS", "PKCS #7", "PKCS #12", "PEM")]
        [string] $Format,

        [Parameter(ParameterSetName = 'Tpp')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if (Test-Path $_ -PathType Container) {
                    $true
                }
                else {
                    Throw "Output path '$_' does not exist"
                }
            })]
        [String] $OutPath,

        [Parameter(ParameterSetName = 'Tpp')]
        [Parameter(ParameterSetName = 'TppJks')]
        [switch] $IncludeChain,

        [Parameter(ParameterSetName = 'Tpp')]
        [Parameter(Mandatory, ParameterSetName = 'TppJks')]
        [string] $FriendlyName,

        [Parameter(ParameterSetName = 'Tpp')]
        [switch] $IncludePrivateKey,

        [Parameter(ParameterSetName = 'Tpp')]
        [Parameter(ParameterSetName = 'TppJks')]
        [Alias('SecurePassword')]
        [Security.SecureString] $PrivateKeyPassword,

        [Parameter(Mandatory, ParameterSetName = 'TppJks')]
        [Security.SecureString] $KeystorePassword,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate()

        $params = @{
            VenafiSession = $VenafiSession
            Body          = @{
                Format = $Format
            }
        }

        if ( $VenafiSession.Platform -eq 'VaaS' ) {

            if ( $Format -notin 'PEM', 'DER') {
                throw 'Venafi as a Service only supports PEM and DER formats'
            }
        }
        else {

            if ($PrivateKeyPassword) {

                # validate format to be able to export the private key
                if ( $Format -in @("DER", "PKCS #7") ) {
                    throw "Format '$Format' does not support private keys"
                }

                $params.Body.IncludePrivateKey = $true
                $plainTextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringUni([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($PrivateKeyPassword))
                $params.Body.Password = $plainTextPassword
            }

            if ($Format -in @("Base64 (PKCS #8)", "DER", "PKCS #7")) {
                if (-not ([string]::IsNullOrEmpty($FriendlyName))) {
                    throw "Only Base64, JKS, PKCS #12 formats support FriendlyName parameter"
                }
            }

            if ( $KeystorePassword ) {
                if ( $Format -and $Format -ne 'JKS' ) {
                    Write-Warning "Changing format from $Format to JKS as KeystorePassword was provided"
                }
                $params.Body.Format = 'JKS'
                $plainTextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringUni([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($KeystorePassword))
                $params.Body.KeystorePassword = $plainTextPassword
            }

            if (-not [string]::IsNullOrEmpty($FriendlyName)) {
                $params.Body.FriendlyName = $FriendlyName
            }

            if ($IncludeChain) {
                if ( $Format -in @('DER') ) {
                    throw "IncludeChain is not supported with the DER Format"
                }

                $params.Body.IncludeChain = $true
            }

            if ($IncludePrivateKey) {
                Write-Warning "IncludePrivateKey is DEPRECATED. Provide a value for -PrivateKeyPassword instead."
            }
        }
    }

    process {

        if ( $VenafiSession.Platform -eq 'VaaS' ) {
            $params.UriRoot = 'outagedetection/v1'
            $params.UriLeaf = "certificates/$CertificateId/contents"
            $params.Method = 'Get'
            $params.FullResponse = $true
            $response = Invoke-TppRestMethod @params
            $response.Content
        }
        else {
            $params.Method = 'Post'
            $params.UriLeaf = 'certificates/retrieve'

            $params.Body.CertificateDN = $CertificateId

            $response = Invoke-TppRestMethod @params

            Write-Verbose ($response | Format-List | Out-String)

            if ( $PSBoundParameters.ContainsKey('OutPath') ) {
                if ( $response.PSobject.Properties.name -contains "CertificateData" ) {
                    $outFile = Join-Path -Path $OutPath -ChildPath ($response.FileName.Trim('"'))
                    $bytes = [Convert]::FromBase64String($response.CertificateData)
                    [IO.File]::WriteAllBytes($outFile, $bytes)
                    Write-Verbose ('Saved {0} with format {1}' -f $outFile, $response.Format)
                }
            }
            else {
                $response
            }
        }
    }
}
