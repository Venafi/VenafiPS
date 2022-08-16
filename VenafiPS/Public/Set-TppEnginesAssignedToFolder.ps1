<#
.SYNOPSIS
Set (overwrite) TPP processing engine assignments for a policy folder
.DESCRIPTION
Set (overwrite) TPP processing engine assignments for a policy folder.
.PARAMETER FolderPath
The full DN path to a policy folder.
.PARAMETER FolderObject
TPPObject belonging to the 'Policy' class.
.PARAMETER EnginePath
The full DN path to one or more TPP processing engines (string array).
.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token can also provided, but this requires an environment variable TPP_SERVER to be set.
.INPUTS
FolderPath or FolderObject, EnginePath[]
.OUTPUTS
None
.EXAMPLE
Set-TppEnginesAssignedToFolder -FolderPath '\VED\Policy\Certificates\Web Team' -EnginePath @('\VED\Engines\MYVENAFI01','\VED\Engines\MYVENAFI02')
Assigns processing engines MYVENAFI01 and MYVENAFI02 to the policy folder '\VED\Policy\Certificates\Web Team'. Existing engine assignments are overwritten.
.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppEnginesAssignedToFolder/
.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Set-TppEnginesAssignedToFolder.ps1
.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-PUT-ProcessingEngines-Folder-fguid.php
#>
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