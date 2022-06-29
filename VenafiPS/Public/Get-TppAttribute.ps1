function Get-TppAttribute {
    <#
    .SYNOPSIS
    Get object attributes as well as policies (policy attributes)

    .DESCRIPTION
    Retrieves object attributes as well as policies (aka policy attributes).
    You can either retrieve all attributes or individual ones.
    By default, the attributes returned are not the effective policy, but that can be requested with the -Effective switch.
    Policy folders can have attributes as well as policies which apply to the resultant objects.
    For more info on policies and how they are different than attributes, see https://docs.venafi.com/Docs/current/TopNav/Content/Policies/c_policies_tpp.php.

    .PARAMETER Path
    Path to the object to retrieve configuration attributes.  Just providing DN will return all attributes.

    .PARAMETER Attribute
    Only retrieve the value/values for this attribute

    .PARAMETER Effective
    Get the objects attribute value, once policies have been applied.
    This is not applicable to policies, only objects.
    The output will contain the path where the policy was applied from.

    .PARAMETER All
    Get all object attribute values.
    This will perform 3 steps, get the object type, enumerate the attributes for the object type, and get all the values.
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
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    Path

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -New

    Name                          : test.gdb.com
    Path                          : \VED\Policy\Certificates\test.gdb.com
    TypeName                      : X509 Server Certificate
    Guid                          : b7a7221b-e038-41d9-9d49-d7f45c1ca128
    ServiceNow Assignment Group   : @{Value=Venafi Management; CustomFieldGuid={7f214dec-9878-495f-a96c-57291f0d42da}}
    ServiceNow CI                 : @{Value=9cc047ed1bad81100774ebd1b24bcbd0;
                                    CustomFieldGuid={a26df613-595b-46ef-b5df-79f6eace72d9}}
    Certificate Vault Id          : @{Value=442493; CustomFieldGuid=}
    Consumers                     : @{Value=System.Object[]; CustomFieldGuid=}
    Created By                    : @{Value=WebAdmin; CustomFieldGuid=}
    CSR Vault Id                  : @{Value=442492; CustomFieldGuid=}

    Retrieve values directly set on an object, excluding values assigned by policy

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -Attribute 'Driver Name' -New

    Name        : test.gdb.com
    Path        : \VED\Policy\Certificates\test.gdb.com
    TypeName    : X509 Server Certificate
    Guid        : b7a7221b-e038-41d9-9d49-d7f45c1ca128
    Driver Name : @{Value=appx509certificate; CustomFieldGuid=}

    Retrieve the value for a specific attribute

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -Attribute 'ServiceNow Assignment Group' -New

    Name                        : test.gdb.com
    Path                        : \VED\Policy\Certificates\test.gdb.com
    TypeName                    : X509 Server Certificate
    Guid                        : b7a7221b-e038-41d9-9d49-d7f45c1ca199
    ServiceNow Assignment Group : @{Value=Venafi Management; CustomFieldGuid={7f214dec-9878-495f-a96c-57291f0d42da}}

    Retrieve the value for a custom field.
    You can specify either the guid or custom field label name.

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -Attribute 'Organization','State' -Effective -New

    Name         : test.gdb.com
    Path         : \VED\Policy\Certificates\test.gdb.com
    TypeName     : X509 Server Certificate
    Guid         : b7a7221b-e038-41d9-9d49-d7f45c1ca128
    Organization : @{Value=Venafi, Inc.; CustomFieldGuid=; Overridden=False; Locked=True;
                PolicyPath=\VED\Policy\Certificates}
    State        : @{Value=UT; CustomFieldGuid=; Overridden=False; Locked=False; PolicyPath=\VED\Policy\Certificates}

    Retrieve the effective (policy applied) value for a specific attribute(s).
    This not only returns the value, but also the path where the policy is applied and if locked or overridden.

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -Effective -All -New

    Name                                               : test.gdb.com
    Path                                               : \VED\Policy\certificates\test.gdb.com
    TypeName                                           : X509 Server Certificate
    ServiceNow Assignment Group                        : @{Value=Venafi Management;
                                                        CustomFieldGuid={7f214dec-9878-495f-a96c-57291f0d42da};
                                                        Overridden=False; Locked=False; PolicyPath=}
    ServiceNow CI                                      : @{Value=9cc047ed1bad81100774ebd1b24bcbd0;
                                                        CustomFieldGuid={a26df613-595b-46ef-b5df-79f6eace72d9};
                                                        Overridden=False; Locked=False; PolicyPath=}
    ACME Account DN                                    :
    Adaptable CA:Binary Data Vault ID                  :
    Adaptable CA:Early Password Vault ID               :
    Adaptable CA:Early Pkcs7 Vault ID                  :
    Adaptable CA:Early Private Key Vault ID            :

    Retrieve the effective (policy applied) value for all attributes.
    This not only returns the value, but also the path where the policy is applied and if locked or overridden.

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

    Retrieve values for all attributes applicable to this object

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates' -PolicyClass 'X509 Certificate' -Attribute 'State' -New

    Name            : certificates
    Path            : \VED\Policy\certificates
    TypeName        : Policy
    Guid            : a91fc152-a9fb-4b49-a7ca-7014b14d73eb
    PolicyClassName : X509 Certificate
    State           : @{Value=UT; Locked=False}

    Retrieve specific policy attribute values for the specified policy folder and class

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates' -PolicyClass 'X509 Certificate' -All -New

    Name                                               : certificates
    Path                                               : \VED\Policy\certificates
    TypeName                                           : Policy
    PolicyClassName                                    : X509 Certificate
    ServiceNow Assignment Group                        :
    Certificate Authority                              :
    Certificate Download: PBES2 Algorithm              :
    Certificate Process Validator                      :
    Certificate Vault Id                               :
    City                                               : @{Value=Salt Lake City; Locked=False}

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

        [Parameter(Mandatory, ParameterSetName = 'ByPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'AllByPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Effective', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'AllEffective', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Policy', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'AllPolicy', ValueFromPipeline, ValueFromPipelineByPropertyName)]
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

        [Parameter(Mandatory, ParameterSetName = 'Effective')]
        [Parameter(ParameterSetName = 'ByPath')]
        [Parameter(Mandatory, ParameterSetName = 'Policy')]
        [ValidateNotNullOrEmpty()]
        [String[]] $Attribute,

        [Parameter(Mandatory, ParameterSetName = 'Effective')]
        [Parameter(Mandatory, ParameterSetName = 'AllEffective')]
        [Alias('EffectivePolicy')]
        [Switch] $Effective,

        [Parameter(Mandatory, ParameterSetName = 'AllByPath')]
        [Parameter(Mandatory, ParameterSetName = 'AllEffective')]
        [Parameter(Mandatory, ParameterSetName = 'AllPolicy')]
        [switch] $All,

        [Parameter(ParameterSetName = 'Policy')]
        [Parameter(ParameterSetName = 'AllPolicy')]
        [switch] $Policy,

        [Parameter(Mandatory, ParameterSetName = 'Policy')]
        [Parameter(Mandatory, ParameterSetName = 'AllPolicy')]
        [ValidateNotNullOrEmpty()]
        [Alias('ClassName')]
        [string] $PolicyClass,

        [Parameter(ParameterSetName = 'Effective')]
        [Parameter(ParameterSetName = 'ByPath')]
        [Parameter(ParameterSetName = 'Policy')]
        [switch] $AsValue,

        [Parameter()]
        [switch] $New,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        Write-Debug $PSCmdlet.ParameterSetName

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        if ( -not $New ) { Write-Warning 'The output format of this function will change in a future release.  Please use the new format with -New.' }
        if ( $AsValue ) { Write-Warning '-AsValue wil be deprecated in a future release.  Please use the new format with -New.' }
        if ( $Policy ) { Write-Warning '-Policy is no longer required; just provide -PolicyClass to find policy attributes.' }

        if ( $All -and $PolicyClass ) {
            Write-Verbose "Getting attributes for class $PolicyClass"
            $Attribute = Get-TppClassAttribute -ClassName $PolicyClass -VenafiSession $VenafiSession | Select-Object -ExpandProperty Name
        }

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            Body          = @{}
        }

        $isEffective = $false
        switch ( $PSCmdlet.ParameterSetName ) {
            { $_ -in 'Policy', 'AllPolicy' } {
                $params.uriLeaf = 'config/ReadPolicy'
                break
            }

            { $_ -in 'Effective', 'AllEffective' } {
                $params.uriLeaf = 'config/ReadEffectivePolicy'
                $isEffective = $true
                break
            }

            'AllByPath' {
                # use config/read instead of config/readall as we will get list of attributes for this class first
                # and then get all the values for them
                $params.uriLeaf = 'config/read'
                break
            }

            Default {
                if ( $PSBoundParameters.ContainsKey('Attribute') ) {
                    $params.uriLeaf = 'config/read'
                } else {
                    $params.uriLeaf = 'config/readall'
                }
            }
        }
    }

    process {

        $params.Body.ObjectDN = $Path
        $thisObject = Get-TppObject -Path $Path -VenafiSession $VenafiSession

        if ( $PolicyClass -and $thisObject.TypeName -ne 'Policy' ) {
            Write-Error ('You are attempting to retrieve policy attributes, but {0} is not a policy path' -f $Path)
            continue
        }

        # get all attributes if item is an object other than a policy
        if ( $All -and -not $PolicyClass ) {
            $Attribute = Get-TppClassAttribute -ClassName $thisObject.TypeName -VenafiSession $VenafiSession | Select-Object -ExpandProperty Name
        }

        if ( $Attribute ) {

            # get the attribute values one by one as there is no
            # api which allows passing a list
            $configValues = foreach ($thisAttribute in $Attribute) {

                $customField = $VenafiSession.CustomField | Where-Object { $_.Label -eq $thisAttribute -or $_.Guid -eq $thisAttribute }

                if ( $customField ) {
                    $params.Body.AttributeName = $customField.Guid
                } else {
                    $params.Body.AttributeName = $thisAttribute
                }

                # add the class for a policy call
                if ( $PolicyClass ) {
                    $params.Body.Class = $PolicyClass
                }

                $response = Invoke-VenafiRestMethod @params

                if ( $response.Error ) {
                    if ( $response.Result -eq 601) {
                        Write-Error "'$thisAttribute' is not a valid attribute for $Path"
                        continue
                    } elseif ( $response.Result -eq 102) {
                        # attribute is valid, but value not set
                        # we're ok with this one
                    } else {
                        Write-Error $response.Error
                        continue
                    }
                }

                [PSCustomObject] @{
                    Name       = $thisAttribute
                    Value      = $response.Values
                    PolicyPath = $response.PolicyDN
                    Locked     = $response.Locked
                    Overridden = $response.Overridden
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

                if ( $PSBoundParameters.ContainsKey('PolicyClass') ) {
                    Add-Member -InputObject $return -NotePropertyMembers @{ 'PolicyClassName' = $PolicyClass }
                }

                # no customfieldname for policy attribs

                foreach ($thisConfigValue in $configValues) {

                    # attribute name will be overridden to use the label if a custom field
                    $newAttributeName = $thisConfigValue.Name

                    $customField = $VenafiSession.CustomField | Where-Object { $_.Guid -eq $thisConfigValue.Name -or $_.Label -eq $thisConfigValue.Name }

                    # add this attribute as the custom field label instead of guid
                    if ( $customField ) {
                        $newAttributeName = $customField.Label
                    }

                    if ( -not $thisConfigValue.Value ) {
                        Add-Member -InputObject $return -NotePropertyMembers @{ $newAttributeName = $null } -Force
                        continue
                    }

                    $valueOut = $null

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
                        $newProp = [pscustomobject] @{
                            Value  = $valueOut
                            Locked = $thisConfigValue.Locked
                        }
                    } else {

                        $newProp = [pscustomobject] @{
                            'Value'           = $valueOut
                            'CustomFieldGuid' = $customField.Guid
                        }

                        if ( $isEffective ) {
                            $newProp | Add-Member @{
                                'PolicyPath' = $thisConfigValue.PolicyPath
                                'Locked'     = $thisConfigValue.Locked
                                'Overridden' = $thisConfigValue.Overridden
                            }
                        }
                    }

                    Add-Member -InputObject $return -NotePropertyMembers @{ $newAttributeName = $newProp } -Force

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