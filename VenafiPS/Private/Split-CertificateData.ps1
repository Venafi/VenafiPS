function Split-CertificateData {

    <#
    .SYNOPSIS
        Convert PEM data into its cert, key, and chain parts
    #>
    
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
        if ( $CertificateData -match '-----BEGIN' ) {
            $pemLines = $CertificateData.Split("`n")
        }
        else {
            $pemLines = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($CertificateData)).Split("`n")
        }

        $certPem = @()

        for ($i = 0; $i -lt $pemLines.Count; $i++) {
            if ($pemLines[$i].Contains('-----BEGIN')) {
                $iStart = $i
                continue
            }
            if ($pemLines[$i].Contains('-----END')) {
                $thisPemLines = $pemLines[$iStart..$i]
                if ( $pemLines[$i].Contains('KEY-----')) {
                    $keyPem = ($thisPemLines -join "`n") -replace "`r"
                }
                else {
                    $certPem += ($thisPemLines -join "`n") -replace "`r"
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