function Get-VdcAttribute {
    <#
    .SYNOPSIS
    Get object attributes as well as policy attributes

    .DESCRIPTION
    Retrieves object attributes as well as policy attributes.
    You can either retrieve all attributes or individual ones.
    Policy folders can have attributes as well as policies which apply to the resultant objects.
    For more info on policies and how they are different than attributes, see https://docs.venafi.com/Docs/current/TopNav/Content/Policies/c_policies_tpp.php.

    Attribute properties are directly added to the return object for ease of access.
    To retrieve attribute configuration, see the Attribute property of the return object which has properties
    Name, PolicyPath, Locked, Value, Overridden (when applicable), and CustomFieldGuid (when applicable).

    .PARAMETER Path
    Path to the object.  If the root is excluded, \ved\policy will be prepended.

    .PARAMETER Attribute
    Only retrieve the value/values for this attribute.
    For custom fields, you provided either the Guid or Label.

    .PARAMETER Class
    Get policy attributes instead of object attributes.
    Provide the class name to retrieve the value for.
    If unsure of the class name, add the value through the TPP UI and go to Support->Policy Attributes to find it.
    The Attribute property will contain the path where the policy was applied.

    .PARAMETER All
    Get all object attributes or policy attributes.
    This will perform 3 steps, get the object type, enumerate the attributes for the object type, and get all the values.
    Note, expect this to take longer than usual given the number of api calls.

    .PARAMETER NoLookup
    Default functionality is to perform lookup of attributes names to see if they are custom fields or not.
    If they are, pass along the guid instead of name required by the api for custom fields.
    To override this behavior and use the attribute name as is, add -NoLookup.
    Useful if on the off chance you have a custom field with the same name as a built-in attribute.
    Can also be used with -All and the output will contain guids instead of looked up names.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token can be provided directly.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    Path

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Get-VdcAttribute -Path '\VED\Policy\certificates\test.gdb.com' -Attribute 'State'

    Name      : test.gdb.com
    Path      : \VED\Policy\Certificates\test.gdb.com
    TypeName  : X509 Server Certificate
    Guid      : b7a7221b-e038-41d9-9d49-d7f45c1ca128
    Attribute : {@{Name=State; PolicyPath=\VED\Policy\Certificates; Locked=False; Value=UT; Overridden=False}}
    State     : UT

    Retrieve a single attribute

    .EXAMPLE
    Get-VdcAttribute -Path '\VED\Policy\certificates\test.gdb.com' -Attribute 'State', 'Driver Name'

    Name        : test.gdb.com
    Path        : \VED\Policy\Certificates\test.gdb.com
    TypeName    : X509 Server Certificate
    Guid        : b7a7221b-e038-41d9-9d49-d7f45c1ca128
    Attribute   : {@{Name=State; PolicyPath=\VED\Policy\Certificates; Locked=False; Value=UT; Overridden=False}, @{Name=Driver
                Name; PolicyPath=; Locked=False; Value=appx509certificate; Overridden=False}}
    State       : UT
    Driver Name : appx509certificate

    Retrieve multiple attributes

    .EXAMPLE
    Get-VdcAttribute -Path '\VED\Policy\certificates\test.gdb.com' -Attribute 'ServiceNow Assignment Group'

    Name                        : test.gdb.com
    Path                        : \VED\Policy\Certificates\test.gdb.com
    TypeName                    : X509 Server Certificate
    Guid                        : b7a7221b-e038-41d9-9d49-d7f45c1ca128
    Attribute                   : {@{CustomFieldGuid={7f214dec-9878-495f-a96c-57291f0d42da}; Name=ServiceNow Assignment Group;
                                PolicyPath=; Locked=False; Value=Venafi Management; Overridden=False}}
    ServiceNow Assignment Group : Venafi Management

    Retrieve a custom field attribute.
    You can specify either the guid or custom field label name.

    .EXAMPLE
    Get-VdcAttribute -Path '\VED\Policy\mydevice\myapp' -Attribute 'Certificate' -NoLookup

    Name                        : myapp
    Path                        : \VED\Policy\mydevice\myapp
    TypeName                    : Adaptable App
    Guid                        : b7a7221b-e038-41d9-9d49-d7f45c1ca128
    Attribute                   : {@{Name=Certificate; PolicyPath=; Value=\VED\Policy\mycert; Locked=False; Overridden=False}}
    Certificate                 : \VED\Policy\mycert

    Retrieve an attribute value without custom value lookup

    .EXAMPLE
    Get-VdcAttribute -Path '\VED\Policy\certificates\test.gdb.com' -All

    Name                                  : test.gdb.com
    Path                                  : \VED\Policy\Certificates\test.gdb.com
    TypeName                              : X509 Server Certificate
    Guid                                  : b7a7221b-e038-41d9-9d49-d7f45c1ca128
    Attribute                             : {@{CustomFieldGuid={7f214dec-9878-495f-a96c-57291f0d42da}; Name=ServiceNow
                                            Assignment Group; PolicyPath=; Locked=False; Value=Venafi Management;
                                            Overridden=False}…}
    ServiceNow Assignment Group           : Venafi Management
    City                                  : Salt Lake City
    Consumers                             : {\VED\Policy\Installations\Agentless\US Zone\mydevice\myapp}
    Contact                               : local:{b1c77034-c099-4a5c-9911-9e26007817da}
    Country                               : US
    Created By                            : WebAdmin
    Driver Name                           : appx509certificate
    ...

    Retrieve all attributes applicable to this object

    .EXAMPLE
    Get-VdcAttribute -Path 'Certificates' -Class 'X509 Certificate' -Attribute 'State'

    Name      : Certificates
    Path      : \VED\Policy\Certificates
    TypeName  : Policy
    Guid      : a91fc152-a9fb-4b49-a7ca-7014b14d73eb
    Attribute : {@{Name=State; PolicyPath=\VED\Policy\Certificates; Locked=False; Value=UT}}
    ClassName : X509 Certificate
    State     : UT

    Retrieve a policy attribute value for the specified policy folder and class.
    \ved\policy will be prepended to the path.

    .EXAMPLE
    Get-VdcAttribute -Path '\VED\Policy\certificates' -Class 'X509 Certificate' -All

    Name                                  : Certificates
    Path                                  : \VED\Policy\Certificates
    TypeName                              : Policy
    Guid                                  : a91fc152-a9fb-4b49-a7ca-7014b14d73eb
    Attribute                             : {@{CustomFieldGuid={7f214dec-9878-495f-a96c-57291f0d42da}; Name=ServiceNow
                                            Assignment Group; PolicyPath=; Locked=False; Value=}…}
    ClassName                             : X509 Certificate
    Approver                              : local:{b1c77034-c099-4a5c-9911-9e26007817da}
    Key Algorithm                         : RSA
    Key Bit Strength                      : 2048
    Managed By                            : Aperture
    Management Type                       : Enrollment
    Network Validation Disabled           : 1
    Notification Disabled                 : 0
    ...

    Retrieve all policy attributes for the specified policy folder and class

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Get-VdcAttribute/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-VdcAttribute.ps1

    .LINK
    https://docs.venafi.com/Docs/currentSDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-findpolicy.php

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-readeffectivepolicy.php

    #>
    [CmdletBinding(DefaultParameterSetName = 'Attribute')]
    [Alias('Get-TppAttribute')]

    param (

        [Parameter(Mandatory, ParameterSetName = 'Attribute', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'All', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('DN')]
        [String] $Path,

        [Parameter(Mandatory, ParameterSetName = 'Attribute')]
        [ValidateNotNullOrEmpty()]
        [String[]] $Attribute,

        [ValidateNotNullOrEmpty()]
        [Alias('ClassName', 'PolicyClass')]
        [string] $Class,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch] $All,

        [Parameter()]
        [switch] $NoLookup,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {

        Write-Debug $PSCmdlet.ParameterSetName

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $newAttribute = $Attribute
        if ( $All -and $Class ) {
            Write-Verbose "Getting attributes for class $Class"
            $newAttribute = Get-VdcClassAttribute -ClassName $Class | Select-Object -ExpandProperty Name -Unique
        }

        $params = @{

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

        $newPath = $Path | ConvertTo-VdcFullPath
        $thisObject = Get-VdcObject -Path $newPath

        if ( $PSBoundParameters.ContainsKey('Class') -and $thisObject.TypeName -ne 'Policy' ) {
            Write-Error ('You are attempting to retrieve policy attributes, but {0} is not a policy path' -f $newPath)
            continue
        }

        # get all attributes if item is an object other than a policy
        # Get-VdcClassAttribute will return matching names from different classes so ensure the list is unique
        if ( $All -and -not $PSBoundParameters.ContainsKey('Class') ) {
            $newAttribute = Get-VdcClassAttribute -ClassName $thisObject.TypeName | Select-Object -ExpandProperty Name -Unique
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

        $allAttributes = Invoke-VenafiParallel -InputObject $newAttribute -ScriptBlock {

            $thisAttribute = $PSItem
            $params = ($using:params).Clone()
            Write-Verbose "Processing attribute $thisAttribute"

            $params.Body.AttributeName = $thisAttribute
            $customField = $null

            if ( -not $NoLookup ) {
                $customField = $VenafiSession.CustomField | Where-Object { $_.Label -eq $thisAttribute -or $_.Guid -eq $thisAttribute }

                if ( $customField ) {
                    $params.Body.AttributeName = $customField.Guid
                }
            }

            # disabled is a special kind of attribute which cannot be read with readeffectivepolicy
            if ( $params.Body.AttributeName -eq 'Disabled' ) {
                $response = Invoke-VenafiRestMethod @params -UriLeaf 'Config/Read'
            }
            else {
                $response = Invoke-VenafiRestMethod @params
            }

            if ( $response.Error ) {
                if ( $response.Result -in 601, 112) {
                    Write-Error "'$thisAttribute' is not a valid attribute for $newPath.  Are you looking for a policy attribute?  If so, add -Class."
                    continue
                }
                elseif ( $response.Result -eq 102) {
                    # attribute is valid, but value not set
                    # we're ok with this one
                }
                else {
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

            $newProp = [pscustomobject] @{}

            # only add attributes to the root of the response object if they have a value
            # always add them to .Attribute ($newProp)
            if ( $CustomField ) {
                $newProp | Add-Member @{
                    Name              = $customField.Label
                    'CustomFieldGuid' = $customField.Guid
                }

                if ( $valueOut ) {
                    $using:return | Add-Member @{ $customField.Label = $valueOut }
                }

            }
            else {

                if ( $valueOut ) {
                    $using:return | Add-Member @{ $thisAttribute = $valueOut } -ErrorAction SilentlyContinue
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

        } -ThrottleLimit 20 -ProgressTitle 'Getting attributes'

        $return.Attribute = @($allAttributes)
        $return

    }
}