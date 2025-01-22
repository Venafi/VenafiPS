function Import-VcCertificate {
    <#
    .SYNOPSIS
    Import one or more certificates

    .DESCRIPTION
    Import one or more certificates and their private keys.
    Currently PKCS #8 (.pem) and PKCS #12 (.pfx or .p12) are supported.

    .PARAMETER Path
    Path to a certificate file or folder with multiple certificates.  Provide either this or -Data.

    .PARAMETER Data
    Contents of a certificate/key to import.  Provide either this or -Path.

    .PARAMETER PKCS8
    Provided -Data is in PKCS #8 format

    .PARAMETER PKCS12
    Provided -Data is in PKCS #12 format

    .PARAMETER Format
    Specify the format provided in -Data.
    This will replace -PKCS8 and -PKCS12 in a future release.

    .PARAMETER PrivateKeyPassword
    Password the private key was encrypted with

    .PARAMETER PrivateKeyPasswordCredential
    Password the private key was encrypted with, in PSCredential type.
    This is used with -Format to pipe from Export-VcCertificate.

    .PARAMETER ThrottleLimit
    Limit the number of threads when running in parallel; the default is 10.  Applicable to PS v7+ only.
    100 keystores will be imported at a time so it's less important to have a very high throttle limit.

    .PARAMETER Force
    Force installation of PSSodium if not already installed

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .EXAMPLE
    Import-VcCertificate -CertificatePath c:\www.VenafiPS.com.pfx

    Import a certificate/key

    .EXAMPLE
    Export-VdcCertificate -Path '\ved\policy\my.cert.com' -Pkcs12 -PrivateKeyPassword 'myPassw0rd!' | Import-VcCertificate -VenafiSession $vaas_key

    Export from TLSPDC and import into TLSPC.
    As $VenafiSession can only point to one platform at a time, in this case TLSPDC, the session needs to be overridden for the import.

    .EXAMPLE
    Find-VdcCertificate -Path '\ved\policy\certs' -Recursive | Export-VdcCertificate -Pkcs12 -PrivateKeyPassword 'myPassw0rd!' | Import-VcCertificate -VenafiSession $vaas_key

    Bulk export from TLSPDC and import into TLSPC.
    As $VenafiSession can only point to one platform at a time, in this case TLSPDC, the session needs to be overridden for the import.

    .EXAMPLE
    Find-VcCertificate | Export-VcCertificate -PrivateKeyPassword 'secretPassword#' -PKCS12 | Import-VcCertificate -VenafiSession $tenant2_key

    Export from 1 TLSPC tenant and import to another

    .INPUTS
    Data

    .LINK
    https://developer.venafi.com/tlsprotectcloud/reference/certificates_import

    .NOTES
    This function requires the use of sodium encryption.
    .net standard 2.0 or greater is required via PS Core (recommended) or supporting .net runtime.
    On Windows, the latest Visual C++ redist must be installed.  See https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByFile')]
    [Alias('Import-VaasCertificate')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ByFile')]
        [ValidateNotNullOrEmpty()]
        [Alias('FullName', 'CertificatePath', 'FilePath')]
        [String] $Path,

        [Parameter(Mandatory, ParameterSetName = 'PKCS12', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'PKCS8', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Format', ValueFromPipelineByPropertyName)]
        # [AllowNull()]
        # [AllowEmptyString()]
        [Alias('certificateData')]
        [String] $Data,

        [Parameter(Mandatory, ParameterSetName = 'PKCS8')]
        [switch] $PKCS8,

        [Parameter(Mandatory, ParameterSetName = 'PKCS12')]
        [switch] $PKCS12,

        [Parameter(Mandatory, ParameterSetName = 'Format', ValueFromPipelineByPropertyName)]
        [ValidateSet('PKCS8', 'PKCS12')]
        [String] $Format,

        [Parameter(Mandatory, ParameterSetName = 'PKCS8')]
        [Parameter(Mandatory, ParameterSetName = 'PKCS12')]
        [Parameter(Mandatory, ParameterSetName = 'ByFile')]
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

        [Parameter(Mandatory, ParameterSetName = 'Format', ValueFromPipelineByPropertyName)]
        [pscredential] $PrivateKeyPasswordCredential,
        
        [Parameter()]
        [int32] $ThrottleLimit = 10,

        [Parameter()]
        [switch] $Force,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {

        Test-VenafiSession $PSCmdlet.MyInvocation

        Initialize-PSSodium -Force:$Force

        $vSat = Get-VcData -Type 'VSatellite' -First
        if ( -not $vSat ) { throw 'No active VSatellites were found' }
        
        if ( $PrivateKeyPassword ) {
            $pkPassString = ConvertTo-PlaintextString -InputObject $PrivateKeyPassword
        }

        $allCerts = [System.Collections.Generic.List[hashtable]]::new()
        
    }
    
    process {

        if ( $PSCmdlet.ParameterSetName -eq 'ByFile' ) {
            $resolvedPath = Resolve-Path -Path $Path -ErrorAction Stop
            $files = if (Test-Path -Path $resolvedPath -PathType Container) {
                Get-ChildItem -Path $resolvedPath -File | Select-Object -ExpandProperty FullName
            }
            else {
                @($resolvedPath)
            }
            
            foreach ($file in $files) {
               
                Write-Verbose "Processing $file"

                switch ([System.IO.Path]::GetExtension($file)) {
                    { $_ -in '.pfx', '.p12' } {
                        if ($PSVersionTable.PSVersion.Major -lt 6) {
                            $cert = Get-Content $file -Encoding Byte
                        }
                        else {
                            $cert = Get-Content $file -AsByteStream
                        }

                        $allCerts.Add(@{
                                'CertData' = [System.Convert]::ToBase64String($cert)
                                'Format'   = 'PKCS12'
                            }
                        )
                    }

                    '.pem' {
                        $split = Split-CertificateData -CertificateData (Get-Content $file -Raw)

                        # we need the private key so check for it in the pem
                        if ( $split.KeyPem ) {
                            $allCerts.Add(@{
                                    'CertPem' = $split.CertPem
                                    'KeyPem'  = $split.KeyPem
                                    'Format'  = 'PKCS8'
                                }
                            )
                        }
                        else {
                            Write-Error "Private key not found in $file"
                        }
                    }
    
                    default {
                        Write-Verbose "$file is not a Pkcs8 or Pkcs12 certificate"
                    }
                }
            }
        }
        else {
            # check if Data exists since we allow null/empty in case piping from another function and data is not there
            if ( $Data ) {

                $addMe = @{
                    'Format' = ''
                }

                if ( $Format ) {
                    $addMe.Format = $Format
                    # privatekeypasswordcredential might have been provided via pipeline so this must be in process block
                    $pkPassString = ConvertTo-PlaintextString -InputObject $PrivateKeyPasswordCredential
                }
                else {
                    $addMe.Format = $PSCmdlet.ParameterSetName
                }

                switch ($addMe.Format) {
                    'PKCS12' {
                        $addMe.'CertData' = $Data -replace "`r|`n|-----BEGIN CERTIFICATE-----|-----END CERTIFICATE-----"
                    }

                    'PKCS8' {
                        $splitData = Split-CertificateData -CertificateData $Data
                        $addMe.CertPem = $splitData.CertPem
                        if ( $splitData.KeyPem ) {
                            $addMe.KeyPem = $splitData.KeyPem
                        }
                        else {
                            Write-Error "Private key not found in provided data"
                            return
                        }
                    }
                }

                $allCerts.Add($addMe)
            }
        }

    }

    end {
        if ( $allCerts.Count -eq 0 ) { return }

        Write-Verbose ('Importing {0} certificates' -f $allCerts.Count)
        Write-Verbose ($allCerts | ConvertTo-Json)

        $importList = [System.Collections.Generic.List[hashtable]]::new()

        $dekEncryptedPassword = ConvertTo-SodiumEncryptedString -Text $pkPassString -PublicKey $vSat.encryptionKey

        # rebuild invoke params as the payload can contain multiple keys at once
        # max 100 keys at a time
        for ($i = 0; $i -lt $allCerts.Count; $i += 100) {

            $params = @{
                Method        = 'post'
                UriRoot       = 'outagedetection/v1'
                UriLeaf       = 'certificates/imports'
                Body          = @{
                    'edgeInstanceId'  = $vSat.vsatelliteId
                    'encryptionKeyId' = $vSat.encryptionKeyId
                }
                VenafiSession = $VenafiSession
            }

            $keystores = foreach ($thisCert in $allCerts[$i..($i + 99)]) {
                switch ($thisCert.Format) {
                    'PKCS12' {
                        @{
                            'pkcs12Keystore'       = $thisCert.CertData
                            'dekEncryptedPassword' = $dekEncryptedPassword
                        }
                    }

                    'PKCS8' {
                        $thisKeystore = @{
                            'certificate'          = $thisCert.CertPem
                            'dekEncryptedPassword' = $dekEncryptedPassword
                        }
                        if ( $thisCert.KeyPem ) { $thisKeystore.passwordEncryptedPrivateKey = $thisCert.KeyPem }
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
                $jobResponse = Invoke-VenafiRestMethod -UriRoot 'outagedetection/v1' -UriLeaf "certificates/imports/$($requestResponse.id)"
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
            VenafiSession = $VenafiSession
        }
        $invokeResponse = Invoke-VenafiParallel @invokeParams

        $invokeResponse | Select-Object -Property fingerprint, status, reason
    }
}
