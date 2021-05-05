<#
.SYNOPSIS
Get certificate information

.DESCRIPTION
Get certificate information, either all available to the api key provided or by id or zone.

.PARAMETER CertificateId
Certificate identifier.  For Venafi as a Service, this is the unique guid.  For TPP, use the full path.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Id

.OUTPUTS
PSCustomObject

.EXAMPLE
Get-VenafiCertificate
Get certificate info for all certs

.EXAMPLE
Get-VenafiCertificate -CertificateId 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Get certificate info for a specific cert on Venafi as a Serivce

.EXAMPLE
Get-VenafiCertificate -CertificateId '\ved\policy\mycert.com'
Get certificate info for a specific cert on TPP

#>
function Get-VenafiCertificate {

    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (

        [Parameter(ParameterSetName = 'Id', ValueFromPipeline, ValueFromPipelineByPropertyName)]
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
                $params.UriLeaf = "certificaterequests"

                if ( $PSCmdlet.ParameterSetName -eq 'Id' ) {
                    $params.UriLeaf += "/$CertificateId"
                }

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
                # $params.Method = 'Post'
                # $params.UriLeaf = 'certificates/retrieve'

                if ( $PSCmdlet.ParameterSetName -eq 'Id' ) {
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
                } else {
                    Find-TppCertificate -Path '\ved' -Recursive
                }
            }
        }
    }
}
