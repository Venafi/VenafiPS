function Set-VcApplication {
    <#
    Update an existing application

    .DESCRIPTION
    Update name or team owners of an existing applications.
    Additional properties will be available in the future.

    .PARAMETER ID
    The application to update.  Specify either ID or name.

    .PARAMETER Name
    Provide a new name for the application if you wish to change it.

    .PARAMETER TeamOwner
    Associate a team as an owner of this application

    .PARAMETER NoOverwrite
    Append to existing details as opposed to overwriting

    .PARAMETER PassThru
    Return the newly updated object

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A VaaS key can also provided.

    .INPUTS
    ID

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Set-VcApplication -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Name 'ThisAppNameIsBetter'

    Rename an existing application

    .EXAMPLE
    Set-VcApplication -ID 'MyApp' -TeamOwner 'GreatTeam'

    Change the owner to this team

    .EXAMPLE
    Set-VcApplication -ID 'MyApp' -TeamOwner 'GreatTeam' -NoOverwrite

    Append this team to the list of owners
    #>

    [CmdletBinding()]

    param (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('applicationId')]
        [string] $ID,

        [Parameter()]
        [string] $Name,

        [Parameter()]
        [string[]] $TeamOwner,

        [Parameter()]
        [switch] $NoOverwrite,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [Alias('Key')]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Put'
            UriRoot       = 'outagedetection/v1'
            Body          = @{}
        }

        switch ($PSBoundParameters.Keys ) {
            'TeamOwner' {
                $allTeams = Get-VenafiTeam -All
            }
            Default {}
        }
    }

    process {

        $thisApp = Get-VcApplication -ID $ID

        if ( -not $thisApp ) {
            # process the next one in the pipeline if we don't have a valid ID this time
            Write-Error "Application $ID does not exist"
            Continue
        }

        $params.UriLeaf = 'applications/{0}' -f $thisApp.applicationId

        # set required fields to existing values by default
        $params.Body.name = if ( $Name ) {
            $Name
        }
        else {
            $thisApp.name
        }
        $params.Body.ownerIdsAndTypes = $thisApp.ownerIdsAndTypes

        switch ( $PSBoundParameters.Keys ) {
            'TeamOwner' {
                $params.Body.ownerIdsAndTypes = @()
                foreach ($owner in $TeamOwner ) {

                    if ( Test-IsGuid($owner) ) {
                        $thisOwner = $owner
                    }
                    else {
                        $thisOwner = $allTeams | Where-Object { $_.name -eq $owner } | Select-Object -ExpandProperty teamId
                    }

                    if ( $thisOwner ) {
                        $params.Body.ownerIdsAndTypes += @{
                            ownerId   = $thisOwner
                            ownerType = 'TEAM'
                        }
                    }
                    else {
                        Write-Error "Team $ID does not exist"
                    }
                }

                if ( $NoOverwrite ) {
                    $params.Body.ownerIdsAndTypes += $thisApp.ownerIdsAndTypes
                }
            }

            Default {}
        }

        $response = Invoke-VenafiRestMethod @params

        if ( $PassThru ) {
            $response | ConvertTo-VaasTeam
        }
    }
}
