
# DELETE https://tpp.venafi.example/vedsdk/ProcessingEngines/Folder/{folder_guid}/{engine_guid}

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