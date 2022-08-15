
# DELETE https://my.venafi.com/vedsdk/ProcessingEngines/Folder/{folder_guid}[/{engine_guid}]

function Remove-TppEnginesAssignedToFolder
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]

    param (
        [Parameter(Mandatory, ParameterSetName = 'RemoveOneByObject', ValueFromPipeline)]
        [Parameter(Mandatory, ParameterSetName = 'RemoveAllByObject', ValueFromPipeline)]
        [TppObject] $FolderObject,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'RemoveOneByPath')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'RemoveAllByPath')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
            if ( $_ | Test-TppDnPath ) { $true }
            else { throw "'$_' is not a valid DN path" }
        })]
        [Alias('DN', 'FolderDN', 'Folder', 'Path')]
        [String] $FolderPath,

        [Parameter(Mandatory, ParameterSetName = 'RemoveOneByObject')]
        [Parameter(Mandatory, ParameterSetName = 'RemoveOneByPath')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
            if ( $_ | Test-TppDnPath ) { $true }
            else { throw "'$_' is not a valid DN path" }
        })]
        [Alias('EngineDN', 'Engine')]
        [String[]] $EnginePath,

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
            Method     = 'Delete'
        }
    }

    process {
        if ( -not ($PSBoundParameters.ContainsKey('FolderObject')) ) {
            $FolderObject = Get-TppObject -Path $FolderPath -VenafiSession $VenafiSession
        }

        if ($FolderObject.TypeName -ne 'Policy') {
            Write-Error ("DN/Path '$($FolderObject.Path)' is not a policy folder")
            Return
        }

        if ( -not ($FolderObject.Path | Test-TppObject -ExistOnly -VenafiSession $VenafiSession) ) {
            Write-Error ("Folder path '$($FolderObject.Path)' does not exist")
            Return
        }

        $apiCall = "ProcessingEngines/Folder/{$($FolderObject.Guid)}"

        Switch -Wildcard ($PsCmdlet.ParameterSetName)	{
            'RemoveOne*' {
                if ($EnginePath.Count -gt 1) {
                    $shouldProcessAction = "Remove $($EnginePath.Count) processing engines"
                }
                else {
                    $shouldProcessAction = "Remove processing engine $($EnginePath)"
                }
                if ($Force.IsPresent -or $PSCmdlet.ShouldProcess($FolderObject.Path, $shouldProcessAction)) {
                    foreach ($path in $EnginePath) {
                        try {
                            $engine = Get-TppObject -Path $path -VenafiSession $VenafiSession
                        }
                        catch {
                            Write-Error ("TPP object '$($path)' does not exist")
                            Continue
                        }
                        try {
                            if ($engine.TypeName -eq 'Venafi Platform') {
                                $Uri = "$($apiCall)/{$($FolderObject.Guid)}/{$($engine.Guid)}"
                                Invoke-VenafiRestMethod @params -UriLeaf $Uri | Out-Null
                            }
                            else {
                                Write-Error ("TPP object '$($engine.Path)' is not a processing engine")
                                Continue
                            }
                        }
                        catch {
                            $myError = $_.ToString() | ConvertFrom-Json
                            Write-Error ("Error removing engine '$($path)' from folder '$($FolderObject.Name)': $($myError.Error)")
                            Continue
                        }
                    }
                }
            }

            'RemoveAll*' {
                $shouldProcessAction = "Remove ALL processing engines"
                try {
                    if ($Force.IsPresent -or $PSCmdlet.ShouldProcess($FolderObject.Path, $shouldProcessAction)) {
                        Invoke-VenafiRestMethod @params -UriLeaf $apiCall | Out-Null
                    }
                } catch {
                    $myError = $_.ToString() | ConvertFrom-Json
                    Write-Error ("Error removing processing engines from folder policy '$($FolderObject.Path)': $($myError.Error)")
                }
            }
        }
    }
}