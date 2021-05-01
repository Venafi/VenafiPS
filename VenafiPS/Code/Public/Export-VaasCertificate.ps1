<#
.SYNOPSIS
Get a certificate

.DESCRIPTION
Get a certificate

.PARAMETER Id
Id of the certificate

.PARAMETER Format
Certificate format, either PEM or DER

.PARAMETER TppSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $TppSession.

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
function Export-VaasCertificate {

    [CmdletBinding()]
    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [guid] $Id,

        [Parameter()]
        [ValidateSet('PEM', 'DER')]
        [string] $Format = 'PEM',

        [Parameter()]
        [TppSession] $TppSession = $Script:TppSession
    )

    begin {
        $TppSession.Validate('vaas')

        $params = @{
            TppSession   = $TppSession
            Method       = 'Get'
            CloudUriLeaf = ''
            Body = @{
                format = $Format
            }
        }
    }

    process {
        $params.CloudUriLeaf = "certificaterequests/$Id/certificate"
        Invoke-TppRestMethod @params
    }
}
