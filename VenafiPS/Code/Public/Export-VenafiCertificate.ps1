<#
.SYNOPSIS
Get a certificate

.DESCRIPTION
Get a certificate

.PARAMETER Id
Id of the certificate

.PARAMETER Format
Certificate format, either PEM or DER

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Id

.OUTPUTS
System.String

.EXAMPLE
$certId | Export-VaasCertificate
Get a certificate

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Export-VaasCertificate/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Export-VaasCertificate.ps1

#>
function Export-VenafiCertificate {

    [CmdletBinding(DefaultParameterSetName = 'Tpp')]
    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Path')]
        [guid] $CertificateId,

        # [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        # [ValidateNotNullOrEmpty()]
        # [ValidateScript( {
        #         if ( $_ | Test-TppDnPath ) {
        #             $true
        #         } else {
        #             throw "'$_' is not a valid path"
        #         }
        #     })]
        # [Alias('DN')]
        # [String] $Path,

        [Parameter(Mandatory)]
        [ValidateSet("Base64", "Base64 (PKCS #8)", "DER", "JKS", "PKCS #7", "PKCS #12", "PEM")]
        [string] $Format,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if (Test-Path $_ -PathType Container) {
                    $true
                } else {
                    Throw "Output path '$_' does not exist"
                }
            })]
        [String] $OutPath,

        [Parameter(ParameterSetName = 'Tpp')]
        [switch] $IncludeChain,

        [Parameter(ParameterSetName = 'Tpp')]
        [Parameter(Mandatory, ParameterSetName = 'TppJks')]
        [string] $FriendlyName,

        [Parameter(ParameterSetName = 'Tpp')]
        [switch] $IncludePrivateKey,

        [Parameter(ParameterSetName = 'Tpp')]
        [Alias('SecurePassword')]
        [Security.SecureString] $PrivateKeyPassword,

        [Parameter(Mandatory, ParameterSetName = 'TppJks')]
        [Security.SecureString] $KeystorePassword,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $params = @{
            VenafiSession = $VenafiSession
            Body          = @{
                format = $Format
            }
        }

        $authType = $VenafiSession.Validate()

        # check format
        # if ( $Format -notin 'PEM', 'DER') {
        #     throw 'Venafi as a Service only supports PEM and DER formats'
        # }
    }

    process {

        if ( $authType -eq 'vaas' ) {
            $params.UriLeaf = "certificaterequests/$CertificateId/certificate"
            $params.Method = 'Get'
            Invoke-TppRestMethod @params
            # $response = Invoke-TppRestMethod @params
            # if ( $response.PSObject.Properties.Name -contains 'certificaterequests' ) {
            #     $certs = $response | Select-Object -ExpandProperty certificaterequests
            # } else {
            #     $certs = $response
            # }

            # $certs | Select-Object *,
            # @{
            #     'n' = 'certificateId'
            #     'e' = {
            #         $_.id
            #     }
            # } -ExcludeProperty id
        } else {
            $params.Body.CertificateDN = $Path

            $response = Invoke-TppRestMethod @params

            Write-Verbose ($response | Format-List | Out-String)

            if ( $PSBoundParameters.ContainsKey('OutPath') ) {
                if ( $response.PSobject.Properties.name -contains "CertificateData" ) {
                    $outFile = Join-Path -Path $OutPath -ChildPath ($response.FileName.Trim('"'))
                    $bytes = [Convert]::FromBase64String($response.CertificateData)
                    [IO.File]::WriteAllBytes($outFile, $bytes)
                    Write-Verbose ('Saved {0} with format {1}' -f $outFile, $response.Format)
                }
            } else {
                $response
            }
        }
    }
}
