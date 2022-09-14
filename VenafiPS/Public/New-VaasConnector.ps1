function New-VaasConnector {
    <#
    .SYNOPSIS
    Create a new application

    .DESCRIPTION
    Create a new application with optional details

    .PARAMETER Name
    Application name

    .PARAMETER Owner
    List of user and/or team IDs to be owners.
    Use Get-VenafiIdentity or Get-VenafiTeam to retrieve the ID.

    .PARAMETER Description
    Application description

    .PARAMETER CertificateIssuingTemplate
    Hashtable of issuing templates.
    For each key/value pair, the key should be the issuing template id and the value should be the alias.
    Null can be provided for the alias which will use the template name as the alias.

    .PARAMETER Fqdn
    Fully qualified domain names to assign to the application

    .PARAMETER IPRange
    IP ranges to assign to the application

    .PARAMETER Port
    Ports to assign to the application.
    Required if either Fqdn or IPRange are specified.

    .PARAMETER PassThru
    Return newly created application object

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .OUTPUTS
    PSCustomObject, if PassThru provided

    .EXAMPLE
    New-VaasApplication -Name 'MyNewApp' -Owner '4ba1e64f-12ad-4a34-a0e2-bc4481a56f7d'

    Create a new application

    .EXAMPLE
    New-VaasApplication -Name 'MyNewApp' -Owner '4ba1e64f-12ad-4a34-a0e2-bc4481a56f7d' -CertificateIssuingTemplate @{'9c9618e8-6b4c-4a1c-8c11-902c9b2676d3'=$null} -Description 'this app is awesome' -Fqdn 'me.com' -IPRange '1.2.3.4/24' -Port '443','9443'

    Create a new application with optional details

    .EXAMPLE
    New-VaasApplication -Name 'MyNewApp' -Owner '4ba1e64f-12ad-4a34-a0e2-bc4481a56f7d' -PassThru

    Create a new application and return the newly created application object

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/New-VaasApplication/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-VaasApplication.ps1

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=outagedetection-service#/Applications/applications_create

    #>

    [CmdletBinding(SupportsShouldProcess)]

    param (
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $Url,

        [Parameter(Mandatory)]
        [String[]] $ActivityType,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Secret,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'
    }

    process {

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriRoot       = 'v1'
            UriLeaf       = 'connectors'
            Body          = @{
                name       = $Name
                properties = @{
                    'connectorKind' = 'WEBHOOK'
                    'target'        = @{
                        'type'       = 'generic'
                        'connection' = @{
                            'url' = $Url
                        }
                    }
                    'filter'        = @{
                        'activityTypes' = @($ActivityType)
                    }
                }
            }
            FullResponse  = $true
        }

        if ( $PSBoundParameters.ContainsKey('Secret') ) {
            $params.Body.properties.target.secret = $Secret
        }

        if ( $PSCmdlet.ShouldProcess($Name, 'Create connector') ) {

            try {
                $response = Invoke-VenafiRestMethod @params
                switch ([int]$response.StatusCode) {

                    '201' {
                        if ( $PassThru ) {
                            $response.Content | ConvertFrom-Json | Select-Object -Property @{'n' = 'connectorId'; 'e' = { $_.id } }, * -ExcludeProperty id
                        }
                    }

                    '409' {
                        throw "Connector '$Name' already exists"
                    }

                    default {
                        throw ($response | Select-Object StatusCode, StatusDescription)
                    }
                }
            } catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }
    }
}