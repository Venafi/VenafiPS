function New-VaasConnector {
    <#
    .SYNOPSIS
    Create a new connector

    .DESCRIPTION
    Create a new connector

    .PARAMETER Name
    Connector name

    .PARAMETER Url
    Endpoint to be called when the event type is triggered

    .PARAMETER EventType
    One or more event types to trigger on.
    You can retrieve a list of possible values from the Event Log and filtering on Event Type.

    .PARAMETER Token
    Token/secret to pass to Url for authentication.
    Set the token as the password on a pscredential.

    .PARAMETER PassThru
    Return newly created connector object

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .OUTPUTS
    PSCustomObject, if PassThru provided

    .EXAMPLE
    New-VaasConnector -Name 'MyConnector' -Url 'https://my.com/endpoint' -EventType 'Authentication'

    Create a new connector

    .EXAMPLE
    New-VaasConnector -Name 'MyConnector' -Url 'https://my.com/endpoint' -EventType 'Authentication', 'Certificates', 'Applications'

    Create a new connector with multiple event types

    .EXAMPLE
    New-VaasConnector -Name 'MyConnector' -Url 'https://my.com/endpoint' -EventType 'Authentication' -Token $myTokenCred

    Create a new connector with optional token

    .EXAMPLE
    New-VaasConnector -Name 'MyConnector' -Url 'https://my.com/endpoint' -EventType 'Authentication' -PassThru

    Create a new connector returning the newly created object

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/New-VaasConnector/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-VaasConnector.ps1

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=connectors-service#/Connectors/connectors_create

    #>

    [CmdletBinding(SupportsShouldProcess)]

    param (
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $Url,

        [Parameter(Mandatory)]
        [String[]] $EventType,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [pscredential] $Token,

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
                        'activityTypes' = @($EventType)
                    }
                }
            }
            FullResponse  = $true
        }

        if ( $PSBoundParameters.ContainsKey('Token') ) {
            $params.Body.properties.target.connection.secret = $Token.GetNetworkCredential().Password
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