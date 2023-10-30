function New-VcApplication {
    <#
    .SYNOPSIS
    Create a new application

    .DESCRIPTION
    Create a new application with optional details

    .PARAMETER Name
    Application name

    .PARAMETER Owner
    List of user and/or team IDs or names to be owners

    .PARAMETER Description
    Application description

    .PARAMETER IssuingTemplate
    1 or more issuing template IDs or names to associate with the new application

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
    A TLSPC key can also provided.

    .OUTPUTS
    PSCustomObject, if PassThru provided

    .EXAMPLE
    New-VcApplication -Name 'MyNewApp' -Owner '4ba1e64f-12ad-4a34-a0e2-bc4481a56f7d','greg@venafi.com'

    Create a new application

    .EXAMPLE
    New-VcApplication -Name 'MyNewApp' -Owner '4ba1e64f-12ad-4a34-a0e2-bc4481a56f7d' -CertificateIssuingTemplate @{'9c9618e8-6b4c-4a1c-8c11-902c9b2676d3'=$null} -Description 'this app is awesome' -Fqdn 'me.com' -IPRange '1.2.3.4/24' -Port '443','9443'

    Create a new application with optional details

    .EXAMPLE
    New-VcApplication -Name 'MyNewApp' -Owner '4ba1e64f-12ad-4a34-a0e2-bc4481a56f7d' -PassThru

    Create a new application and return the newly created application object

    #>

    [CmdletBinding(DefaultParameterSetName = 'NoTarget', SupportsShouldProcess)]
    [Alias('New-VaasApplication')]

    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]] $Owner,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String] $Description,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]] $IssuingTemplate,

        [Parameter(ParameterSetName = 'Fqdn', Mandatory, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'FqdnIPRange', Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Fqdn,

        [Parameter(ParameterSetName = 'IPRange', Mandatory, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'FqdnIPRange', Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]] $IPRange,

        [Parameter(ParameterSetName = 'Fqdn', Mandatory, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'IPRange', Mandatory, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'FqdnIPRange', Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Port,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VC'

        # determine if user or team and build the payload
        $ownerHash = foreach ($thisOwner in $Owner) {

            $team = Get-VcTeam -ID $thisOwner -ErrorAction SilentlyContinue
            if ( $team ) {
                @{ 'ownerId' = $team.teamId; 'ownerType' = 'TEAM' }
            }
            else {
                $user = Get-VcIdentity -ID $thisOwner -ErrorAction SilentlyContinue
                if ( $user ) {
                    @{ 'ownerId' = $user.userId; 'ownerType' = 'USER' }
                }
                else {
                    Write-Error "Owner $thisOwner not found"
                    Continue
                }
            }
        }

        $templateHash = @{}
        foreach ($thisTemplateID in $IssuingTemplate) {
            $thisTemplate = Get-VcIssuingTemplate -ID $thisTemplateID
            if ( $thisTemplate ) {
                $templateHash.Add($thisTemplate.name, $thisTemplate.issuingTemplateId)
            }
            else {
                throw ('Template ID {0} not found' -f $thisTemplateID)
            }
        }

        # if ( $PSBoundParameters.ContainsKey('IssuingTemplate') ) {
        #     $IssuingTemplate.GetEnumerator() | ForEach-Object {
        #         if ( $_.Value ) {
        #             $templateHash.Add($_.Value, $_.Key)
        #         }
        #         else {
        #             $thisTemplate = Get-VcIssuingTemplate -ID $_.Key -ErrorAction SilentlyContinue
        #             if ( $thisTemplate ) {
        #                 $templateHash.Add($thisTemplate.Name, $_.Key)
        #             }
        #             else {
        #                 Write-Error ('Template ID {0} not found' -f $_.Key)
        #                 Continue
        #             }
        #         }
        #     }
        # }
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
                switch ( $response.StatusCode ) {

                    201 {
                        if ( $PassThru ) {
                            $response.Content | ConvertFrom-Json |
                            Select-Object -ExpandProperty applications | Select-Object -Property @{'n' = 'applicationId'; 'e' = { $_.id } }, * -ExcludeProperty id
                        }
                    }

                    409 {
                        throw "$Name already exists"
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