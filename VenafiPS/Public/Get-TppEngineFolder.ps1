<#
.SYNOPSIS
Get TPP folder/engine assignments
.DESCRIPTION
When the input is a policy folder, retrieves an array of assigned TPP processing engines.
When the input is a TPP engine, retrieves an array of assigned policy folders.
If there are no matching assignments, nothing will be returned.
.PARAMETER Path
The full DN path to a TPP processing engine or policy folder.
.PARAMETER InputObject
TPPObject belonging to the 'Venafi Platform' or 'Policy' class.
.PARAMETER Guid
Guid of a TPP processing engine or policy folder.
.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token can also provided, but this requires an environment variable TPP_SERVER to be set.
.INPUTS
Path, Guid, TppObject
.OUTPUTS
TppObject[]
.EXAMPLE
Get-TppEngineFolder -Path '\VED\Engines\MYVENSERVER'
Get an array of policy folders assigned to the TPP processing engine 'MYVENSERVER'.
.EXAMPLE
Get-TppEngineFolder -Path '\VED\Policy\Certificates\Web Team'
Get an array of TPP processing engines assigned to the policy folder '\VED\Policy\Certificates\Web Team'.
.EXAMPLE
[guid]'866e1d59-d5d2-482a-b9e6-7bb657e0f416' | Get-TppEngineFolder
When the GUID is assigned to a TPP processing engine, returns an array of assigned policy folders.
When the GUID is assigned to a policy folder, returns an array of assigned TPP processing engines.
Otherwise nothing will be returned.
.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppEngineFolder/
.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppEngineFolder.ps1
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

        [Parameter(ParameterSetName = 'ByObject', ValueFromPipeline)]
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
            # If our input isn't TppObject we don't have the TypeName needed to determine behavior
            $InputObject = Get-TppObject @params
        }

        if ($InputObject.TypeName -eq 'Venafi Platform') {
            $apiLeaf = "ProcessingEngines/Engine/{$($InputObject.Guid)}"
            $response = ((Invoke-VenafiRestMethod -VenafiSession $VenafiSession -Method Get -UriLeaf $apiLeaf).Folders)
            foreach ($item in $response) {
                $folder = Get-TppObject -Guid ($item.FolderGuid) -VenafiSession $VenafiSession
                # Return valid policy objects. i.e. omit the engine link to itself.
                if ($folder.TypeName -eq 'Policy') { $folder }
            }
        }
        elseif ($InputObject.TypeName -eq 'Policy') {
            $apiLeaf = "ProcessingEngines/Folder/{$($InputObject.Guid)}"
            $response = ((Invoke-VenafiRestMethod -VenafiSession $VenafiSession -Method Get -UriLeaf $apiLeaf).Engines)
            foreach ($item in $response) {
                $engine = Get-TppObject -Guid ($item.EngineGuid) -VenafiSession $VenafiSession
                # This call should only return engines, but filter for consistency anyway.
                if ($engine.TypeName -eq 'Venafi Platform') { $engine }
            }
        }
    }
}