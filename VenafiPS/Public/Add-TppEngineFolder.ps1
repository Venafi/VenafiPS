<#
.SYNOPSIS
Add policy folder assignments to a TPP processing engine
.DESCRIPTION
Add one or more policy folder assignments to a TPP processing engine.
.PARAMETER EnginePath
The full DN path to a TPP processing engine.
.PARAMETER EngineObject
TPPObject belonging to the 'Venafi Platform' class.
.PARAMETER FolderPath
The full DN path to one or more policy folders (string array).
.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token can also provided, but this requires an environment variable TPP_SERVER to be set.
.INPUTS
EnginePath or EngineObject, FolderPath[]
.OUTPUTS
None
.EXAMPLE
Add-TppEngineFolder -EnginePath '\VED\Engines\MYVENAFI01' -FolderPath '\VED\Policy\Certificates\Web Team'
Add processing engine MYVENAFI01 to the policy folders '\VED\Policy\Certificates\Web Team'.
.EXAMPLE
Add-TppEngineFolder -EnginePath '\VED\Engines\MYVENAFI01' -FolderPath @('\VED\Policy\Certificates\Web Team','\VED\Policy\Certificates\Database Team')
Add processing engine MYVENAFI01 to the policy folders '\VED\Policy\Certificates\Web Team' and '\VED\Policy\Certificates\Database Team'.
.EXAMPLE
$EngineObjects | Add-TppEngineFolder -FolderPath @('\VED\Policy\Certificates\Web Team','\VED\Policy\Certificates\Database Team') -Confirm:$false
Add one or more processing engines via the pipeline to multiple policy folders. Suppress the confirmation prompt.
.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Add-TppEngineFolder/
.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Add-TppEngineFolder.ps1
.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-ProcessingEngines-Engine-eguid.php
#>
function Add-TppEngineFolder
{
    [CmdletBinding(SupportsShouldProcess)]

    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript( {
            if ( $_ | Test-TppDnPath ) { $true }
            else { throw "'$_' is not a valid DN path" }
        })]
        [Alias('EngineDN', 'Engine', 'Path')]
        [String] $EnginePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
            if ( $_ | Test-TppDnPath ) { $true }
            else { throw "'$_' is not a valid DN path" }
        })]
        [Alias('FolderDN', 'Folder')]
        [String[]] $FolderPath,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            Body       = @{
                FolderGuids = ''
            }
        }
    }

    process {
        if ( -not ($PSBoundParameters.ContainsKey('EngineObject')) ) {
            $EngineObject = Get-TppObject -Path $EnginePath -VenafiSession $VenafiSession
            if ($EngineObject.TypeName -ne 'Venafi Platform') {
                throw ("DN/Path '$($EngineObject.Path)' is not a processing engine")
            }
        }

        $FolderGuids = [System.Collections.Generic.List[string]]::new()
        $params.UriLeaf = "ProcessingEngines/Engine/{$($EngineObject.Guid)}"

        foreach ($path in $FolderPath) {
            try {
                $folder = Get-TppObject -Path $path -VenafiSession $VenafiSession
            }
            catch {
                Write-Warning ("TPP object '$($path)' does not exist")
                Continue
            }
            if ($folder.TypeName -ne 'Policy') {
                Write-Warning ("TPP object '$($folder.Path)' is not a policy folder")
                Continue
            }
            $lastFolder = $folder.Path
            $FolderGuids += "{$($folder.guid)}"
        }

        $params.Body.FolderGuids = @($FolderGuids)

        if ($FolderGuids.Count -gt 1) {
            $shouldProcessAction = "Add $($FolderGuids.Count) policy folders"
        }
        else {
            $shouldProcessAction = "Add $($lastFolder)"
        }

        if ($PSCmdlet.ShouldProcess($EngineObject.Name, $shouldProcessAction)) {
            $response = Invoke-VenafiRestMethod @params

            if ($response.AddedCount -ne $FolderGuids.Count) {
                $errorMessage = "Added $($response.AddedCount) folder(s), but requested $($FolderGuids.Count)"
                if ($response.Errors) {
                    $errorMessage += ": $($response.Errors)"
                }
                Write-Warning ($errorMessage)
            }
            else {
                Write-Verbose ("Added $($response.AddedCount) folder(s) to $($EngineObject.Name)")
            }
        }
    }
}
