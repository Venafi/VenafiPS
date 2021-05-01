<#
.SYNOPSIS
Get certificate information

.DESCRIPTION
Get certificate information, either all available to the api key provided or by id or zone.

.PARAMETER Id
Get certificate information for a specific id

.PARAMETER ZoneId
Get certificate information for all within a specific zone

.PARAMETER TppSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $TppSession.

.INPUTS
Id

.OUTPUTS
PSCustomObject

.EXAMPLE
Get-VaasCertificate
Get certificate info for all certs

.EXAMPLE
Get-VaasCertificate -Id 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Get certificate info for a specific cert

.EXAMPLE
Get-VaasCertificate -ZoneId 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Get certificate info for all certs within a specific zone

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-VaasCertificate/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Get-VaasCertificate.ps1

#>
function Get-VaasCertificate {

    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'Id', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [guid] $CertificateId,

        [Parameter(Mandatory, ParameterSetName = 'Zone')]
        [guid] $ZoneId,

        [Parameter()]
        [TppSession] $TppSession = $Script:TppSession
    )

    begin {
        $TppSession.Validate('vaas')

        $params = @{
            TppSession   = $TppSession
            Method       = 'Get'
            CloudUriLeaf = 'certificaterequests'
        }
    }

    process {

        switch ($PSCmdLet.ParameterSetName) {
            'Id' {
                $params.CloudUriLeaf += "/$CertificateId"
            }

            'Zone' {
                $params.CloudUriLeaf += "/zone/$ZoneId"
            }

            Default {
            }
        }

        $response = Invoke-TppRestMethod @params
        if ( $response.PSObject.Properties.Name -contains 'certificaterequests' ) {
            $certs = $response | Select-Object -ExpandProperty certificaterequests
        } else {
            $certs = $response
        }

        $certs = $certs | Select-Object *,
        @{
            'n' = 'certificateId'
            'e' = {
                $_.id
            }
        } -ExcludeProperty id

        $certs | ForEach-Object { $_.PSObject.TypeNames.Insert(0, 'VenafiPS.Vaas.Certificate') }
        $certs

    }
}
