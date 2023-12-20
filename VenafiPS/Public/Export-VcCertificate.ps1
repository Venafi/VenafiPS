function Export-VcCertificate {
    <#
    .SYNOPSIS
    Export certificate data from TLSPC

    .DESCRIPTION
    Export certificate data in PEM format.  You can retrieve the certificate, chain, and key.

    .PARAMETER ID
    Certificate ID, also known as uuid.  Use Find-VcCertificate or Get-VcCertificate to determine the ID.
    You can pipe those functions as well.

    .PARAMETER PrivateKeyPassword
    Password required to include the private key.
    You can either provide a String, SecureString, or PSCredential.

    .PARAMETER IncludeChain
    Include the certificate chain with the exported certificate.

    .PARAMETER OutPath
    Folder path to save the certificate to.  The name of the file will be determined automatically.
    For each certificate a directory will be created in this folder with the format Name-ID.

    .PARAMETER ThrottleLimit
    Limit the number of threads when running in parallel; the default is 100.  Applicable to PS v7+ only.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    ID

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    $certId | Export-VcCertificate

    Export certificate data

    .EXAMPLE
    $certId | Export-VcCertificate -PrivateKeyPassword 'myPassw0rd!'

    Export certificate and private key data

    .EXAMPLE
    $cert | Export-VcCertificate -OutPath '~/temp'

    Get certificate data and save to a file

    .EXAMPLE
    $cert | Export-VcCertificate -IncludeChain

    Get certificate data with the certificate chain included.

    .NOTES
    This function requires the use of sodium encryption.
    .net standard 2.0 or greater is required via PS Core (recommended) or supporting .net runtime.
    On Windows, the latest Visual C++ redist must be installed.  See https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist.
    #>

    [CmdletBinding()]

    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('certificateId')]
        [string] $ID,

        [Parameter()]
        [psobject] $PrivateKeyPassword,

        [Parameter()]
        [switch] $IncludeChain,

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
        [int32] $ThrottleLimit = 100,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'

        $allCerts = [System.Collections.Generic.List[hashtable]]::new()

        if ( $PrivateKeyPassword ) {

            $params = @{
                Method       = 'Post'
                Header       = @{ 'accept' = 'application/octet-stream' }
                UriRoot      = 'outagedetection/v1'
                Body         = @{
                    'exportFormat'                = 'PEM'
                    'encryptedKeystorePassphrase' = ''
                    'certificateLabel'            = ''
                }
                FullResponse = $true
            }

            $pkPassString = if ( $PrivateKeyPassword -is [string] ) { $PrivateKeyPassword }
            elseif ($PrivateKeyPassword -is [securestring]) { ConvertFrom-SecureString -SecureString $PrivateKeyPassword -AsPlainText }
            elseif ($PrivateKeyPassword -is [pscredential]) { $PrivateKeyPassword.GetNetworkCredential().Password }
            else { throw 'Unsupported type for -PrivateKeyPassword.  Provide either a String, SecureString, or PSCredential.' }
        }
        else {
            # no need to get the entire keystore if just getting cert/chain
            $params = @{
                UriRoot      = 'outagedetection/v1'
                Body         = @{
                    format = 'PEM'
                }
                FullResponse = $true
            }

            if ( $IncludeChain ) {
                $params.Body.chainOrder = 'EE_FIRST'
            }
            else {
                $params.Body.chainOrder = 'EE_ONLY'
            }
        }

        Initialize-PSSodium
    }

    process {
        if ( $PrivateKeyPassword ) {
            $params.UriLeaf = "certificates/$id/keystore"
            $allCerts.Add(
                @{
                    InvokeParams       = $params
                    ID                 = $ID
                    PrivateKeyPassword = $pkPassString
                }
            )
        }
        else {
            $params.UriLeaf = "certificates/$id/contents"
            $allCerts.Add(
                @{
                    InvokeParams = $params
                    ID           = $ID
                }
            )

        }
    }

    end {
        if ( $PrivateKeyPassword ) {
            $currDir = $PSScriptRoot
            $sb = {

                $out = [pscustomobject] @{
                    certificateId = $PSItem.ID
                    error         = ''
                }

                $thisCert = Get-VcCertificate -id $PSItem.ID

                if ( -not $thisCert.dekHash ) {
                    $out.error = 'Private key not found'
                    return $out
                }

                Import-Module (Join-Path -Path (Split-Path $using:currDir -Parent) -ChildPath 'import/PSSodium/PSSodium.psd1') -Force

                $params = $PSItem.InvokeParams

                $publicKey = Invoke-VenafiRestMethod -UriLeaf "edgeencryptionkeys/$($thisCert.dekHash)" | Select-Object -ExpandProperty key

                $privateKeyPasswordEnc = ConvertTo-SodiumEncryptedString -Text $PSItem.PrivateKeyPassword -PublicKey $publicKey

                $params.Body.encryptedPrivateKeyPassphrase = $privateKeyPasswordEnc

                $innerResponse = Invoke-VenafiRestMethod @params

                if ($innerResponse.StatusCode -notin 200, 201, 202) {
                    $out.error = $innerResponse.StatusDescription
                    return $out
                }

                if ( -not $innerResponse.Content ) {
                    $out.error = 'No certificate data received'
                    return $out
                }

                $zipFile = New-TemporaryFile
                $unzipPath = Join-Path -Path (Split-Path -Path $zipFile -Parent) -ChildPath $PSItem.ID

                try {
                    # always save the zip file then decide to copy to the final destination or return contents
                    [IO.File]::WriteAllBytes($zipFile, $innerResponse.Content)

                    Expand-Archive -Path $zipFile -DestinationPath $unzipPath
                    $unzipFiles = Get-ChildItem -Path $unzipPath

                    if ( $using:outPath ) {
                        # copy files to final desination
                        $dest = Join-Path -Path (Resolve-Path -Path $using:OutPath) -ChildPath ('{0}-{1}' -f $thisCert.certificateName, $thisCert.certificateId)
                        $null = New-Item -Path $dest -ItemType Directory -Force
                        $unzipFiles | Copy-Item -Destination $dest -Force
                        $out | Add-Member @{'outPath' = $dest }
                    }
                    else {
                        # pull in the contents so we can provide them
                        switch ($unzipFiles) {
                            { $_.Name.EndsWith('.key') } {
                                $out | Add-Member @{'KeyPem' = Get-Content -Path $_.FullName -Raw }
                            }
                            { $_.Name.EndsWith('root-last.pem') } {

                                $certPem = @()

                                $pemLines = Get-Content -Path $_.FullName
                                for ($i = 0; $i -lt $pemLines.Count; $i++) {
                                    if ($pemLines[$i].Contains('-----BEGIN')) {
                                        $iStart = $i
                                        continue
                                    }
                                    if ($pemLines[$i].Contains('-----END')) {
                                        $thisPemLines = $pemLines[$iStart..$i]
                                        $certPem += $thisPemLines -join "`n"
                                        continue
                                    }
                                }

                                $out | Add-Member @{'CertPem' = $certPem[0] }
                                if ( $using:IncludeChain ) {
                                    $out | Add-Member @{'ChainPem' = $certPem[1..($certPem.Count - 1)] }
                                }
                            }
                        }
                    }
                    $out
                }
                finally {
                    Remove-Item -Path $unzipPath -Recurse -Force -ErrorAction SilentlyContinue
                    Remove-Item -Path $zipFile -Force -ErrorAction SilentlyContinue
                }
            }
        }
        else {
            # cert/chain only, no private key.  different api call, better performance.
            $sb = {

                $thisCert = Get-VcCertificate -id $PSItem.ID

                $params = $PSItem.InvokeParams
                $innerResponse = Invoke-VenafiRestMethod @params
                $certificateData = $innerResponse.Content

                $out = [pscustomobject] @{
                    certificateId = $PSItem.ID
                    error         = if ($innerResponse.StatusCode -notin 200, 201, 202) { $innerResponse.StatusDescription }
                }

                if ( $certificateData ) {
                    if ( $using:OutPath ) {
                        $dest = Join-Path -Path (Resolve-Path -Path $using:OutPath) -ChildPath ('{0}-{1}' -f $thisCert.certificateName, $thisCert.certificateId)
                        $null = New-Item -Path $dest -ItemType Directory -Force
                        $outFile = Join-Path -Path $dest -ChildPath ('{0}.{1}' -f $PSItem.ID, $PSItem.InvokeParams.Body.format)
                        try {
                            $sw = [IO.StreamWriter]::new($outFile, $false, [Text.Encoding]::ASCII)
                            $sw.WriteLine($certificateData)
                            Write-Verbose "Saved $outFile"
                        }
                        finally {
                            if ($null -ne $sw) { $sw.Close() }
                        }

                        $out | Add-Member @{'outPath' = $dest }
                    }
                    else {
                        $out | Add-Member @{'certificateData' = $certificateData }
                    }
                }
                $out
            }
        }

        $invokeParams = @{
            InputObject   = $allCerts
            ScriptBlock   = $sb
            ThrottleLimit = $ThrottleLimit
            ProgressTitle = 'Exporting certificates'
        }
        Invoke-VenafiParallel @invokeParams
    }
}
