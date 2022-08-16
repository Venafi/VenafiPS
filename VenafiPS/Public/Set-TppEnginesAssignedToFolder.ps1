
# Example: Assign two Platforms engines to manage a Policy folder
#
# PUT https://tpp.venafi.example/vedsdk/ProcessingEngines/Folder/{067e26e2-5536-4a6d-915b-fbf28496125c}
#
# {
#    "EngineGuids":[
#       "{c4152110-1ec9-4f62-99fe-869d66264c34}",
#       "{153d0c3d-f9ff-4682-b801-687c7c4db0e9}"
#    ]
# }

function Set-TppEnginesAssignedToFolder
{
    [CmdletBinding(SupportsShouldProcess)]

    param (
        [Parameter(Mandatory, ParameterSetName = 'AddByObject', ValueFromPipeline)]
        [TppObject] $FolderObject,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'AddByPath')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
            if ( $_ | Test-TppDnPath ) { $true }
            else { throw "'$_' is not a valid DN path" }
        })]
        [Alias('DN', 'FolderDN', 'Folder', 'Path')]
        [String] $FolderPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
            if ( $_ | Test-TppDnPath ) { $true }
            else { throw "'$_' is not a valid DN path" }
        })]
        [Alias('EngineDN', 'Engine')]
        [String[]] $EnginePath,

        [switch] $Force,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Put'
            Body       = @{
                EngineGuids = ''
            }
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

        $params.UriLeaf = "ProcessingEngines/Folder/{$($FolderObject.Guid)}"

        [string[]] $EngineGuids = @()

        foreach ($path in $EnginePath) {
            try {
                $engine = Get-TppObject -Path $path -VenafiSession $VenafiSession
            }
            catch {
                Write-Error ("TPP object '$($path)' does not exist")
                Continue
            }
            if ($engine.TypeName -ne 'Venafi Platform') {
                Write-Error ("TPP object '$($engine.Path)' is not a processing engine")
                Continue
            }
            $EngineGuids += "{$($engine.guid)}"
        }

        $params.Body.EngineGuids = @($EngineGuids)

        if ($EngineGuids.Count -gt 1) {
            $shouldProcessAction = "Assign $($EngineGuids.Count) processing engines"
        }
        else {
            $shouldProcessAction = "Assign processing engine $($engine.Name)"
        }

        if ($Force.IsPresent -or $PSCmdlet.ShouldProcess($FolderObject.Path, $shouldProcessAction)) {
            Invoke-VenafiRestMethod @params | Out-Null
        }
    }
}