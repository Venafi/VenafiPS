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
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByFile')]
    [Alias('Import-VaasCertificate')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'ByFile', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( -not (Test-Path -Path (Resolve-Path -Path $_) -PathType Leaf) ) {
                    throw "'$_' is not a valid file path"
                }

                if ((Split-Path -Path (Resolve-Path -Path $_) -Extension) -notin '.pfx', '.p12') {
                    throw "$_ is not a .p12 or .pfx file"
                }

                $true
            })]
        [Alias('FullName', 'CertificatePath')]
        [String] $Path,

        [Parameter(Mandatory, ParameterSetName = 'Pkcs12', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Pkcs8', ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [AllowEmptyString()]
        [Alias('CertificateData')]
        [String] $Data,

        [Parameter(Mandatory, ParameterSetName = 'Pkcs12')]
        [switch] $Pkcs12,

        [Parameter(Mandatory, ParameterSetName = 'Pkcs8')]
        [switch] $Pkcs8,

        [Parameter(Mandatory)]
        [psobject] $PrivateKeyPassword,

        [Parameter()]
        [int32] $ThrottleLimit = 10,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'

        Initialize-PSSodium

        $vSat = Get-VcData -Type 'VSatellite' -First
        if ( -not $vSat ) { throw 'No active VSatellites were found' }

        $pkPassString = if ( $PrivateKeyPassword -is [string] ) { $PrivateKeyPassword }
        elseif ($PrivateKeyPassword -is [securestring]) { ConvertFrom-SecureString -SecureString $PrivateKeyPassword -AsPlainText }
        elseif ($PrivateKeyPassword -is [pscredential]) { $PrivateKeyPassword.GetNetworkCredential().Password }
        else { throw 'Unsupported type for -PrivateKeyPassword.  Provide either a String, SecureString, or PSCredential.' }

        $allCerts = [System.Collections.Generic.List[hashtable]]::new()

    }

    process {

        if ( $PSBoundParameters.ContainsKey('Path') ) {
            $thisCertPath = Resolve-Path -Path $Path

            switch (Split-Path -Path $thisCertPath -Extension) {
                { $_ -in '.pfx', '.p12' } { $format = 'Pkcs12' }
            }

            if ($PSVersionTable.PSVersion.Major -lt 6) {
                $cert = Get-Content $thisCertPath -Encoding Byte
            }
            else {
                $cert = Get-Content $thisCertPath -AsByteStream
            }

            $allCerts.Add(@{
                    'CertData' = [System.Convert]::ToBase64String($cert)
                    'Format'   = $format
                }
            )
        }
        else {
            # check if Data exists since we allow null/empty in case piping from another function and data is not there
            if ( $Data ) {

                $addMe = @{
                    'Format' = $PSCmdlet.ParameterSetName
                }

                switch ($PSCmdlet.ParameterSetName) {
                    'Pkcs12' {
                        $addMe.'CertData' = $Data -replace "`r|`n|-----BEGIN CERTIFICATE-----|-----END CERTIFICATE-----"
                    }

                    'Pkcs8' {
                        $splitData = Split-CertificateData -CertificateData $Data
                        $addMe.CertPem = $splitData.CertPem
                        if ( $splitData.KeyPem ) { $addMe.KeyPem = $splitData.KeyPem }
                    }
                }

                $allCerts.Add($addMe)
            }
        }

    }

    end {
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
                switch ($allCerts[$i].Format) {
                    'Pkcs12' {
                        @{
                            'pkcs12Keystore'       = $thisCert.CertData
                            'dekEncryptedPassword' = $dekEncryptedPassword
                        }
                    }

                    'Pkcs8' {
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
