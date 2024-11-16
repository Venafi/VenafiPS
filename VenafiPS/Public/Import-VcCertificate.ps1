function Import-VcCertificate {
    <#
    .SYNOPSIS
    Import one or more certificates

    .DESCRIPTION
    Import one or more certificates and their private keys.  Currently PKCS #8 and PKCS #12 (.pfx or .p12) are supported.

    .PARAMETER Path
    Path to a certificate file.  Provide either this or -Data.

    .PARAMETER Data
    Contents of a certificate/key to import.  Provide either this or -Path.

    .PARAMETER Pkcs8
    Provided -Data is in PKCS #8 format

    .PARAMETER Pkcs12
    Provided -Data is in PKCS #12 format

    .PARAMETER PrivateKeyPassword
    Password the private key was encrypted with

    .PARAMETER ThrottleLimit
    Limit the number of threads when running in parallel; the default is 10.  Applicable to PS v7+ only.
    100 keystores will be imported at a time so it's less important to have a very high throttle limit.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .EXAMPLE
    Import-VcCertificate -CertificatePath c:\www.VenafiPS.com.pfx

    Import a certificate/key

    .EXAMPLE
    $p12 = Export-VdcCertificate -Path '\ved\policy\my.cert.com' -Pkcs12 -PrivateKeyPassword 'myPassw0rd!'
    $p12 | Import-VcCertificate -Pkcs12 -PrivateKeyPassword 'myPassw0rd!' -VenafiSession $vaas_key

    Export from TLSPDC and import into TLSPC.
    As $VenafiSession can only point to one platform at a time, in this case TLSPDC, the session needs to be overridden for the import.

    .EXAMPLE
    $p12 = Find-VdcCertificate -Path '\ved\policy\certs' -Recursive | Export-VdcCertificate -Pkcs12 -PrivateKeyPassword 'myPassw0rd!'
    $p12 | Import-VcCertificate -Pkcs12 -PrivateKeyPassword 'myPassw0rd!' -VenafiSession $vaas_key

    Bulk export from TLSPDC and import into TLSPC.
    As $VenafiSession can only point to one platform at a time, in this case TLSPDC, the session needs to be overridden for the import.

    .INPUTS
    Path, Data

    .LINK
    https://developer.venafi.com/tlsprotectcloud/reference/certificates_import

    .NOTES
    This function requires the use of sodium encryption.
    .net standard 2.0 or greater is required via PS Core (recommended) or supporting .net runtime.
    On Windows, the latest Visual C++ redist must be installed.  See https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByPath')]
    [Alias('Import-VaasCertificate')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ByPath', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'ByPathWithKey', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( -not (Test-Path -Path (Resolve-Path -Path $_)) ) {
                    throw "'$_' is not a valid path"
                }

                # if ([System.IO.Path]::GetExtension((Resolve-Path -Path $_)) -notin '.pfx', '.p12') {
                #     throw "$_ is not a .p12 or .pfx file"
                # }

                $true
            })]
        [Alias('FullName', 'CertificatePath')]
        [String] $Path,

        [Parameter(Mandatory, ParameterSetName = 'Pkcs12', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Pkcs8', ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [AllowEmptyString()]
        [Alias('CertificateData')]
        [psobject] $Data,

        [Parameter(Mandatory, ParameterSetName = 'Pkcs12')]
        [switch] $Pkcs12,

        [Parameter(Mandatory, ParameterSetName = 'Pkcs8')]
        [switch] $Pkcs8,

        [Parameter(Mandatory, ParameterSetName = 'Pkcs12')]
        [Parameter(Mandatory, ParameterSetName = 'Pkcs8')]
        [Parameter(Mandatory, ParameterSetName = 'ByPathWithKey')]
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

        [Parameter(ParameterSetName = 'Pkcs12')]
        [Parameter(ParameterSetName = 'Pkcs8')]
        [Parameter(ParameterSetName = 'ByPathWithKey')]
        [int32] $ThrottleLimit = 10,

        [Parameter()]
        [string] $Application,

        [Parameter()]
        [string] $Tag,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'

        # if ( $PrivateKeyPassword ) {
        #     # private key import is a different endpoint with very different prereqs
        #     Initialize-PSSodium

        #     $vSat = Get-VcData -Type 'VSatellite' -First
        #     if ( -not $vSat ) { throw 'No active VSatellites were found' }

        #     $pkPassString = $PrivateKeyPassword | ConvertTo-PlaintextString
        # }

        $allCerts = [System.Collections.Generic.List[hashtable]]::new()

    }

    process {

        # $certItems = if ( $PSBoundParameters.ContainsKey('Path') ) {
        #     $isPath = $true
        #     $resolvedPath = Resolve-Path -Path $Path

        #     # see if we're working with a file or a path
        #     # if a path, enumerate all the files in the directory
        #     if ( Test-Path -Path $resolvedPath -PathType Container ) {
        #         @(Get-ChildItem -Path $resolvedPath -File | Select-Object -ExpandProperty FullName)
        #     }
        #     else {
        #         @($resolvedPath)
        #     }
        # }
        # else {
        #     @($Data)
        # }

        # foreach ($certItem in $certItems) {

        #     $thisCertData = $thisKeyData = $thisChainData = $thisFormat = $null

        #     if ( $isPath -and ([System.IO.Path]::GetExtension($certItem) -notin '.pfx', '.p12', '.crt', '.cer', '.pem') ) {
        #         Write-Verbose "Unsupported file type: $certItem"
        #         continue
        #     }

        #     Write-Verbose "Processing $certPath"

        #     try {
        #         if ( $PrivateKeyPassword ) {
        #             $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certItem, $PrivateKeyPassword, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
        #         }
        #         else {
        #             $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certItem)
        #         }

        #         if ( $cert ) {
        #             $thisCertData = [System.Convert]::ToBase64String( $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12))

        #             if ( $cert.HasPrivateKey ) {

        #             }
        #         }

        #         $thisFormat = 'Pkcs12'
        #     }
        #     catch {
        #         Write-Error "Failed to import $certPath, $_"
        #     }
        #     # switch ([System.IO.Path]::GetExtension($certItem)) {
        #     #     { $_ -in '.pfx', '.p12', '.crt', '.cer', '.pem' } {

        #     #     }
        #     # }
        #     if ( -not $thisCertData ) {
        #         continue
        #     }

        #     $allCerts.Add(
        #         @{
        #             'CertData'  = $thisCertData
        #             'Format'    = $thisFormat
        #             'Path'      = $certPath
        #             'KeyData'   = $thisKeyData
        #             'ChainData' = $thisChainData
        #         }
        #     )
        # }

        if ( $PSBoundParameters.ContainsKey('Path') ) {
            $resolvedPath = Resolve-Path -Path $Path

            # see if we're working with a file or a path
            # if a path, enumerate all the files in the directory
            $certPaths = if ( Test-Path -Path $resolvedPath -PathType Container ) {
                @(Get-ChildItem -Path $resolvedPath -File | Select-Object -ExpandProperty FullName)
            }
            else {
                @($resolvedPath)
            }

            foreach ($certPath in $certPaths) {

                $thisCertData = $thisKeyData = $thisChainData = $thisFormat = $null

                switch ([System.IO.Path]::GetExtension($certPath)) {
                    { $_ -in '.pfx', '.p12', '.crt', '.cer', '.pem' } {

                        Write-Verbose "Processing $certPath"


                        try {
                            $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certPath, $PrivateKeyPassword, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)

                            if ( $cert ) {
                                $thisCertData = [System.Convert]::ToBase64String( $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12))

                                if ( $cert.HasPrivateKey ) {

                                }
                            }

                            $thisFormat = 'Pkcs12'
                        }
                        catch {
                            Write-Error "Failed to import $certPath, $_"
                        }
                    }

                    { $_ -in '.pem' } {
                        $certData = Get-Content -Path $certPath -Raw
                        $splitData = Split-CertificateData -CertificateData $certData
                        $thisCertData = $splitData.CertPem
                        $thisKeyData = $splitData.KeyPem
                        $thisChainData = $splitData.ChainPem
                        $thisFormat = 'Pkcs8'

                    }
                    default {
                        Write-Verbose "Unsupported file type: $certPath"
                    }
                }

                # make sure we have cert data to add
                if ( -not $thisCertData ) {
                    continue
                }

                $allCerts.Add(
                    @{
                        'CertData'  = $thisCertData
                        'Format'    = $thisFormat
                        'Path'      = $certPath
                        'KeyData'   = $thisKeyData
                        'ChainData' = $thisChainData
                    }
                )
            }
        }
        else {
            # check if Data exists since we allow null/empty in case piping from another function and data is not there
            if ( $Data ) {

                $thisFormat = $PSCmdlet.ParameterSetName

                # $addMe = @{
                #     'Format' = $PSCmdlet.ParameterSetName
                # }

                switch ($PSCmdlet.ParameterSetName) {
                    'Pkcs12' {
                        # $addMe.'CertData' = $Data -replace "-{5}.*?-{5}|`r|`n"
                        $thisCertData = $Data -replace "-{5}.*?-{5}|`r|`n"
                    }

                    'Pkcs8' {
                        $splitData = Split-CertificateData -CertificateData $Data
                        $thisCertData = $splitData.CertPem
                        $thisKeyData = $splitData.KeyPem
                        $thisChainData = $splitData.ChainPem
                        # $addMe.CertPem = $splitData.CertPem
                        # if ( $splitData.KeyPem ) { $addMe.KeyPem = $splitData.KeyPem }
                    }
                }

                # $allCerts.Add($addMe)
            }
            $allCerts.Add(
                @{
                    'CertData'  = $thisCertData
                    'Format'    = $thisFormat
                    'Path'      = $certPath
                    'KeyData'   = $thisKeyData
                    'ChainData' = $thisChainData
                }
            )
        }

    }

    end {

        # if ( -not $PrivateKeyPassword ) {

        # different endpoint to import just end entity certificates

        $params = @{
            Method  = 'Post'
            UriRoot = 'outagedetection/v1'
            UriLeaf = 'certificates'
        }

        # get data in the needed format before sending through batching
        # at this point we're only importing certs without keys

        $certOnly = [System.Collections.Generic.List[hashtable]]::new()

        for ($i = $allCerts.Count - 1; $i -ge 0 ; $i--) {
            if ( $allCerts[$i].Format -eq 'Pkcs8' -and -not $allCerts[$i].KeyData ) {
                $certOnly.Add(
                    @{
                        applicationIds     = if ($Application) { @($Application) }
                        certificate        = $allCerts[$i].CertData
                        issuerCertificates = if ( $allCerts[$i].ChainData ) { $allCerts[$i].ChainData }
                    }
                )
                $allCerts.RemoveAt($i)
            }
        }

        # $certOnly = $allCerts | Where-Object { $_.Format -eq 'Pkcs8' -and -not $_.KeyData } |
        # $certOnly | Select-Object `
        # @{'n' = 'applicationIds'; 'e' = { If ($Application) { , ($Application) } } },
        # @{'n' = 'certificate'; 'e' = { $_.CertData } },
        # @{'n' = 'issuerCertificates'; 'e' = { if ( $_.ChainData) { $_.ChainData } } }

        $certOnly | Select-VenBatch -Activity 'Importing certificates' -BatchSize 1000 -TotalCount $certOnly.Count | ForEach-Object {
            $params.Body = @{
                "certificates"      = @($_)
                'overrideBlocklist' = $true
            }

            $response = Invoke-VenafiRestMethod @params
            $response
            # $response.certificateInformations | Select-Object fingerprint
        }

        # after importing certs only, see if there's anything left
        # if so, let's keep going otherwise stop here
        if ( $allCerts.Count -eq 0 ) {
            return
        }

        $importList = [System.Collections.Generic.List[hashtable]]::new()

        # private key import is a different endpoint with very different prereqs
        $vSat = Get-VcData -Type 'VSatellite' -First
        if ( -not $vSat ) { throw 'No active VSatellites were found' }

        Initialize-PSSodium

        if ( -not $PrivateKeyPassword ) {
            throw 'PrivateKeyPassword is required when importing a private key'
        }

        $pkPassString = $PrivateKeyPassword | ConvertTo-PlaintextString

        $dekEncryptedPassword = ConvertTo-SodiumEncryptedString -Text $pkPassString -PublicKey $vSat.encryptionKey

        # rebuild invoke params as the payload can contain multiple keys at once
        # max 100 keys at a time
        for ($i = 0; $i -lt $allCerts.Count; $i += 100) {

            $params = @{
                Method  = 'post'
                UriRoot = 'outagedetection/v1'
                UriLeaf = 'certificates/imports'
                Body    = @{
                    'edgeInstanceId'  = $vSat.vsatelliteId
                    'encryptionKeyId' = $vSat.encryptionKeyId
                }
                # VenafiSession = $VenafiSession
            }

            $keystores = foreach ($thisCert in $allCerts[$i..($i + 99)]) {
                switch ($allCerts[$i].Format) {
                    'Pkcs12' {
                        @{
                            'pkcs12Keystore'       = $thisCert.CertData
                            'dekEncryptedPassword' = $dekEncryptedPassword
                        }
                    }

                    'Pkcs8' {
                        $thisKeystore = @{
                            'certificate'          = $thisCert.CertData
                            'dekEncryptedPassword' = $dekEncryptedPassword
                        }
                        if ( $thisCert.KeyData ) { $thisKeystore.passwordEncryptedPrivateKey = $thisCert.KeyData }
                        $thisKeystore
                    }
                }
            }

            $params.Body.importInformation = @($keystores)
            $importList.Add($params)
        }

        $sb = {
            $params = $PSItem

            $requestResponse = Invoke-VenafiRestMethod @params
            do {
                Write-Verbose "checking job status for id $($requestResponse.id)"
                $jobResponse = invoke-VenafiRestMethod -UriRoot 'outagedetection/v1' -UriLeaf "certificates/imports/$($requestResponse.id)"
                Start-Sleep 2
            } until (
                $jobResponse.status -in 'COMPLETED', 'FAILED'
            )

            if ( $jobResponse.status -eq 'COMPLETED' ) {
                $jobResponse.results
            }
            else {
                # importing only 1 keycert that fails does not give us any results to return to the user :(
                throw 'Import failed'
            }
        }

        $invokeParams = @{
            InputObject   = $importList
            ScriptBlock   = $sb
            ThrottleLimit = $ThrottleLimit
            ProgressTitle = 'Importing certificates'
        }
        $invokeResponse = Invoke-VenafiParallel @invokeParams

        $invokeResponse | Select-Object -Property fingerprint, status, reason
    }
}
