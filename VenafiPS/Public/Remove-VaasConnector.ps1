function Remove-VaasConnector {
    <#
    .SYNOPSIS
    Delete a code sign project

    .DESCRIPTION
    Delete a code sign project.  You must be a code sign admin or owner of the project.

    .PARAMETER Path
    Path of the project to delete

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    Path

    .OUTPUTS
    None

    .EXAMPLE
    Remove-TppCodeSignProject -Path '\ved\code signing\projects\my_project'
    Delete a project

    .EXAMPLE
    $projectObj | Remove-TppCodeSignProject
    Remove 1 or more projects.  Get projects with Find-TppCodeSignProject

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppCodeSignProject/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppCodeSignProject.ps1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-DeleteProject.php

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('connectorId')]
        [guid] $ID,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Delete'
            UriRoot       = 'v1'
        }
    }

    process {

        $params.UriLeaf = "connectors/$ID"

        if ( $PSCmdlet.ShouldProcess($ID, 'Remove connector') ) {
            Invoke-VenafiRestMethod @params
        }
    }
}
