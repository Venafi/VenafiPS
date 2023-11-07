function Split-CertificateData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String] $CertificateData
    )

    begin {
        $allCerts = [System.Collections.Generic.List[hashtable]]::new()
    }

    process {
        $pemLines = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($CertificateData)).Split("`n")

        $certPem = @()

        for ($i = 0; $i -lt $pemLines.Count; $i++) {
            if ($pemLines[$i].Contains('-----BEGIN')) {
                $iStart = $i
                continue
            }
            if ($pemLines[$i].Contains('-----END')) {
                $thisPemLines = $pemLines[$iStart..$i]
                if ( $pemLines[$i].Contains('KEY-----')) {
                    $keyPem = $thisPemLines | Join-String
                }
                else {
                    $certPem += $thisPemLines | Join-String
                }
                continue
            }
        }

        $allCerts.Add(
            @{
                CertPem  = $certPem[0]
                KeyPem   = $keyPem
                ChainPem = $certPem[1..($certPem.Count - 1)]
            }
        )
    }

    end {
        $allCerts
    }
}