function New-VcWebhook {
    <#
    .SYNOPSIS
    Create a new connector

    .DESCRIPTION
    Create a new connector

    .PARAMETER Name
    Connector name

    .PARAMETER Url
    Endpoint to be called when the event type/name is triggered.
    This should be the full url and will be validated during connector creation.

    .PARAMETER EventType
    One or more event types to trigger on.
    You can retrieve a list of possible values from the Event Log and filtering on Event Type.

    .PARAMETER EventName
    One or more event names to trigger on.

    .PARAMETER Secret
    Secret value used to calculate signature which will be sent to the endpoint in the header

    .PARAMETER CriticalOnly
    Only subscribe to log messages deemed as critical

    .PARAMETER PassThru
    Return newly created connector object

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .OUTPUTS
    PSCustomObject, if PassThru provided

    .EXAMPLE
    New-VcConnector -Name 'MyConnector' -Url 'https://my.com/endpoint' -EventType 'Authentication'

    Create a new connector for one event type

    .EXAMPLE
    New-VcConnector -Name 'MyConnector' -Url 'https://my.com/endpoint' -EventType 'Authentication', 'Certificates', 'Applications'

    Create a new connector with multiple event types

    .EXAMPLE
    New-VcConnector -Name 'MyConnector' -Url 'https://my.com/endpoint' -EventName 'Certificate Validation Started'

    Create a new connector with event names as opposed to event types.
    This will result in fewer messages received as opposed to subscribing at the event type level.

    .EXAMPLE
    New-VcConnector -Name 'MyConnector' -Url 'https://my.com/endpoint' -EventType 'Certificates' -CriticalOnly

    Subscribe to critical messages only for a specific event type

    .EXAMPLE
    New-VcConnector -Name 'MyConnector' -Url 'https://my.com/endpoint' -EventType 'Authentication' -Secret 'MySecret'

    Create a new connector with optional secret

    .EXAMPLE
    New-VcConnector -Name 'MyConnector' -Url 'https://my.com/endpoint' -EventType 'Authentication' -PassThru

    Create a new connector returning the newly created object

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/New-VcConnector/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-VcConnector.ps1

    .LINK
    https://api.venafi.cloud/webjars/swagger-ui/index.html?urls.primaryName=connectors-service#/Connectors/connectors_create

    #>

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'EventName')]

    param (
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $Url,

        [Parameter(Mandatory, ParameterSetName = 'EventType')]
        [String[]] $EventType,

        [Parameter(Mandatory, ParameterSetName = 'EventName')]
        [String[]] $EventName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('token')]
        [string] $Secret,

        [Parameter()]
        [switch] $CriticalOnly,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'

        # validate inputs
        $at = Invoke-VenafiRestMethod -UriLeaf 'activitytypes'

        if ( $PSBoundParameters.ContainsKey('EventType') ) {
            $compare = compare-object -ReferenceObject $EventType -DifferenceObject $at.readablename | Where-Object { $_.SideIndicator -eq '<=' }
            if ( $compare ) {
                throw ('{0} are not valid event types.  Valid values include {1}.' -f ($compare.InputObject -join ', '), ($at.readablename -join ', '))
            }
        }
        else {
            $compare = compare-object -ReferenceObject $EventName -DifferenceObject $at.values.readablename | Where-Object { $_.SideIndicator -eq '<=' }
            if ( $compare ) {
                throw ('{0} are not valid event names.  Valid values include {1}.' -f ($compare.InputObject -join ', '), ($at.values.readablename -join ', '))
            }
        }
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
                        criticality = [int]$CriticalOnly.IsPresent
                    }
                }
            }
            FullResponse  = $true
        }

        # either event type or name will be provided
        if ( $PSBoundParameters.ContainsKey('EventType') ) {
            $params.Body.properties.filter.activityTypes = @($EventType)
        }
        else {
            $params.Body.properties.filter.activities = @($EventName)
        }

        if ( $PSBoundParameters.ContainsKey('Secret') ) {
            $params.Body.properties.target.connection.secret = $Secret
        }

        if ( $PSCmdlet.ShouldProcess($Name, 'Create connector') ) {

            try {
                $response = Invoke-VenafiRestMethod @params
                switch ( $response.StatusCode ) {

                    201 {
                        if ( $PassThru ) {
                            $response.Content | ConvertFrom-Json | Select-Object -Property @{'n' = 'connectorId'; 'e' = { $_.id } }, * -ExcludeProperty id
                        }
                    }

                    409 {
                        throw "Connector '$Name' already exists"
                    }

                    default {
                        throw $response
                    }
                }
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }
    }
}