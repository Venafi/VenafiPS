<#
.SYNOPSIS
Get a certificate

.DESCRIPTION
Get a certificate with or without private key.
You have the option of simply getting the data or saving it to a file.

.PARAMETER Path
Path to the certificate object to retrieve

.PARAMETER Format
The format of the returned certificate.  Valid formats include Base64, Base64 (PKCS #8), DER, JKS, PKCS #7, PKCS #12.

.PARAMETER OutPath
Folder path to save the certificate to.  The name of the file will be determined automatically.

.PARAMETER IncludeChain
Include the certificate chain with the exported certificate.  Not supported with DER format.

.PARAMETER FriendlyName
Label or alias to use.  Permitted with Base64 and PKCS #12 formats.  Required when Format is JKS.

.PARAMETER PrivateKeyPassword
Password required to include the private key.  Not supported with DER or PKCS #7 formats.
You must adhere to the following rules:
- Password is at least 12 characters.
- Comprised of at least three of the following:
    - Uppercase alphabetic letters
    - Lowercase alphabetic letters
    - Numeric characters
    - Special characters

.PARAMETER KeystorePassword
Password required to retrieve the certificate in JKS format.  You must adhere to the following rules:
- Password is at least 12 characters.
- Comprised of at least three of the following:
    - Uppercase alphabetic letters
    - Lowercase alphabetic letters
    - Numeric characters
    - Special characters

.PARAMETER TppSession
Session object created from New-TppSession method.  The value defaults to the script session object $TppSession.

.EXAMPLE
$certs | Get-TppCertificate -Format 'PKCS #7' -OutPath 'c:\temp'
Get certificate data and save to a file

.EXAMPLE
$certs | Get-TppCertificate -Format 'PKCS #7' -IncludeChain
Get one or more certificates with the certificate chain included

.EXAMPLE
$certs | Get-TppCertificate -Format 'PKCS #12' -PrivateKeyPassword $cred.password
Get one or more certificates with private key included

.EXAMPLE
$certs | Get-TppCertificate -FriendlyName 'MyFriendlyName' -KeystorePassword $cred.password
Get certificates in JKS format

.INPUTS
Path

.OUTPUTS
If OutPath not provided, a PSCustomObject will be returned with properties CertificateData, Filename, and Format.  Otherwise, no output.

#>
function Get-TppCertificate {
    [CmdletBinding(DefaultParameterSetName = 'NonJKS')]
    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                } else {
                    throw "'$_' is not a valid path"
                }
            })]
        [Alias('DN')]
        [String] $Path,

        [Parameter(Mandatory, ParameterSetName = 'NonJKS')]
        [Parameter(ParameterSetName = 'JKS')]
        [ValidateSet("Base64", "Base64 (PKCS #8)", "DER", "JKS", "PKCS #7", "PKCS #12")]
        [String] $Format,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if (Test-Path $_ -PathType Container) {
                    $true
                } else {
                    Throw "Output path '$_' does not exist"
                }
            })]
        [String] $OutPath,

        [Parameter()]
        [switch] $IncludeChain,

        [Parameter(ParameterSetName = 'NonJKS')]
        [Parameter(Mandatory, ParameterSetName = 'JKS')]
        [string] $FriendlyName,

        [Parameter()]
        [switch] $IncludePrivateKey,

        [Parameter()]
        [Alias('SecurePassword')]
        [Security.SecureString] $PrivateKeyPassword,

        [Parameter(Mandatory, ParameterSetName = 'JKS')]
        [Security.SecureString] $KeystorePassword,

        [Parameter()]
        [TppSession] $TppSession = $Script:TppSession
    )

    begin {

        $TppSession.Validate()

        $params = @{
            TppSession = $TppSession
            Method     = 'Post'
            UriLeaf    = 'certificates/retrieve'
            Body       = @{
                Format = $Format
            }
        }

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

    }

    process {

        $params.Body.CertificateDN = $Path

        $response = Invoke-TppRestMethod @params

        Write-Verbose ($response | Format-List | Out-String)

        if ( $PSBoundParameters.ContainsKey('OutPath') ) {
            if ( $response.PSobject.Properties.name -contains "CertificateData" ) {
                $outFile = Join-Path -Path $OutPath -ChildPath ($response.FileName.Trim('"'))
                $bytes = [Convert]::FromBase64String($response.CertificateData)
                [IO.File]::WriteAllBytes($outFile, $bytes)
                Write-Verbose ('Saved {0} with format {1}' -f $outFile, $response.Format)
            }
        } else {
            $response
        }
    }
}
