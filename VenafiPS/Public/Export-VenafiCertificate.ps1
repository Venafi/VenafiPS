<#
.SYNOPSIS
Get a certificate

.DESCRIPTION
Get a certificate

.PARAMETER Id
Id of the certificate

.PARAMETER Format
Certificate format, either PEM or DER

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Id

.OUTPUTS
System.String

.EXAMPLE
$certId | Export-VaasCertificate
Get a certificate

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Export-VaasCertificate/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Export-VaasCertificate.ps1

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

        [Parameter(ParameterSetName = 'Tpp')]
        [switch] $IncludeChain,

        [Parameter(ParameterSetName = 'Tpp')]
        [Parameter(Mandatory, ParameterSetName = 'TppJks')]
        [string] $FriendlyName,

        [Parameter(ParameterSetName = 'Tpp')]
        [switch] $IncludePrivateKey,

        [Parameter(ParameterSetName = 'Tpp')]
        [Alias('SecurePassword')]
        [Security.SecureString] $PrivateKeyPassword,

        [Parameter(Mandatory, ParameterSetName = 'TppJks')]
        [Security.SecureString] $KeystorePassword,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $params = @{
            VenafiSession = $VenafiSession
            Body          = @{
                Format = $Format
            }
        }

        $authType = $VenafiSession.Validate()

        if ( $authType -eq 'vaas' ) {

            if ( $Format -notin 'PEM', 'DER') {
                throw 'Venafi as a Service only supports PEM and DER formats'
            }
        } else {

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
    }

    process {

        if ( $authType -eq 'vaas' ) {
            $params.UriLeaf = "certificaterequests/$CertificateId/certificate"
            $params.Method = 'Get'
            Invoke-TppRestMethod @params
        } else {
            $params.Method     = 'Post'
            $params.UriLeaf    = 'certificates/retrieve'

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
            } else {
                $response
            }
        }
    }
}
