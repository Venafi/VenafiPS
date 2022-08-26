<#
.SYNOPSIS
Get folders assigned to a TPP processing engine
.DESCRIPTION
Retrieves an array of policy folders assigned to a TPP processing engine.
.PARAMETER Path
The full DN path to a TPP processing engine.
.PARAMETER InputObject
TPPObject belonging to the 'Venafi Platform' class.
.PARAMETER Guid
Guid of a TPP processing engine.
.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token can also provided, but this requires an environment variable TPP_SERVER to be set.
.INPUTS
Path, Guid, TppObject
.OUTPUTS
TppObject[]
.EXAMPLE
Get-TppFoldersAssignedToEngine -Path '\VED\Engines\MYVENSERVER'
Get an array of policy folders assigned to the TPP processing engine 'MYVENSERVER'.
.EXAMPLE
[guid]'866e1d59-d5d2-482a-b9e6-7bb657e0f416' | Get-TppFoldersAssignedToEngine
Get an array of policy folders assigned to a TPP processing engine GUID.
.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppFoldersAssignedToEngine/
.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppFoldersAssignedToEngine.ps1
#>
function Get-TppEngineFolder
{
    [CmdletBinding()]

    param (
        [Parameter(Mandatory, ParameterSetName = 'ByPath', ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
            if ( $_ | Test-TppDnPath ) { $true }
            else { throw "'$_' is not a valid DN path" }
        })]
        [Alias('DN')]
        [String] $Path,

        [Parameter(ParameterSetName='ByObject', ValueFromPipeline)]
        [TppObject] $InputObject,

        [Parameter(Mandatory, ParameterSetName = 'ByGuid', ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Alias('ObjectGuid')]
        [guid] $Guid,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'
    }

    process {

        if ($PsCmdlet.ParameterSetName -ne 'ByObject') {
            $params = @{
                VenafiSession = $VenafiSession
            }
            if ($PsCmdlet.ParameterSetName -eq 'ByPath') {
                $params.Path = $Path
            }
            else {
                $params.Guid = $Guid
            }
            $InputObject = Get-TppObject @params
        }

        if ($InputObject.TypeName -eq 'Venafi Platform') {
            $apiLeaf = "ProcessingEngines/Engine/{$($InputObject.Guid)}"
            $response = ((Invoke-VenafiRestMethod -VenafiSession $VenafiSession -Method Get -UriLeaf $apiLeaf).Folders)
            foreach ($item in $response) {
                $folder = Get-TppObject -Guid ($item.FolderGuid) -VenafiSession $VenafiSession
                # Add return valid policy objects. i.e. omit the engine link to itself.
                if ($folder.TypeName -eq 'Policy') { $folder }
            }
        }
    }
}