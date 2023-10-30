function Export-VcCertificate {
    <#
    .SYNOPSIS
    Expoort certificate data from TLSPC

    .DESCRIPTION
    Export certificate data

    .PARAMETER ID
    Full path to the certificate

    .PARAMETER Format
    Certificate format, either Base64, Base64 (PKCS#8), DER, PKCS #7, or PKCS #12.
    Defaults to Base64.

    .PARAMETER OutPath
    Folder path to save the certificate to.  The name of the file will be determined automatically.

    .PARAMETER IncludeChain
    Include the certificate chain with the exported certificate.  Not supported with DER format.

    .PARAMETER RootFirst
    Use with -IncludeChain for TLSPC to return the root first instead of the end entity first

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
    $certId | Export-VdcCertificate -VaasFormat PEM

    Get certificate data from TLSPC

    .EXAMPLE
    $cert | Export-VdcCertificate -TppFormat 'PKCS #7' -OutPath 'c:\temp'

    Get certificate data and save to a file

    .EXAMPLE
    $cert | Export-VdcCertificate -VaasFormat PEM -IncludeChain -RootFirst

    Get one or more certificates with the certificate chain included and the root first in the chain
    #>

    [CmdletBinding(DefaultParameterSetName = 'Vaas')]

    param (

        [Parameter(ParameterSetName = 'Vaas', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'VaasChain', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('certificateId')]
        [string] $ID,

        [Parameter(ParameterSetName = 'Vaas')]
        [Parameter(ParameterSetName = 'VaasChain')]
        [ValidateSet("DER", "PEM")]
        [string] $Format = 'PEM',

        [Parameter(ParameterSetName = 'VaasChain', Mandatory)]
        [switch] $IncludeChain,

        [Parameter(ParameterSetName = 'VaasChain')]
        [switch] $RootFirst,

        [Parameter(ParameterSetName = 'Vaas')]
        [Parameter(ParameterSetName = 'VaasChain')]
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

        $allCerts = [System.Collections.Generic.List[string]]::new()

        $params = @{
            UriRoot = 'outagedetection/v1'
            Body    = @{
                Format = $Format
            }
        }

        if ( $IncludeChain ) {
            if ( $Format -in @('DER') ) {
                throw "-IncludeChain is not supported with the DER Format"
            }

            $params.Body.chainOrder = 'EE_FIRST'
            if ( $RootFirst ) {
                $params.Body.chainOrder = 'ROOT_FIRST'
            }
        }
        else {
            $params.Body.chainOrder = 'EE_ONLY'
        }
    }

    process {

        $allCerts.Add($ID)
    }

    end {
        Invoke-VenafiParallel -InputObject $allCerts -ScriptBlock {

            # hashtables are reference types so the body must be cloned or the parent scope gets updated
            $params = ($using:params).Clone()

            $params.UriLeaf = "certificates/$PSItem/contents"
            $params.FullResponse = $true

            $innerResponse = Invoke-VenafiRestMethod @params

            $certificateData = $innerResponse.Content -replace "`r|`n|-----(BEGIN|END)[\w\s]+-----|\\r|\\n"

            $out = [pscustomobject] @{
                fileName      = '{0}.{1}' -f $PSItem, $using:Format
                format        = $using:Format
                certificateId = $PSItem
                error         = if ($innerResponse.StatusCode -ne 200) { $innerResponse.StatusDescription }
            }

            if ( $using:OutPath ) {
                if ( $certificateData ) {
                    $outFile = Join-Path -Path $using:OutPath -ChildPath ($innerResponse.FileName.Trim('"'))
                    $bytes = [Convert]::FromBase64String($certificateData)
                    [IO.File]::WriteAllBytes($outFile, $bytes)
                    Write-Verbose "Saved $outFile"
                    $out | Add-Member @{'outPath' = $outFile }
                }
            }
            else {
                $out | Add-Member @{'certificateData' = $certificateData }
            }

            $out

        } -ThrottleLimit $ThrottleLimit -ProgressTitle 'Exporting certificates'
    }
}
