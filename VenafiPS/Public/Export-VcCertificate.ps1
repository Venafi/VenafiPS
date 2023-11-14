function Export-VcCertificate {
    <#
    .SYNOPSIS
    Export certificate data from TLSPC

    .DESCRIPTION
    Export certificate data in PEM format.  You can retrieve the certificate, chain, and key.

    .PARAMETER ID
    Full path to the certificate

    .PARAMETER PrivateKeyPassword
    Password required to include the private key.
    You can either provide a String, SecureString, or PSCredential.

    .PARAMETER IncludeChain
    Include the certificate chain with the exported certificate.

    .PARAMETER OutPath
    Folder path to save the certificate to.  The name of the file will be determined automatically.

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
        [int] $ThrottleLimit = 100,

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
            $sb = {

                $out = [pscustomobject] @{
                    certificateId = $PSItem.ID
                    error         = ''
                }

                Import-Module (Join-Path -Path (Split-Path $using:thisDir -Parent) -ChildPath 'import/PSSodium/PSSodium.psd1') -Force

                $params = $PSItem.InvokeParams

                $thisCert = Get-VcCertificate -id $PSItem.ID

                if ( -not $thisCert.dekHash ) {
                    $out.error = 'Private key not found'
                    return $out
                }

                $publicKey = Invoke-VenafiRestMethod -UriLeaf "edgeencryptionkeys/$($thisCert.dekHash)" | Select-Object -ExpandProperty key

                $privateKeyPasswordEnc = ConvertTo-SodiumEncryptedString -Text $PSItem.PrivateKeyPassword -PublicKey $publicKey

                $params.Body.encryptedPrivateKeyPassphrase = $privateKeyPasswordEnc

                $innerResponse = Invoke-VenafiRestMethod @params

                if ( -not $innerResponse.Content ) { return }

                $zipFile = New-TemporaryFile
                $unzipPath = Join-Path -Path (Split-Path -Path $zipFile -Parent) -ChildPath $PSItem.ID

                try {
                    # always save the zip file then decide to copy to the final destination or return contents
                    [IO.File]::WriteAllBytes($zipFile, $innerResponse.Content)

                    $unzipFiles = Expand-Archive -Path $zipFile -DestinationPath $unzipPath -PassThru

                    if ($innerResponse.StatusCode -notin 200, 201, 202) {
                        $out.error = $innerResponse.StatusDescription
                        return $out
                    }

                    if ( $using:outPath ) {
                        # copy files to final desination
                        $outPath = Resolve-Path -Path $using:OutPath
                        $unzipFiles | Copy-Item -Destination $outPath -Force
                        $out | Add-Member @{'outPath' = $outPath }
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
                                        $certPem += $thisPemLines | Join-String
                                        continue
                                    }
                                }

                                $out | Add-Member @{'CertPem' = $certPem[0] }
                                $out | Add-Member @{'ChainPem' = $certPem[1..($certPem.Count - 1)] }
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
            # cert/chain only, no private key.  different api call.
            $sb = {
                $params = $PSItem.InvokeParams
                $innerResponse = Invoke-VenafiRestMethod @params
                $certificateData = $innerResponse.Content

                $out = [pscustomobject] @{
                    certificateId = $PSItem.ID
                    error         = if ($innerResponse.StatusCode -notin 200, 201, 202) { $innerResponse.StatusDescription }
                }

                if ( $certificateData ) {
                    if ( $using:OutPath ) {
                        # if ( $certificateData ) {
                        $outFile = Join-Path -Path (Resolve-Path -Path $using:OutPath) -ChildPath ('{0}.{1}' -f $PSItem.ID, $PSItem.InvokeParams.Body.format)
                        try {
                            $sw = [IO.StreamWriter]::new($outFile, $false, [Text.Encoding]::ASCII)
                            $sw.WriteLine($certificateData)
                            Write-Verbose "Saved $outFile"
                        }
                        finally {
                            if ($null -ne $sw) { $sw.Close() }
                        }

                        $out | Add-Member @{'outFile' = $outFile }
                        # }
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
