function Import-VcCertificate {
    <#
    .SYNOPSIS
    Import one or more certificates

    .DESCRIPTION
    Import one or more certificates and their private keys.  Currently PKCS12 (.pfx or .p12) is supported.

    .PARAMETER Path
    Path to a certificate file.  Provide either this or -Data.

    .PARAMETER Data
    Contents of a certificate/key to import.  Provide either this or -Path.

    .PARAMETER ThrottleLimit
    Limit the number of threads when running in parallel; the default is 100.  Applicable to PS v7+ only.

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
        [AllowNull()]
        [AllowEmptyString()]
        [Alias('CertificateData')]
        [String] $Data,

        [Parameter(Mandatory, ParameterSetName = 'Pkcs12')]
        [switch] $Pkcs12,

        [Parameter(Mandatory)]
        [psobject] $PrivateKeyPassword,

        [Parameter()]
        [int32] $ThrottleLimit = 100,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'

        if ( -not (Get-Module -Name PSSodium)) {
            Import-Module "$PSScriptRoot/../import/PSSodium/PSSodium.psd1" -Force
        }

        $vSat = Get-VcSatellite -All | Select-Object -First 1

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
            if ( $Data ) {
                $allCerts.Add(@{
                        'CertData' = $Data -replace "`r|`n|-----BEGIN CERTIFICATE-----|-----END CERTIFICATE-----"
                        'Format'   = $PSCmdlet.ParameterSetName
                    }
                )
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
                Method  = 'post'
                UriRoot = 'outagedetection/v1'
                UriLeaf = 'certificates/imports'
                Body    = @{
                    'edgeInstanceId'  = $vSat.vsatelliteId
                    'encryptionKeyId' = $vSat.encryptionKeyId
                }
                VenafiSession = $VenafiSession
            }

            switch ($allCerts[$i].Format) {
                'Pkcs12' {
                    $keystores = $allCerts[$i..($i + 99)] | ForEach-Object {
                        @{
                            'pkcs12Keystore'       = $_.CertData
                            'dekEncryptedPassword' = $dekEncryptedPassword
                        }
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
                $jobResponse.status -eq 'COMPLETED'
            )
            $jobResponse.results
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
