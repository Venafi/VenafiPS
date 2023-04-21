function Export-VenafiCertificate {
    <#
    .SYNOPSIS
    Get certificate data

    .DESCRIPTION
    Get certificate data from either Venafi as a Service or TPP.

    .PARAMETER CertificateId
    Certificate identifier.  For Venafi as a Service, this is the unique guid.  For TPP, use the full path.

    .PARAMETER TppFormat
    Certificate format, either Base64, Base64 (PKCS#8), DER, PKCS #7, or PKCS #12.

    .PARAMETER VaasFormat
    Certificate format, either DER or PEM

    .PARAMETER OutPath
    Folder path to save the certificate to.  The name of the file will be determined automatically.

    .PARAMETER IncludeChain
    Include the certificate chain with the exported certificate.  Not supported with DER format.

    .PARAMETER RootFirst
    Use with -IncludeChain for VaaS to return the root first instead of the end entity first

    .PARAMETER FriendlyName
    Label or alias to use.  Permitted with Base64 and PKCS #12 formats.  Required when exporting JKS.  TPP Only.

    .PARAMETER IncludePrivateKey
    DEPRECATED. Provide a value for -PrivateKeyPassword.  TPP only.

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
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    CertificateId / Path from TppObject

    .OUTPUTS
    Vaas, System.String.  TPP, PSCustomObject.

    .EXAMPLE
    $certId | Export-VenafiCertificate -VaasFormat PEM
    Get certificate data from Venafi as a Service

    .EXAMPLE
    $cert | Export-VenafiCertificate -TppFormat 'PKCS #7' -OutPath 'c:\temp'
    Get certificate data and save to a file

    .EXAMPLE
    $cert | Export-VenafiCertificate -TppFormat 'PKCS #7' -IncludeChain
    Get one or more certificates with the certificate chain included, TPP

    .EXAMPLE
    $cert | Export-VenafiCertificate -VaasFormat PEM -IncludeChain -RootFirst
    Get one or more certificates with the certificate chain included and the root first in the chain, VaaS

    .EXAMPLE
    $cert | Export-VenafiCertificate -TppFormat 'PKCS #12' -PrivateKeyPassword $cred.password
    Get one or more certificates with private key included, TPP

    .EXAMPLE
    $cert | Export-VenafiCertificate -FriendlyName 'MyFriendlyName' -KeystorePassword $cred.password
    Get certificates in JKS format, TPP.  -TppFormat not needed since we know its JKS via -KeystorePassword.

    #>

    [CmdletBinding()]

    param (

        [Parameter(ParameterSetName = 'Tpp', Mandatory, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'TppJks', Mandatory, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'Vaas', Mandatory, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'VaasChain', Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Path', 'id')]
        [string] $CertificateId,

        [Parameter(ParameterSetName = 'Tpp', Mandatory)]
        [ValidateSet("Base64", "Base64 (PKCS #8)", "DER", "PKCS #7", "PKCS #12")]
        [Alias('Format')]
        [string] $TppFormat,

        [Parameter(ParameterSetName = 'Vaas', Mandatory)]
        [Parameter(ParameterSetName = 'VaasChain', Mandatory)]
        [ValidateSet("DER", "PEM")]
        [string] $VaasFormat,

        [Parameter(ParameterSetName = 'Tpp')]
        [Parameter(ParameterSetName = 'Vaas')]
        [Parameter(ParameterSetName = 'VaasChain')]
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
        [Parameter(ParameterSetName = 'VaasChain', Mandatory)]
        [switch] $IncludeChain,

        [Parameter(ParameterSetName = 'VaasChain')]
        [switch] $RootFirst,

        [Parameter(ParameterSetName = 'Tpp')]
        [Parameter(Mandatory, ParameterSetName = 'TppJks')]
        [string] $FriendlyName,

        [Parameter(ParameterSetName = 'Tpp')]
        [Parameter(ParameterSetName = 'TppJks')]
        [Alias('SecurePassword')]
        [Security.SecureString] $PrivateKeyPassword,

        [Parameter(Mandatory, ParameterSetName = 'TppJks')]
        [Security.SecureString] $KeystorePassword,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        $platform = Test-VenafiSession -VenafiSession $VenafiSession -Platform $PsCmdlet.ParameterSetName -PassThru

        $params = @{
            VenafiSession = $VenafiSession
            Body          = @{}
        }

        if ( $platform -eq 'VaaS' ) {

            $params.Body.Format = $VaasFormat

            if ( $IncludeChain ) {
                if ( $Format -in @('DER') ) {
                    throw "-IncludeChain is not supported with the DER Format"
                }

                $params.Body.chainOrder = 'EE_FIRST'
                if ( $RootFirst ) {
                    $params.Body.chainOrder = 'ROOT_FIRST'
                }
            }
            else {
                $params.Body.chainOrder = 'EE_ONLY'
            }

        }
        else {

            $params.Body.Format = $TppFormat

            if ( $PSBoundParameters.ContainsKey('PrivateKeyPassword') ) {

                # validate format to be able to export the private key
                if ( $Format -in @("DER", "PKCS #7") ) {
                    throw "Format '$Format' does not support private keys"
                }

                $params.Body.IncludePrivateKey = $true
                $plainTextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringUni([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($PrivateKeyPassword))
                $params.Body.Password = $plainTextPassword
            }

            if ( $PSBoundParameters.ContainsKey('KeystorePassword') ) {
                $params.Body.Format = 'JKS'
                $plainTextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringUni([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($KeystorePassword))
                $params.Body.KeystorePassword = $plainTextPassword
            }

            if ( $PSBoundParameters.ContainsKey('FriendlyName') ) {
                if ($Format -in @("Base64 (PKCS #8)", "DER", "PKCS #7")) {
                    throw "Only Base64, JKS, PKCS #12 formats support -FriendlyName parameter"
                }

                $params.Body.FriendlyName = $FriendlyName
            }

            if ($IncludeChain) {
                if ( $Format -in @('DER') ) {
                    throw "-IncludeChain is not supported with the DER Format"
                }

                $params.Body.IncludeChain = $true
            }
        }
    }

    process {

        if ( $platform -eq 'VaaS' ) {
            $params.UriRoot = 'outagedetection/v1'
            $params.UriLeaf = "certificates/$CertificateId/contents"
            $params.Method = 'Get'
            $params.FullResponse = $true
            $response = Invoke-VenafiRestMethod @params
            $response = [pscustomobject] @{
                'CertificateData' = $response.Content -replace "`r|`n|-----(BEGIN|END)[\w\s]+-----|\\r|\\n"
                FileName          = "$CertificateId.$VaasFormat"
            }

        }
        else {
            $params.Method = 'Post'
            $params.UriLeaf = 'certificates/retrieve'

            $params.Body.CertificateDN = $CertificateId | ConvertTo-TppFullPath

            $response = Invoke-VenafiRestMethod @params

            Write-Verbose ($response | Format-List | Out-String)
        }

        if ( $PSBoundParameters.ContainsKey('OutPath') ) {
            if ( $response.PSobject.Properties.name -contains "CertificateData" ) {
                $outFile = Join-Path -Path $OutPath -ChildPath ($response.FileName.Trim('"'))
                $bytes = [Convert]::FromBase64String($response.CertificateData)
                [IO.File]::WriteAllBytes($outFile, $bytes)
                Write-Verbose "Saved $outFile"
            }
        }
        else {
            $response
        }
    }
}
