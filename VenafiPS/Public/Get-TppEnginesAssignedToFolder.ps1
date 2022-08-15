<#
.SYNOPSIS
Get TPP processing engine(s) assigned to a folder
.DESCRIPTION
Retrieves an array of TPP processing engines assigned to a policy folder.
.PARAMETER Path
The full DN path to a policy folder.
.PARAMETER InputObject
TPPObject belonging to the 'Policy' class.
.PARAMETER Guid
Guid of a policy folder.
.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token can also provided, but this requires an environment variable TPP_SERVER to be set.
.INPUTS
Path, Guid, TppObject
.OUTPUTS
TppObject[]
.EXAMPLE
Get-TppEnginesAssignedToFolder -Path '\VED\Policy\Certificates\Web Team'
Get an array of TPP processing engines assigned to the policy folder '\VED\Policy\Certificates\Web Team'.
.EXAMPLE
[guid]'e9cf029d-6efe-486d-8bdd-4fceed07b295' | Get-TppEnginesAssignedToFolder
Get an array of TPP processing engines assigned to a policy folder GUID.
.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppEnginesAssignedToFolder/
.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppEnginesAssignedToFolder.ps1
#>
function Get-TppEnginesAssignedToFolder
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

        if ($InputObject.TypeName -eq 'Policy') {
            $apiLeaf = "ProcessingEngines/Folder/{$($InputObject.Guid)}"
            $response = ((Invoke-VenafiRestMethod -VenafiSession $VenafiSession -Method Get -UriLeaf $apiLeaf).Engines)
            foreach ($item in $response) {
                $engine = Get-TppObject -Guid ($item.EngineGuid) -VenafiSession $VenafiSession
                # Add return valid policy objects. i.e. omit the engine link to itself.
                if ($engine.TypeName -eq 'Venafi Platform') { $engine }
            }
        }
    }
}