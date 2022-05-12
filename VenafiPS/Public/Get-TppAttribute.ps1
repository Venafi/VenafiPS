function Get-TppAttribute {
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

    .PARAMETER PolicyClass
    Get policies (aka policy attributes) instead of object attributes.
    Provide the class name to retrieve the value for.
    If unsure of the class name, add the value through the TPP UI and go to Support->Policy Attributes to find it.

    .PARAMETER New
    New output format which returns 1 object with multiple properties instead of an object per property

    .PARAMETER Policy
    Deprecated.  To retrieve policy attributes, just provide -PolicyClass.

    .PARAMETER AsValue
    Deprecated.  No longer required with -New format.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TppServer must also be set.

    .INPUTS
    Path

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -New

    Name                                   : test.gdb.com
    Path                                   : \ved\policy\certificates\test.gdb.com
    TypeName                               : X509 Server Certificate
    Guid                                   : b7a7221b-e038-41d9-9d49-d7f45c1ca128
    Certificate Vault Id                   : @{Value=442493; CustomFieldName=; PolicyPath=}
    Consumers                              : @{Value=System.Object[]; CustomFieldName=; PolicyPath=}
    Created By                             : @{Value=WebAdmin; CustomFieldName=; PolicyPath=}

    Retrieve all values for an object, excluding values assigned by policy

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -Attribute 'Driver Name' -New

    Name        : test.gdb.com
    Path        : \ved\policy\certificates\test.gdb.com
    TypeName    : X509 Server Certificate
    Guid        : b7a7221b-e038-41d9-9d49-d7f45c1ca128
    Driver Name : @{Value=appx509certificate; CustomFieldName=; PolicyPath=}

    Retrieve the value for a specific attribute

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -AttributeName 'State' -Effective -New

    Name     : test.gdb.com
    Path     : \ved\policy\certificates\test.gdb.com
    TypeName : X509 Server Certificate
    Guid     : b7a7221b-e038-41d9-9d49-d7f45c1ca128
    State    : @{Value=UT; CustomFieldName=; PolicyPath=\VED\Policy\Certificates}

    Retrieve the effective (policy applied) value for a specific attribute.
    This not only returns the value, but also the path where the policy is applied.

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -All -New

    Name                 : test.gdb.com
    Path                 : \ved\policy\certificates\test.gdb.com
    TypeName             : X509 Server Certificate
    Guid                 : b7a7221b-e038-41d9-9d49-d7f45c1ca128
    Certificate Vault Id : @{Value=442493; CustomFieldName=; PolicyPath=}
    City                 : @{Value=Salt Lake City; CustomFieldName=; PolicyPath=\VED\Policy\Certificates}
    Consumers            : @{Value=System.Object[]; CustomFieldName=; PolicyPath=}
    Created By           : @{Value=WebAdmin; CustomFieldName=; PolicyPath=}
    State                : @{Value=UT; CustomFieldName=; PolicyPath=\VED\Policy\Certificates}

    Retrieve all effective values for an object

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates' -PolicyClass 'X509 Certificate' -AttributeName 'State' -New

    Name            : certificates
    Path            : \ved\policy\certificates
    TypeName        : Policy
    Guid            : a91fc152-a9fb-4b49-a7ca-7014b14d73eb
    PolicyClassName : x509 certificate
    State           : UT

    Retrieve specific policy attribute values for the specified policy folder and class

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates' -PolicyClass 'X509 Certificate' -All -New

    Name            : certificates
    Path            : \ved\policy\certificates
    TypeName        : Policy
    Guid            : a91fc152-a9fb-4b49-a7ca-7014b14d73eb
    PolicyClassName : x509 certificate
    City            : Salt Lake City
    Country         : US
    Management Type : Enrollment
    Organization    : Venafi, Inc.
    State           : UT

    Retrieve all policy attribute values for the specified policy folder and class

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
    [CmdletBinding(DefaultParameterSetName = 'ByPath')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'EffectiveByPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'ByPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'AllEffectivePath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'PolicyPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'AllPolicyPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                } else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('DN')]
        [String] $Path,

        [Parameter(Mandatory, ParameterSetName = 'EffectiveByPath')]
        [Parameter(ParameterSetName = 'ByPath')]
        [Parameter(Mandatory, ParameterSetName = 'PolicyPath')]
        [ValidateNotNullOrEmpty()]
        [String[]] $Attribute,

        [Parameter(Mandatory, ParameterSetName = 'EffectiveByPath')]
        [Alias('EffectivePolicy')]
        [Switch] $Effective,

        [Parameter(Mandatory, ParameterSetName = 'AllEffectivePath')]
        [Parameter(Mandatory, ParameterSetName = 'AllPolicyPath')]
        [switch] $All,

        [Parameter(ParameterSetName = 'PolicyPath')]
        [Parameter(ParameterSetName = 'AllPolicyPath')]
        [switch] $Policy,

        [Parameter(Mandatory, ParameterSetName = 'PolicyPath')]
        [Parameter(Mandatory, ParameterSetName = 'AllPolicyPath')]
        [Alias('ClassName')]
        [string] $PolicyClass,

        [Parameter(ParameterSetName = 'EffectiveByPath')]
        [Parameter(ParameterSetName = 'ByPath')]
        [Parameter(ParameterSetName = 'PolicyPath')]
        [switch] $AsValue,

        [Parameter()]
        [switch] $New,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        if ( $AsValue ) { Write-Warning '-AsValue wil be deprecated in a future release.  Please use the new format with -New.' }
        if ( $Policy ) { Write-Warning '-Policy is no longer required; just provide -PolicyClass to find policy attributes.' }

        if ( $All -and $PolicyClass ) {
            Write-Verbose "Getting attributes for class $PolicyClass"
            $Attribute = Get-TppClassAttribute -ClassName $PolicyClass -VenafiSession $VenafiSession | Select-Object -ExpandProperty Name
        }
    }

    process {

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            Body          = @{
                ObjectDN = $Path
            }
        }

        if ( $PolicyClass ) {
            $params.uriLeaf = 'config/ReadPolicy'
        } else {
            if ( $PSBoundParameters.ContainsKey('Attribute') ) {
                if ( $Effective ) {
                    $params.uriLeaf = 'config/ReadEffectivePolicy'
                } else {
                    $params.uriLeaf = 'config/read'
                }
            } else {
                if ( $All ) {
                    $params.uriLeaf = 'config/ReadEffectivePolicy'
                } else {
                    $params.uriLeaf = 'config/readall'
                }
            }
        }
        # $baseParams.UriLeaf = $uriLeaf

        # $baseParams.Body['ObjectDN'] = $Path
        $thisObject = Get-TppObject -Path $Path -VenafiSession $VenafiSession

        if ( $PolicyClass -and $thisObject.TypeName -ne 'Policy' ) {
            Write-Error ('You are attempting to retrieve policy attributes, but {0} is not a policy path' -f $Path)
            continue
        }

        if ( $All -and -not $PolicyClass ) {
            $Attribute = Get-TppClassAttribute -ClassName $thisObject.TypeName -VenafiSession $VenafiSession | Select-Object -ExpandProperty Name
        }

        if ( $Attribute ) {

            # get the attribute values one by one as there is no
            # api which allows passing a list
            $configValues = foreach ($thisAttribute in $Attribute) {

                $params.Body.AttributeName = $thisAttribute

                # add the class for a policy call
                if ( $PolicyClass ) {
                    $params.Body.Class = $PolicyClass
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
        } else {
            $response = Invoke-VenafiRestMethod @params
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

            if ( $AsValue ) {
                if ( $configValues.Count -eq 1 ) {
                    return $configValues.Value
                } else {
                    Write-Warning '-AsValue can only be used for 1 attribute'
                }
            }

            if ( $New ) {

                $return = [pscustomobject] @{
                    Name     = $thisObject.Name
                    Path     = $Path
                    TypeName = $thisObject.TypeName
                    Guid     = $thisObject.Guid
                }

                if ( $PolicyClass ) {
                    Add-Member -InputObject $return -NotePropertyMembers @{ 'PolicyClassName' = $PolicyClass }
                }
                # no customfieldname for policy attribs

                foreach ($thisConfigValue in $configValues) {

                    $valueOut = $null

                    if ( -not $thisConfigValue.Value ) { continue }

                    switch ($thisConfigValue.Value.GetType().Name) {
                        'Object[]' {
                            switch ($thisConfigValue.Value.Count) {
                                0 {
                                    $valueOut = $null
                                }

                                1 {
                                    $valueOut = $thisConfigValue.Value[0]
                                }

                                Default {
                                    $valueOut = $thisConfigValue.Value
                                }
                            }
                        }
                        Default {
                            $valueOut = $thisConfigValue.Value
                        }
                    }

                    if ( $PolicyClass ) {
                        $newProp = $valueOut
                    } else {

                        $customField = $VenafiSession.CustomField | Where-Object { $_.Guid -eq $thisConfigValue.Name }
                        $newProp = [pscustomobject] @{
                            'Value'           = $valueOut
                            'CustomFieldName' = $customField.Label
                            'PolicyPath'      = $thisConfigValue.PolicyPath
                        }
                    }
                    Add-Member -InputObject $return -NotePropertyMembers @{ $thisConfigValue.Name = $newProp } -Force

                }

                $return

            } else {

                # convert custom field guids to names
                foreach ($thisConfigValue in $configValues) {

                    $customField = $VenafiSession.CustomField | Where-Object { $_.Guid -eq $thisConfigValue.Name }

                    $thisConfigValue | Add-Member @{
                        'IsCustomField' = [bool] $customField
                        'CustomName'    = $customField.Label
                    }

                    $thisConfigValue
                }
            }


        }
    }
}