function New-VaasApplication {
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

    [CmdletBinding(DefaultParameterSetName = 'NoTarget', SupportsShouldProcess)]

    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory)]
        [guid[]] $Owner,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String] $Description,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [hashtable] $CertificateIssuingTemplate,

        [Parameter(ParameterSetName = 'Fqdn', Mandatory)]
        [Parameter(ParameterSetName = 'FqdnIPRange', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Fqdn,

        [Parameter(ParameterSetName = 'IPRange', Mandatory)]
        [Parameter(ParameterSetName = 'FqdnIPRange', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $IPRange,

        [Parameter(ParameterSetName = 'Fqdn', Mandatory)]
        [Parameter(ParameterSetName = 'IPRange', Mandatory)]
        [Parameter(ParameterSetName = 'FqdnIPRange', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Port,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        # determine if user or team and build the payload
        $ownerHash = foreach ($thisOwner in $Owner) {
            $team = Get-VenafiTeam -ID $thisOwner -VenafiSession $VenafiSession -ErrorAction SilentlyContinue
            if ( $team ) {
                @{ 'ownerId' = $thisOwner; 'ownerType' = 'TEAM' }
            } else {
                $user = Get-VenafiIdentity -ID $thisOwner -VenafiSession $VenafiSession -ErrorAction SilentlyContinue
                if ( $user ) {
                    @{ 'ownerId' = $thisOwner; 'ownerType' = 'USER' }
                } else {
                    Write-Error "Owner $thisOwner not found for application $Name"
                    Continue
                }
            }
        }

        $templateHash = @{}

        if ( $PSBoundParameters.ContainsKey('CertificateIssuingTemplate') ) {
            $CertificateIssuingTemplate.GetEnumerator() | ForEach-Object {
                if ( $_.Value ) {
                    $templateHash.Add($_.Value, $_.Key)
                } else {
                    $thisTemplate = Get-VaasIssuingTemplate -ID $_.Key -VenafiSession $VenafiSession -ErrorAction SilentlyContinue
                    if ( $thisTemplate ) {
                        $templateHash.Add($thisTemplate.Name, $_.Key)
                    } else {
                        Write-Error ('Template ID {0} not found' -f $_.Key)
                        Continue
                    }
                }
            }
        }
    }

    process {

        Write-Verbose $PSCmdlet.ParameterSetName

        if ( -not $ownerHash ) {
            return
        }

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriRoot       = 'outagedetection/v1'
            UriLeaf       = 'applications'
            Body          = @{
                name             = $Name
                ownerIdsAndTypes = [array] $ownerHash
            }
            FullResponse  = $true
        }

        if ( $PSBoundParameters.ContainsKey('Description') ) {
            $params.Body.description = $Description
        }

        if ( $templateHash.Count -gt 0 ) {
            $params.Body.certificateIssuingTemplateAliasIdMap = $templateHash
        }

        if ( $PSBoundParameters.ContainsKey('Fqdn') ) {
            $params.Body.fullyQualifiedDomainNames = $Fqdn
        }

        if ( $PSBoundParameters.ContainsKey('IPRange') ) {
            $params.Body.ipRanges = $IPRange
        }

        if ( $PSBoundParameters.ContainsKey('Port') ) {
            $params.Body.ports = $Port
        }

        if ( $PSCmdlet.ShouldProcess($Name, 'Create application') ) {

            try {
                $response = Invoke-VenafiRestMethod @params
                switch ([int]$response.StatusCode) {

                    '201' {
                        if ( $PassThru ) {
                            $response.Content | ConvertFrom-Json |
                            Select-Object -ExpandProperty applications | Select-Object -Property @{'n' = 'applicationId'; 'e' = { $_.id } }, * -ExcludeProperty id
                        }
                    }

                    '409' {
                        throw "$Name already exists"
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