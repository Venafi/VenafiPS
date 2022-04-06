<#
.SYNOPSIS
Get object attributes as well as policies (policy attributes)

.DESCRIPTION
Retrieves object attributes as well as policies (aka policy attributes).
You can either retrieve all attributes or individual ones.
By default, the attributes returned are not the effective policy, but that can be requested with the
Effective switch.
Policy folders can have attributes as well as policies which apply to the resultant objects.
For more info on policies and how they are different than attributes, see https://docs.venafi.com/Docs/current/TopNav/Content/Policies/c_policies_tpp.php.

.PARAMETER Path
Path to the object to retrieve configuration attributes.  Just providing DN will return all attributes.

.PARAMETER Guid
To be deprecated; use -Path instead.
Object Guid.  Just providing Guid will return all attributes.

.PARAMETER Attribute
Only retrieve the value/values for this attribute

.PARAMETER Effective
Get the objects attribute value, once policies have been applied.
This is not applicable to policies, only objects.

.PARAMETER All
Get all effective object attribute values.
This will perform 3 steps, get the object type, enumerate the attributes for the object type, and get all the effective values.
The output will contain the path where the policy was applied from.
Note, expect this to take longer than usual given the number of api calls.

.PARAMETER Policy
Get policies (aka policy attributes) instead of object attributes

.PARAMETER ClassName
Required when getting policy attributes.  Provide the class name to retrieve the value for.
If unsure of the class name, add the value through the TPP UI and go to Support->Policy Attributes to find it.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.
A TPP token or VaaS key can also provided.

.INPUTS
Path

.OUTPUTS
PSCustomObject with properties:
- Name
- Value
- PolicyPath (only applicable with -All)
- IsCustomField (not applicable to policies)
- CustomName (not applicable to policies)

.EXAMPLE
Get-TppAttribute -Path '\VED\Policy\My Folder\myapp.company.com'
Retrieve all values for an object, excluding values assigned by policy

.EXAMPLE
Get-TppAttribute -Path '\VED\Policy\My Folder\myapp.company.com' -AttributeName 'driver name'
Retrieve the value for a specific attribute

.EXAMPLE
Get-TppAttribute -Path '\VED\Policy\My Folder\myapp.company.com' -AttributeName 'Contact' -Effective
Retrieve the effective value for a specific attribute

.EXAMPLE
Get-TppAttribute -Path '\VED\Policy\My Folder\myapp.company.com' -All
Retrieve all effective values for an object

.EXAMPLE
Get-TppAttribute -Path '\VED\Policy\My Folder' -Policy -Class 'X509 Certificate' -AttributeName 'Contact'
Retrieve the policy attribute value for the specified policy folder

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppAttribute/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppAttribute.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-read.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-readall.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-readeffectivepolicy.php

#>
function Get-TppAttribute {
    [CmdletBinding(DefaultParameterSetName = 'ByPath')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'EffectiveByPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'ByPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'AllEffectivePath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'PolicyPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('DN')]
        [String] $Path,

        [Parameter(Mandatory, ParameterSetName = 'EffectiveByGuid', ValueFromPipeline)]
        [Parameter(Mandatory, ParameterSetName = 'ByGuid', ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [guid] $Guid,

        [Parameter(Mandatory, ParameterSetName = 'EffectiveByPath')]
        [Parameter(ParameterSetName = 'ByPath')]
        [Parameter(Mandatory, ParameterSetName = 'EffectiveByGuid')]
        [Parameter(ParameterSetName = 'ByGuid')]
        [Parameter(Mandatory, ParameterSetName = 'PolicyPath')]
        [ValidateNotNullOrEmpty()]
        [String[]] $Attribute,

        [Parameter(Mandatory, ParameterSetName = 'EffectiveByPath')]
        [Parameter(Mandatory, ParameterSetName = 'EffectiveByGuid')]
        [Alias('EffectivePolicy')]
        [Switch] $Effective,

        [Parameter(Mandatory, ParameterSetName = 'AllEffectivePath')]
        [switch] $All,

        [Parameter(Mandatory, ParameterSetName = 'PolicyPath')]
        [switch] $Policy,

        [Parameter(Mandatory, ParameterSetName = 'PolicyPath')]
        [string] $ClassName,

        [Parameter()]
        [switch] $AsValue,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        if ( $Guid ) {
            Write-Warning '-Guid will be deprecated in a future release.  Please use -Path instead.'
        }

        $baseParams = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            Body          = @{
                ObjectDN = ''
            }
        }

        if ( $Policy ) {
            $uriLeaf = 'config/ReadPolicy'
        }
        else {
            if ( $PSBoundParameters.ContainsKey('Attribute') ) {
                if ( $Effective ) {
                    $uriLeaf = 'config/ReadEffectivePolicy'
                }
                else {
                    $uriLeaf = 'config/read'
                }
            }
            else {
                if ( $All ) {
                    $uriLeaf = 'config/ReadEffectivePolicy'
                }
                else {
                    $uriLeaf = 'config/readall'
                }
            }
        }
        $baseParams.UriLeaf = $uriLeaf
    }

    process {

        switch -Wildcard ($PSCmdlet.ParameterSetName) {
            '*Path' {
                $pathToProcess = $Path
            }

            '*Guid' {
                $pathToProcess = $Guid | ConvertTo-TppPath -VenafiSession $VenafiSession
            }
        }

        $baseParams.Body['ObjectDN'] = $pathToProcess

        if ( $All ) {
            $className = Get-TppObject -Path $pathToProcess -VenafiSession $VenafiSession | Select-Object -ExpandProperty TypeName
            $Attribute = Get-TppClassAttribute -ClassName $className -VenafiSession $VenafiSession | Select-Object -ExpandProperty Name
        }

        if ( $Attribute ) {

            # get the attribute values one by one as there is no
            # api which allows passing a list
            $configValues = foreach ($thisAttribute in $Attribute) {

                $params = $baseParams.Clone()
                $params.Body += @{
                    AttributeName = $thisAttribute
                }

                # add the class for a policy call
                if ( $ClassName ) {
                    $params.Body += @{
                        'Class' = $ClassName
                    }
                }

                $response = Invoke-VenafiRestMethod @params

                if ( $response ) {
                    [PSCustomObject] @{
                        Name       = $thisAttribute
                        Value      = $response.Values
                        PolicyPath = $response.PolicyDN
                    }
                }
            }
        }
        else {
            $response = Invoke-VenafiRestMethod @baseParams
            if ( $response ) {
                $configValues = $response.NameValues | Select-Object Name,
                @{
                    n = 'Value'
                    e = {
                        $_.Values
                    }
                }
            }
        }

        if ( $configValues ) {

            $configValues = @($configValues)

            if ( $configValues.Count -eq 1 -and $AsValue ) {
                return $configValues.Value
            }

            # convert custom field guids to names
            foreach ($thisConfigValue in $configValues) {

                $customField = $VenafiSession.CustomField | Where-Object { $_.Guid -eq $thisConfigValue.Name }
                $thisConfigValue | Add-Member @{
                    'IsCustomField' = [bool]$customField
                    'CustomName'    = $null
                }
                if ( $customField ) {
                    $thisConfigValue.CustomName = $customField.Label
                }

                $thisConfigValue
            }
        }
    }

    end {

    }
}