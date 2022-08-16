
# Example: Attach an engine to a Policy folder
#
# POST https://tpp.venafi.example/vedsdk/ProcessingEngines/engine/{c4152110-1ec9-4f62-99fe-869d66264c34}
#
# {
#    "FolderGuids":[
#       "{067e26e2-5536-4a6d-915b-fbf28496125c}"
#    ]
# }
function Add-TppFoldersAssignedToEngine
{
    [CmdletBinding(SupportsShouldProcess)]

    param (
        [Parameter(Mandatory, ParameterSetName = 'AddByObject', ValueFromPipeline)]
        [TppObject] $EngineObject,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'AddByPath')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
            if ( $_ | Test-TppDnPath ) { $true }
            else { throw "'$_' is not a valid DN path" }
        })]
        [Alias('DN', 'EngineDN', 'Engine', 'Path')]
        [String] $EnginePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
            if ( $_ | Test-TppDnPath ) { $true }
            else { throw "'$_' is not a valid DN path" }
        })]
        [Alias('FolderDN', 'Folder')]
        [String[]] $FolderPath,

        [switch] $Force,

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
        }

        if ($EngineObject.TypeName -ne 'Venafi Platform') {
            Write-Error ("DN/Path '$($EngineObject.Path)' is not a processing engine")
            Return
        }

        if ( -not ($EngineObject.Path | Test-TppObject -ExistOnly -VenafiSession $VenafiSession) ) {
            Write-Error ("Engine path '$($EngineObject.Path)' does not exist")
            Return
        }

        $params.UriLeaf = "ProcessingEngines/Engine/{$($EngineObject.Guid)}"

        [string[]] $FolderGuids = @()

        foreach ($path in $FolderPath) {
            try {
                $folder = Get-TppObject -Path $path -VenafiSession $VenafiSession
            }
            catch {
                Write-Error ("TPP object '$($path)' does not exist")
                Continue
            }
            if ($folder.TypeName -ne 'Policy') {
                Write-Error ("TPP object '$($folder.Path)' is not a policy folder")
                Continue
            }
            $FolderGuids += "{$($folder.guid)}"
        }

        $params.Body.FolderGuids = @($FolderGuids)

        if ($FolderGuids.Count -gt 1) {
            $shouldProcessAction = "Add $($FolderGuids.Count) policy folders"
        }
        else {
            $shouldProcessAction = "Add policy folder $($folder.Name)"
        }

        if ($Force.IsPresent -or $PSCmdlet.ShouldProcess($EngineObject.Path, $shouldProcessAction)) {
            $response = Invoke-VenafiRestMethod @params

            if ($response.AddedCount -ne $FolderGuids.Count) {
                $errorMessage = "Added $($response.AddedCount) folder(s), but requested $($FolderGuids.Count)"
                if ($response.Errors) {
                    $errorMessage += ": $($response.Errors)"
                }
                Write-Error ($errorMessage)
            }
        }
    }
}