function Export-VdcCertificate {
    <#
    .SYNOPSIS
    Expoort certificate data from TLSPDC

    .DESCRIPTION
    Export certificate data

    .PARAMETER Path
    Full path to the certificate

    .PARAMETER Format
    Certificate format, either Base64, Base64 (PKCS#8), DER, PKCS #7, or PKCS #12.
    Defaults to Base64.

    .PARAMETER OutPath
    Folder path to save the certificate to.  The name of the file will be determined automatically.

    .PARAMETER IncludeChain
    Include the certificate chain with the exported certificate.  Not supported with DER format.

    .PARAMETER RootFirst
    Use with -IncludeChain for TLSPC to return the root first instead of the end entity first

    .PARAMETER FriendlyName
    Label or alias to use.  Permitted with Base64 and PKCS #12 formats.  Required when exporting JKS.

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
    Password required to retrieve the certificate in JKS format.
    You must adhere to the following rules:
    - Password is at least 12 characters.
    - Comprised of at least three of the following:
        - Uppercase alphabetic letters
        - Lowercase alphabetic letters
        - Numeric characters
        - Special characters

    .PARAMETER ThrottleLimit
    Limit the number of threads when running in parallel; the default is 100.  Applicable to PS v7+ only.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named TLSPDC_SERVER must also be set.

    .INPUTS
    Path

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Export-VdcCertificate -Path '\ved\policy\mycert.com'

    Get certificate data

    .EXAMPLE
    $cert | Export-VdcCertificate -TppFormat 'PKCS #7' -OutPath 'c:\temp'

    Get certificate data and save to a file

    .EXAMPLE
    $cert | Export-VdcCertificate -TppFormat 'PKCS #7' -IncludeChain

    Get one or more certificates with the certificate chain included

    .EXAMPLE
    $cert | Export-VdcCertificate -TppFormat 'PKCS #12' -PrivateKeyPassword $cred.password

    Get one or more certificates with private key included

    .EXAMPLE
    $cert | Export-VdcCertificate -FriendlyName 'MyFriendlyName' -KeystorePassword $cred.password

    Get certificates in JKS format.  -TppFormat not needed since we know its JKS via -KeystorePassword.

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

        [Parameter()]
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
        [int] $ThrottleLimit = 100,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TLSPDC'

        $allCerts = [System.Collections.Generic.List[string]]::new()

        $body = @{ Format = $Format }

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

        $allCerts.Add(($Path | ConvertTo-VdcFullPath))
    }

    end {
        Invoke-VenafiParallel -InputObject $allCerts -ScriptBlock {

            # hashtables are reference types so the body must be cloned or the parent scope gets updated
            $body = ($using:body).Clone()

            $body.CertificateDN = $PSItem

            $innerResponse = Invoke-VenafiRestMethod -Method 'Post' -UriLeaf 'certificates/retrieve' -Body $body

            $out = $innerResponse | Select-Object Filename, Format, @{
                n = 'Path'
                e = { $body.CertificateDN }
            },
            @{
                n = 'Error'
                e = { $_.Status }
            }

            if ( $using:OutPath ) {
                if ( $innerResponse.PSobject.Properties.name -contains "CertificateData" ) {
                    $outFile = Join-Path -Path $using:OutPath -ChildPath ($innerResponse.FileName.Trim('"'))
                    $bytes = [Convert]::FromBase64String($innerResponse.CertificateData)
                    [IO.File]::WriteAllBytes($outFile, $bytes)
                    Write-Verbose "Saved $outFile"
                    $out | Add-Member @{'OutPath' = $outFile }
                }
            }
            else {
                $out | Add-Member @{'CertificateData' = $innerResponse.CertificateData }
            }

            $out

        } -ThrottleLimit $ThrottleLimit -ProgressTitle 'Exporting certificates'
    }
}
