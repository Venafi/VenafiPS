<#
.SYNOPSIS
Get certificate information

.DESCRIPTION
Get certificate information, either all available to the api key provided or by id or zone.

.PARAMETER Id
Get certificate information for a specific id

.PARAMETER ZoneId
Get certificate information for all within a specific zone

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

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
function Get-VenafiCertificate {

    [CmdletBinding()]
    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [guid] $CertificateId,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {

        $authType = $VenafiSession.Validate()

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Get'
        }
    }

    process {

        switch ($authType) {
            'vaas' {
                $params.UriLeaf = "certificaterequests/$CertificateId"
                $response = Invoke-TppRestMethod @params
                if ( $response.PSObject.Properties.Name -contains 'certificaterequests' ) {
                    $certs = $response | Select-Object -ExpandProperty certificaterequests
                } else {
                    $certs = $response
                }

                $certs | Select-Object *,
                @{
                    'n' = 'certificateId'
                    'e' = {
                        $_.id
                    }
                } -ExcludeProperty id
            }

            Default {
                $params.Method = 'Post'
                $params.UriLeaf = 'certificates/retrieve'

                try {
                    $thisGuid = [guid] $CertificateId
                } catch {
                    $thisGuid = $CertificateId | ConvertTo-TppGuid -VenafiSession $VenafiSession
                }
                # $thisGuid = $Path | ConvertTo-TppGuid -VenafiSession $VenafiSession
                $params.UriLeaf = [System.Web.HttpUtility]::HtmlEncode("certificates/{$thisGuid}")
                $response = Invoke-VenafiRestMethod @params

                $selectProps = @{
                    Property        =
                    @{
                        n = 'Name'
                        e = { $_.Name }
                    },
                    @{
                        n = 'TypeName'
                        e = { $_.SchemaClass }
                    },
                    @{
                        n = 'Path'
                        e = { $_.DN }
                    }, @{
                        n = 'Guid'
                        e = { [guid]$_.guid }
                    }, @{
                        n = 'ParentPath'
                        e = { $_.ParentDN }
                    },
                    '*'
                    ExcludeProperty = 'DN', 'GUID', 'ParentDn', 'SchemaClass', 'Name'
                }
                $response | Select-Object @selectProps
            }
        }
    }
}
