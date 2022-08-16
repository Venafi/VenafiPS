<#
.SYNOPSIS
Remove policy folder assignments from a TPP processing engine
.DESCRIPTION
Remove one or more policy folder assignments from a TPP processing engine.
.PARAMETER EnginePath
The full DN path to a TPP processing engine.
.PARAMETER EngineObject
TPPObject belonging to the 'Venafi Platform' class.
.PARAMETER FolderPath
The full DN path to one or more policy folders (string array).
.PARAMETER All
Remove all assigned folder assignments from a TPP processing engine.
.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token can also provided, but this requires an environment variable TPP_SERVER to be set.
.INPUTS
EnginePath or EngineObject, FolderPath[]
.OUTPUTS
None
.EXAMPLE
Remove-TppFoldersAssignedToEngine -EnginePath '\VED\Engines\MYVENAFI01' -FolderPath @('\VED\Policy\Certificates\Web Team','\VED\Policy\Certificates\Database Team')
Remove processing engine MYVENAFI01 from the policy folders '\VED\Policy\Certificates\Web Team' and '\VED\Policy\Certificates\Database Team'.
.EXAMPLE
$MyEngine | Remove-TppFoldersAssignedToEngine -All -Force
Remove all policy folder assignments for the processing engine represented by the $MyEngine TPP object and suppress the confirmation prompt.
.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppFoldersAssignedToEngine/
.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppFoldersAssignedToEngine.ps1
.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-DELETE-ProcessingEngines-Folder-fguid-eguid.php
#>
function Remove-TppFoldersAssignedToEngine
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]

    param (
        [Parameter(Mandatory, ParameterSetName = 'RemoveOneByObject', ValueFromPipeline)]
        [Parameter(Mandatory, ParameterSetName = 'RemoveAllByObject', ValueFromPipeline)]
        [TppObject] $EngineObject,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'RemoveOneByPath')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'RemoveAllByPath')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
            if ( $_ | Test-TppDnPath ) { $true }
            else { throw "'$_' is not a valid DN path" }
        })]
        [Alias('DN', 'EngineDN', 'Engine', 'Path')]
        [String] $EnginePath,

        [Parameter(Mandatory, ParameterSetName = 'RemoveOneByObject')]
        [Parameter(Mandatory, ParameterSetName = 'RemoveOneByPath')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
            if ( $_ | Test-TppDnPath ) { $true }
            else { throw "'$_' is not a valid DN path" }
        })]
        [Alias('FolderDN', 'Folder')]
        [String[]] $FolderPath,

        [Parameter(Mandatory, ParameterSetName = 'RemoveAllByObject')]
        [Parameter(Mandatory, ParameterSetName = 'RemoveAllByPath')]
        [Alias('RemoveAll')]
        [switch] $All,

        [switch] $Force,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Delete'
        }

        $apiCall = "ProcessingEngines/Folder"
    }

    process {
        if ( -not ($PSBoundParameters.ContainsKey('EngineObject')) ) {
            $EngineObject = Get-TppObject -Path $EnginePath -VenafiSession $VenafiSession
        }

        if ($EngineObject.TypeName -ne 'Venafi Platform') {
            Write-Error ("DN/Path '$($EngineObject.Path)' is not a processing engine")
            Return
        }

        if ( -not ($EngineObject.Path | Test-TppObject -ExistOnly -VenafiSession $VenafiSession) ) {
            Write-Error ("Engine path '$($EngineObject.Path)' does not exist")
            Return
        }

        Switch -Wildcard ($PsCmdlet.ParameterSetName)	{
            'RemoveOne*' {
                if ($FolderPath.Count -gt 1) {
                    $shouldProcessAction = "Remove $($FolderPath.Count) policy folders"
                }
                else {
                    $shouldProcessAction = "Remove policy folder $($FolderPath)"
                }
                if ($Force.IsPresent -or $PSCmdlet.ShouldProcess($EngineObject.Path, $shouldProcessAction)) {
                    foreach ($path in $FolderPath) {
                        try {
                            $folder = Get-TppObject -Path $path -VenafiSession $VenafiSession
                        }
                        catch {
                            Write-Error ("TPP object '$($path)' does not exist")
                            Continue
                        }
                        try {
                            if ($folder.TypeName -eq 'Policy') {
                                $Uri = "$($apiCall)/{$($folder.Guid)}/{$($EngineObject.Guid)}"
                                Invoke-VenafiRestMethod @params -UriLeaf $Uri | Out-Null
                            }
                            else {
                                Write-Error ("TPP object '$($folder.Path)' is not a policy folder")
                                Continue
                            }
                        }
                        catch {
                            $myError = $_.ToString() | ConvertFrom-Json
                            Write-Error ("Error removing folder '$($path)' from engine '$($EngineObject.Name)': $($myError.Error)")
                            Continue
                        }
                    }
                }
            }

            'RemoveAll*' {
                $shouldProcessAction = "Remove ALL policy folder assignments"
                $FolderList = $EngineObject | Get-TppFoldersAssignedToEngine -VenafiSession $VenafiSession
                if ($FolderList) {
                    $shouldProcessAction = "Remove ALL ($($FolderList.Count)) policy folder"
                    if ($FolderList.Count -gt 1) { $shouldProcessAction += "s" }
                    if ($Force.IsPresent -or $PSCmdlet.ShouldProcess($EngineObject.Path, $shouldProcessAction)) {
                        foreach ($folder in $FolderList) {
                            $Uri = "$($apiCall)/{$($folder.Guid)}/{$($EngineObject.Guid)}"
                            try {
                                Invoke-VenafiRestMethod @params -UriLeaf $Uri | Out-Null
                            }
                            catch {
                                $myError = $_.ToString() | ConvertFrom-Json
                                Write-Error ("Error removing folder '$($folder)' from engine '$($EngineObject.Name)': $($myError.Error)")
                                Continue
                            }
                        }
                    }
                }
            }
        }
    }
}