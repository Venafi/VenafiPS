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
    Password required to include the private key.
    You can either provide a String, SecureString, or PSCredential.
    You must adhere to the following rules:
    - Password is at least 12 characters.
    - Comprised of at least three of the following:
        - Uppercase alphabetic letters
        - Lowercase alphabetic letters
        - Numeric characters
        - Special characters

    .PARAMETER KeystorePassword
    Password required to retrieve the certificate in JKS format.
    You can either provide a String, SecureString, or PSCredential.
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
    If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

    .INPUTS
    Path

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Export-VdcCertificate -Path '\ved\policy\mycert.com'

    Get certificate data

    .EXAMPLE
    $cert | Export-VdcCertificate -'PKCS7' -OutPath 'c:\temp'

    Get certificate data and save to a file

    .EXAMPLE
    $cert | Export-VdcCertificate -'PKCS7' -IncludeChain

    Get one or more certificates with the certificate chain included

    .EXAMPLE
    $cert | Export-VdcCertificate -'PKCS12' -PrivateKeyPassword 'mySecretPassword!'

    Get one or more certificates with private key included

    .EXAMPLE
    $cert | Export-VdcCertificate -Jks -FriendlyName 'MyFriendlyName' -KeystorePassword $cred.password

    Get certificates in JKS format.

    #>

    [CmdletBinding(DefaultParameterSetName = 'Base64')]

    param (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string] $Path,

        [Parameter(ParameterSetName = 'Base64')]
        [switch] $Base64,

        [Parameter(Mandatory, ParameterSetName = 'Pkcs7')]
        [switch] $Pkcs7,

        [Parameter(Mandatory, ParameterSetName = 'Pkcs8')]
        [switch] $Pkcs8,

        [Parameter(Mandatory, ParameterSetName = 'Der')]
        [switch] $Der,

        [Parameter(Mandatory, ParameterSetName = 'Pkcs12')]
        [switch] $Pkcs12,

        [Parameter(Mandatory, ParameterSetName = 'Jks')]
        [switch] $Jks,

        [Parameter(ParameterSetName = 'Pkcs8')]
        [Parameter(ParameterSetName = 'Pkcs12')]
        [Parameter(ParameterSetName = 'Jks')]
        [Alias('SecurePassword')]
        [psobject] $PrivateKeyPassword,

        [Parameter(ParameterSetName = 'Base64')]
        [Parameter(ParameterSetName = 'Pkcs7')]
        [Parameter(ParameterSetName = 'Pkcs8')]
        [Parameter(ParameterSetName = 'Pkcs12')]
        [Parameter(ParameterSetName = 'Jks')]
        [switch] $IncludeChain,

        [Parameter(ParameterSetName = 'Base64')]
        [Parameter(ParameterSetName = 'Pkcs12')]
        [Parameter(Mandatory, ParameterSetName = 'Jks')]
        [string] $FriendlyName,

        [Parameter(Mandatory, ParameterSetName = 'Jks')]
        [psobject] $KeystorePassword,

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

        [Parameter()]
        [int] $ThrottleLimit = 100,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VDC'

        $allCerts = [System.Collections.Generic.List[hashtable]]::new()

        $body = @{ Format = 'Base64' }
        switch ($PSCmdlet.ParameterSetName) {
            'Pkcs7' { $body.Format = 'PKCS #7' }
            'Pkcs8' { $body.Format = 'Base64 (PKCS#8)' }
            'Pkcs12' { $body.Format = 'PKCS #12' }
            'Der' { $body.Format = 'DER' }
            'Jks' { $body.Format = 'JKS' }
        }

        if ( $PSBoundParameters.ContainsKey('PrivateKeyPassword') ) {

            $body.IncludePrivateKey = $true

            switch ($PrivateKeyPassword.GetType().Name) {
                'String' { $body.Password = $PrivateKeyPassword }
                'SecureString' { $body.Password = [System.Runtime.InteropServices.Marshal]::PtrToStringUni([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($PrivateKeyPassword)) }
                'PSCredential' { $body.Password = $PrivateKeyPassword.GetNetworkCredential().Password }
                Default { throw 'Unsupported type for -PrivateKeyPassword.  Provide either a String, SecureString, or PSCredential.' }
            }
        }

        if ( $PSBoundParameters.ContainsKey('KeystorePassword') ) {
            $body.Format = 'JKS'
            switch ($KeystorePassword.GetType().Name) {
                'String' { $body.Password = $KeystorePassword }
                'SecureString' { $body.Password = [System.Runtime.InteropServices.Marshal]::PtrToStringUni([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($KeystorePassword)) }
                'PSCredential' { $body.Password = $KeystorePassword.GetNetworkCredential().Password }
                Default { throw 'Unsupported type for -KeystorePassword.  Provide either a String, SecureString, or PSCredential.' }
            }
        }

        if ( $PSBoundParameters.ContainsKey('FriendlyName') ) {
            $body.FriendlyName = $FriendlyName
        }

        if ($IncludeChain) {
            $body.IncludeChain = $true
        }

        $body | Write-VerboseWithSecret

        $splitCertificateDataFunction = 'function Split-CertificateData {{ {0} }}' -f (Get-Command Split-CertificateData | Select-Object -ExpandProperty Definition)
    }

    process {
        $body.CertificateDN = ($Path | ConvertTo-VdcFullPath)
        $allCerts.Add(
            @{
                Body                         = $body
                SplitCertificateDataFunction = $splitCertificateDataFunction
            }
        )
    }

    end {
        Invoke-VenafiParallel -InputObject $allCerts -ScriptBlock {

            . ([scriptblock]::Create($PSItem.SplitCertificateDataFunction))

            $thisBody = $PSItem.Body
            $innerResponse = Invoke-VenafiRestMethod -Method 'Post' -UriLeaf 'certificates/retrieve' -Body $thisBody

            $out = $innerResponse | Select-Object Filename, Format, @{
                n = 'Path'
                e = { $thisBody.CertificateDN }
            },
            @{
                n = 'Error'
                e = { $_.Status }
            }

            if ( $innerResponse.CertificateData ) {

                $splitData = Split-CertificateData -CertificateData $innerResponse.CertificateData

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
                    $out | Add-Member @{'CertPem' = $splitData.CertPem }

                    if ( $thisBody.IncludePrivateKey ) {
                        $out | Add-Member @{'KeyPem' = $splitData.KeyPem }
                    }

                    if ( $thisBody.IncludeChain -and $certPem.Count -gt 1 ) {
                        $out | Add-Member @{'ChainPem' = $splitData.CertPem[1..($splitData.CertPem.Count - 1)] }
                    }
                }
            }

            $out

        } -ThrottleLimit $ThrottleLimit -ProgressTitle 'Exporting certificates'
    }
}
