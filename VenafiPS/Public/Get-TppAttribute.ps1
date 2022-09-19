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
    Only retrieve the value/values for this attribute.
    Custom fields can use either its Guid or its Label and it will be automatically handled.
    All custom fields will have the Guid for that field added to the output.

    .PARAMETER Effective
    Get the objects attribute value, once policies have been applied.
    When used on a Policy, it will only return attributes that apply to the Policy Folder object (i.e. not attributes for the X509 Certificate class).
    The output will contain the path where the policy was applied from if available.

    .PARAMETER All
    Get all object attribute values.
    This will perform 3 steps, get the object type, enumerate the attributes for the object type, and get all the values.
    Note, expect this to take longer than usual given the number of api calls.

    .PARAMETER Class
    Get policies (aka policy attributes) instead of object attributes.
    Provide the class name to retrieve the value for.
    If unsure of the class name, add the value through the TPP UI and go to Support->Policy Attributes to find it.
    The output will contain the path where the policy was applied from if available.

    .PARAMETER New
    New output format which returns 1 object with multiple properties instead of an object per property

    .PARAMETER Policy
    Deprecated.  To retrieve policy attributes, just provide -Class.

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
    Consumers                     : @{Value=System.Object[]}
    Created By                    : @{Value=WebAdmin}
    CSR Vault Id                  : @{Value=442492}

    Retrieve values directly set on an object, excluding values assigned by policy

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -Attribute 'Driver Name' -New

    Name        : test.gdb.com
    Path        : \VED\Policy\Certificates\test.gdb.com
    TypeName    : X509 Server Certificate
    Guid        : b7a7221b-e038-41d9-9d49-d7f45c1ca128
    Driver Name : @{Value=appx509certificate}

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
    Organization : @{Value=Venafi, Inc.; Overridden=False; Locked=True; PolicyPath=\VED\Policy\Certificates}
    State        : @{Value=UT; Overridden=False; Locked=False; PolicyPath=\VED\Policy\Certificates}

    Retrieve the effective (policy applied) value for a specific attribute(s).
    This not only returns the value, but also the path where the policy is applied and if locked or overridden.

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates\test.gdb.com' -Effective -All -New

    Name                                               : test.gdb.com
    Path                                               : \VED\Policy\certificates\test.gdb.com
    TypeName                                           : X509 Server Certificate
    ServiceNow Assignment Group                        : @{Value=Venafi Management;
                                                        CustomFieldGuid={7f214dec-9878-495f-a96c-57291f0d42da};
                                                        Overridden=False; Locked=False}
    ServiceNow CI                                      : @{Value=9cc047ed1bad81100774ebd1b24bcbd0;
                                                        CustomFieldGuid={a26df613-595b-46ef-b5df-79f6eace72d9};
                                                        Overridden=False; Locked=False}
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
    Certificate Vault Id : @{Value=442493}
    City                 : @{Value=Salt Lake City; PolicyPath=\VED\Policy\Certificates}
    Consumers            : @{Value=System.Object[]}
    Created By           : @{Value=WebAdmin}
    State                : @{Value=UT; PolicyPath=\VED\Policy\Certificates}

    Retrieve values for all attributes applicable to this object

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates' -Class 'X509 Certificate' -Attribute 'State' -New

    Name            : certificates
    Path            : \VED\Policy\certificates
    TypeName        : Policy
    Guid            : a91fc152-a9fb-4b49-a7ca-7014b14d73eb
    ClassName : X509 Certificate
    State           : @{Value=UT; Locked=False}

    Retrieve specific policy attribute values for the specified policy folder and class

    .EXAMPLE
    Get-TppAttribute -Path '\VED\Policy\certificates' -Class 'X509 Certificate' -All -New

    Name                                               : certificates
    Path                                               : \VED\Policy\certificates
    TypeName                                           : Policy
    ClassName                                    : X509 Certificate
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
    [CmdletBinding(DefaultParameterSetName = 'Attribute')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'Attribute', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'All', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('DN')]
        [String] $Path,

        [Parameter(Mandatory, ParameterSetName = 'Attribute')]
        [ValidateNotNullOrEmpty()]
        [String[]] $Attribute,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch] $All,

        [ValidateNotNullOrEmpty()]
        [Alias('ClassName', 'PolicyClass')]
        [string] $Class,

        [Parameter(ParameterSetName = 'Attribute')]
        [switch] $AsValue,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        Write-Debug $PSCmdlet.ParameterSetName

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        if ( $AsValue -and (@($Attribute).Count -gt 1 ) ) {
            throw '-AsValue can only be used for 1 attribute'
        }

        $newAttribute = $Attribute
        if ( $All -and $Class ) {
            Write-Verbose "Getting attributes for class $Class"
            $newAttribute = Get-TppClassAttribute -ClassName $Class -VenafiSession $VenafiSession | Select-Object -ExpandProperty Name -Unique
        }

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            Body          = @{}
            UriLeaf       = 'config/ReadEffectivePolicy'
        }

        if ( $PSBoundParameters.ContainsKey('Class') ) {
            $params.UriLeaf = 'config/FindPolicy'
            $params.Body.Class = $Class
        }
    }

    process {

        $newPath = $Path | ConvertTo-TppFullPath
        $thisObject = Get-TppObject -Path $newPath -VenafiSession $VenafiSession

        if ( $PSBoundParameters.ContainsKey('Class') -and $thisObject.TypeName -ne 'Policy' ) {
            Write-Error ('You are attempting to retrieve policy attributes, but {0} is not a policy path' -f $Path)
            continue
        }

        # get all attributes if item is an object other than a policy
        if ( $All -and -not $Class ) {
            $newAttribute = Get-TppClassAttribute -ClassName $thisObject.TypeName -VenafiSession $VenafiSession | Select-Object -ExpandProperty Name -Unique
        }

        $params.Body.ObjectDN = $newPath

        $return = [pscustomobject] @{
            Name      = $thisObject.Name
            Path      = $newPath
            TypeName  = $thisObject.TypeName
            Guid      = $thisObject.Guid
            Attribute = [pscustomobject] @{}
        }

        if ( $PSBoundParameters.ContainsKey('Class') ) {
            $return | Add-Member @{ 'ClassName' = $Class }
        }

        $allAttributes = foreach ($thisAttribute in $newAttribute) {

            Write-Verbose "Processing attribute $thisAttribute"

            $customField = $VenafiSession.CustomField | Where-Object { $_.Label -eq $thisAttribute -or $_.Guid -eq $thisAttribute }

            if ( $customField ) {
                $params.Body.AttributeName = $customField.Guid
            } else {
                $params.Body.AttributeName = $thisAttribute
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

            $valueOut = $null

            if ( $response.Values ) {
                switch ($response.Values.GetType().Name) {
                    'Object[]' {
                        switch ($response.Values.Count) {
                            1 {
                                $valueOut = $response.Values[0]
                            }

                            Default {
                                $valueOut = $response.Values
                            }
                        }
                    }
                    Default {
                        $valueOut = $response.Values
                    }
                }
            }

            if ( $AsValue ) {
                return $valueOut
            }

            $newProp = [pscustomobject] @{}

            if ( $CustomField ) {
                $newProp | Add-Member @{
                    Name              = $customField.Label
                    'CustomFieldGuid' = $customField.Guid
                }

                if ( $valueOut ) {
                    $return | Add-Member @{ $customField.Label = $valueOut }
                }

            } else {

                if ( $valueOut ) {
                    $return | Add-Member @{ $thisAttribute = $valueOut } -ErrorAction SilentlyContinue
                }

                $newProp | Add-Member @{ Name = $thisAttribute }
            }

            $newProp | Add-Member @{
                Value      = $valueOut
                PolicyPath = $response.PolicyDN
                Locked     = $response.Locked
            }

            # overridden not available at policy level
            if ( -not $PSBoundParameters.ContainsKey('Class') ) {
                $newProp | Add-Member @{ 'Overridden' = $response.Overridden }
            }

            $newProp

        }

        $return.Attribute = @($allAttributes)
        $return

    }
}