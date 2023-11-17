function Export-VdcCertificate {
    <#
    .SYNOPSIS
    Expoort certificate data from TLSPDC

    .DESCRIPTION
    Export certificate data

    .PARAMETER Path
    Full path to the certificate

    .PARAMETER Base64
    Provide output in Base64 format.  This is the default if no format is provided.

    .PARAMETER Pkcs7
    Provide output in PKCS #7 format

    .PARAMETER Pkcs8
    Provide output in PKCS #8 format

    .PARAMETER Der
    Provide output in DER format

    .PARAMETER Pkcs12
    Provide output in PKCS #12 format.  Requires a value for PrivateKeyPassword.

    .PARAMETER Jks
    Provide output in JKS format.  Requires a value for FriendlyName.

    .PARAMETER OutPath
    Folder path to save the certificate/key to.  The name of the file will be determined automatically.

    .PARAMETER IncludeChain
    Include the certificate chain with the exported certificate.
    The end entity will be first and the root last.

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

    Get certificate data in Base64 format, the default

    .EXAMPLE
    $cert | Export-VdcCertificate -'PKCS7' -OutPath 'c:\temp'

    Get certificate data in a specific format and save to a file

    .EXAMPLE
    $cert | Export-VdcCertificate -'PKCS7' -IncludeChain

    Get one or more certificates with the certificate chain included

    .EXAMPLE
    $cert | Export-VdcCertificate -'PKCS12' -PrivateKeyPassword 'mySecretPassword!'

    Get one or more certificates with private key included

    .EXAMPLE
    $cert | Export-VdcCertificate -'PKCS8' -PrivateKeyPassword 'mySecretPassword!' -OutPath '~/temp'

    Save certificate info to a file.  PKCS8 with private key will save 3 files, .pem (cert+key), .pem.cer (cert only), and .pem.key (key only)

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
        [Parameter(Mandatory, ParameterSetName = 'Pkcs12')]
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

        $body.IncludePrivateKey = $PSBoundParameters.ContainsKey('PrivateKeyPassword')

        if ( $body.IncludePrivateKey ) {

            $body.Password = if ( $PrivateKeyPassword -is [string] ) { $PrivateKeyPassword }
            elseif ($PrivateKeyPassword -is [securestring]) { ConvertFrom-SecureString -SecureString $PrivateKeyPassword -AsPlainText }
            elseif ($PrivateKeyPassword -is [pscredential]) { $PrivateKeyPassword.GetNetworkCredential().Password }
            else { throw 'Unsupported type for -PrivateKeyPassword.  Provide either a String, SecureString, or PSCredential.' }

        }

        if ( $PSBoundParameters.ContainsKey('KeystorePassword') ) {
            $body.Format = 'JKS'
            $body.KeystorePassword = if ( $KeystorePassword -is [string] ) { $KeystorePassword }
            elseif ($KeystorePassword -is [securestring]) { ConvertFrom-SecureString -SecureString $KeystorePassword -AsPlainText }
            elseif ($KeystorePassword -is [pscredential]) { $KeystorePassword.GetNetworkCredential().Password }
            else { throw 'Unsupported type for -KeystorePassword.  Provide either a String, SecureString, or PSCredential.' }
        }

        if ( $PSBoundParameters.ContainsKey('FriendlyName') ) {
            $body.FriendlyName = $FriendlyName
        }

        if ($IncludeChain) {
            $body.IncludeChain = $true
        }

        $body | Write-VerboseWithSecret

        # function not available in parallel jobs, use this workaround to pass it in via InputObject
        $splitCertificateDataFunction = 'function Split-CertificateData {{ {0} }}' -f (Get-Command Split-CertificateData | Select-Object -ExpandProperty Definition)
    }

    process {
        $body.CertificateDN = ($Path | ConvertTo-VdcFullPath)

        $allCerts.Add(
            @{
                Body                         = $body.Clone()
                SplitCertificateDataFunction = $splitCertificateDataFunction
            }
        )
    }

    end {
        Invoke-VenafiParallel -InputObject $allCerts -ScriptBlock {

            . ([scriptblock]::Create($PSItem.SplitCertificateDataFunction))

            $thisBody = $PSItem.Body

            try {
                $innerResponse = Invoke-VenafiRestMethod -Method 'Post' -UriLeaf 'certificates/retrieve' -Body $thisBody
            }
            catch {
                try {
                    # key not available, get just the cert
                    if ( $_.ToString() -like '*failed to lookup private key*') {

                        # we can't have a p12 without a private key
                        if ( $thisBody.Format -eq 'PKCS #12' ) {
                            throw $_
                        }

                        $thisBody.IncludePrivateKey = $false
                        $thisBody.Password = $null
                        $innerResponse = Invoke-VenafiRestMethod -Method 'Post' -UriLeaf 'certificates/retrieve' -Body $thisBody
                    }
                }
                catch {
                    return [pscustomobject]@{
                        'Path'            = $thisBody.CertificateDN
                        'Error'           = $_
                        'CertificateData' = $null
                    }
                }
            }

            $out = $innerResponse | Select-Object Filename, Format, @{
                n = 'Path'
                e = { $thisBody.CertificateDN }
            },
            @{
                n = 'Error'
                e = { $_.Status }
            }, CertificateData

            if ( $innerResponse.CertificateData ) {

                if ( $thisBody.Format -in 'Base64', 'Base64 (PKCS#8)' ) {
                    $splitData = Split-CertificateData -CertificateData $innerResponse.CertificateData
                }

                if ( $using:OutPath ) {

                    $out = $out | Select-Object -Property * -ExcludeProperty CertificateData

                    # write the file with the filename provided
                    $outFile = Join-Path -Path (Resolve-Path -Path $using:OutPath) -ChildPath ($innerResponse.FileName.Trim('"'))
                    $bytes = [Convert]::FromBase64String($innerResponse.CertificateData)
                    [IO.File]::WriteAllBytes($outFile, $bytes)

                    Write-Verbose "Saved $outFile"

                    $out | Add-Member @{'OutPath' = @($outFile) }

                    if ( $thisBody.Format -in 'Base64 (PKCS#8)' -and $thisBody.IncludePrivateKey) {
                        # outFile will be .pem with cert and key
                        # write out the individual files as well
                        try {
                            $crtFile = $outFile.Replace('.pem', '.crt')

                            $sw = [IO.StreamWriter]::new($crtFile, $false, [Text.Encoding]::ASCII)
                            $sw.WriteLine($splitData.CertPem)
                            Write-Verbose "Saved $crtFile"

                            $out.OutPath += $crtFile
                        }
                        finally {
                            if ($null -ne $sw) { $sw.Close() }
                        }

                        if ( $thisBody.IncludePrivateKey ) {
                            try {
                                $keyFile = $outFile.Replace('.pem', '.key')

                                $sw = [IO.StreamWriter]::new($keyFile, $false, [Text.Encoding]::ASCII)
                                $sw.WriteLine($splitData.KeyPem)
                                Write-Verbose "Saved $keyFile"

                                $out.OutPath += $keyFile
                            }
                            finally {
                                if ($null -ne $sw) { $sw.Close() }
                            }
                        }
                    }
                }
                else {
                    if ( $thisBody.Format -in 'Base64', 'Base64 (PKCS#8)' ) {

                        $out | Add-Member @{'CertPem' = $splitData.CertPem }

                        if ( $thisBody.IncludePrivateKey ) {
                            $out | Add-Member @{'KeyPem' = $splitData.KeyPem }
                        }

                        if ( $thisBody.IncludeChain -and $splitData.ChainPem ) {
                            $out | Add-Member @{'ChainPem' = $splitData.ChainPem }
                        }
                    }
                }
            }

            $out

        } -ThrottleLimit $ThrottleLimit -ProgressTitle 'Exporting certificates'
    }
}
