function Export-TppCertificate {
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
        [Alias('id')]
        [string] $Path,

        [Parameter(ParameterSetName = 'Tpp')]
        [ValidateSet("Base64", "Base64 (PKCS #8)", "DER", "PKCS #7", "PKCS #12")]
        [string] $Format = 'Base64',

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
        [Parameter(ParameterSetName = 'TppJks')]
        [Alias('SecurePassword')]
        [Security.SecureString] $PrivateKeyPassword,

        [Parameter(Mandatory, ParameterSetName = 'TppJks')]
        [Security.SecureString] $KeystorePassword,

        [Parameter()]
        [int] $ThrottleLimit = 20,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $allCerts = [System.Collections.Generic.List[string]]::new()

        # $params = @{
        #     VenafiSession = $VenafiSession
        #     Body          = @{}
        # }
        $body = @{}
        $body.Format = $Format

        if ( $PSBoundParameters.ContainsKey('PrivateKeyPassword') ) {

            # validate format to be able to export the private key
            if ( $Format -in @("DER", "PKCS #7") ) {
                throw "Format '$Format' does not support private keys"
            }

            $body.IncludePrivateKey = $true
            $plainTextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringUni([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($PrivateKeyPassword))
            $body.Password = $plainTextPassword
        }

        if ( $PSBoundParameters.ContainsKey('KeystorePassword') ) {
            $body.Format = 'JKS'
            $plainTextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringUni([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($KeystorePassword))
            $body.KeystorePassword = $plainTextPassword
        }

        if ( $PSBoundParameters.ContainsKey('FriendlyName') ) {
            if ($Format -in @("Base64 (PKCS #8)", "DER", "PKCS #7")) {
                throw "Only Base64, JKS, PKCS #12 formats support -FriendlyName parameter"
            }

            $body.FriendlyName = $FriendlyName
        }

        if ($IncludeChain) {
            if ( $Format -in @('DER') ) {
                throw "-IncludeChain is not supported with the DER Format"
            }

            $body.IncludeChain = $true
        }
    }

    process {

        # $params.Method = 'Post'
        # $params.UriLeaf = 'certificates/retrieve'

        # $body.CertificateDN = $CertificateId | ConvertTo-TppFullPath

        # $response = Invoke-VenafiRestMethod @params

        $allCerts.Add(($Path | ConvertTo-TppFullPath))

        # Write-Verbose ($response | Format-List | Out-String)

        # if ( $PSBoundParameters.ContainsKey('OutPath') ) {
        #     if ( $response.PSobject.Properties.name -contains "CertificateData" ) {
        #         $outFile = Join-Path -Path $OutPath -ChildPath ($response.FileName.Trim('"'))
        #         $bytes = [Convert]::FromBase64String($response.CertificateData)
        #         [IO.File]::WriteAllBytes($outFile, $bytes)
        #         Write-Verbose "Saved $outFile"
        #     }
        # }
        # else {
        #     $response
        # }
    }

    end {
        $response = Invoke-VenafiParallel -InputObject $allCerts -ScriptBlock {

            # combine cert path with body
            $body = $using:body
            $body.CertificateDN = $_

            Invoke-VenafiRestMethod -Method 'Post' -UriLeaf 'certificates/retrieve' -Body $body

        } -ThrottleLimit $ThrottleLimit -VenafiSession $VenafiSession

        $response
    }
}
