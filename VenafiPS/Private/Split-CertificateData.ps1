function Split-CertificateData {
    [CmdletBinding(DefaultParameterSetName = 'Data')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [String] $Path,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Data')]
        [ValidateNotNullOrEmpty()]
        [String] $CertificateData,

        [Parameter()]
        [switch] $AsData
    )

    begin {
        $allCerts = [System.Collections.Generic.List[hashtable]]::new()
    }

    process {
        # $pemLines = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($CertificateData)).Split("`n")
        if ( $Path ) {
            $data = Get-Content -Path $Path -Raw
            # $pemLines = Get-Content -Path $Path
        }
        else {
            $data = $CertificateData
            # $pemLines = $CertificateData.Split("`n")
        }

        if ( -not $data.Contains('-----BEGIN') ) {
            # if already base64 with no headers/footers, no need to process
            $allCerts.Add(
                @{
                    CertPem = $data
                }
            )
            return
        }

        $pemLines = $data.Split("`n")
        $certPem = @()

        for ($i = 0; $i -lt $pemLines.Count; $i++) {
            if ($pemLines[$i].Contains('-----BEGIN')) {
                $iStart = $i
                continue
            }
            if ($pemLines[$i].Contains('-----END')) {

                $thisPemLines = $pemLines[$iStart..$i] -join "`n"

                if ( $pemLines[$i].Contains('KEY-----')) {
                    # $keyPem = ($thisPemLines -join "`n") -replace "`r"
                    $keyPem = $thisPemLines
                }
                else {
                    # $certPem += ($thisPemLines -join "`n") -replace "`r"
                    $certPem += $thisPemLines
                }

                continue
            }
        }

        # TODO: ensure the cert is first
        if ( $AsData ) {
            $allCerts.Add(
                @{
                    CertPem  = $certPem[0] -replace "-{5}.*?-{5}|`r|`n"
                    KeyPem   = $keyPem -replace "-{5}.*?-{5}|`r|`n"
                    ChainPem = $certPem[1..($certPem.Count - 1)] -replace "-{5}.*?-{5}|`r|`n"
                }
            )
        }
        else {
            $allCerts.Add(
                @{
                    CertPem  = $certPem[0]
                    KeyPem   = $keyPem
                    ChainPem = $certPem[1..($certPem.Count - 1)]
                }
            )
        }
    }

    end {
        $allCerts
    }
}