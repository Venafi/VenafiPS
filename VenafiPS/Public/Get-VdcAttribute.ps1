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
    For custom fields, you can provide either the Guid or Label.

    .PARAMETER Class
    Get policy attributes instead of object attributes.
    Provide the class name to retrieve the value(s) for.
    If unsure of the class name, add the value through the TLSPDC UI and go to Support->Policy Attributes to find it.
    The Attribute property of the return object will contain the path where the policy was applied.

    .PARAMETER All
    Get all object attributes or policy attributes.
    This will perform 3 steps, get the object type, enumerate the attributes for the object type, and get all the values.
    Note, expect this to take longer than usual given the number of api calls.

    .PARAMETER NoLookup
    Default functionality is to perform lookup of attributes names to see if they are custom fields or not.
    If they are, pass along the guid instead of name required by the api for custom fields.
    To override this behavior and use the attribute name as is, add -NoLookup.
    Useful if, on the off chance, you have a custom field with the same name as a built-in attribute.
    Can also be used with -All and the output will contain guids instead of looked up names.

    .PARAMETER ThrottleLimit
    Limit the number of threads when running in parallel; the default is 100.  Applicable to PS v7+ only.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token can be provided directly.
    If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

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

    .EXAMPLE
    Find-VdcCertificate | Get-VdcAttribute -Attribute Contact,'Managed By','Want Renewal' -ThrottleLimit 50

    Name         : mycert
    Path         : \VED\Policy\mycert
    TypeName     : X509 Server Certificate
    Guid         : 1dc31664-a9f3-407c-8bf3-1e388e90a114
    Attribute    : {@{Name=Contact; PolicyPath=\VED\Policy; Value=local:{ab2a2e32-b412-4466-b5b5-484478a99bf4}; Locked=False; Overridden=False}, @{Name=Managed By; PolicyPath=\VED\Policy;
                Value=Aperture; Locked=True; Overridden=False}, @{Name=Want Renewal; PolicyPath=\VED\Policy; Value=0; Locked=True; Overridden=False}}
    Contact      : local:{ab2a2e32-b412-4466-b5b5-484478a99bf4}
    Managed By   : Aperture
    Want Renewal : 0
    ...

    Retrieve specific attributes for all certificates.  Throttle the number of threads to 50, the default is 100

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
        [int32] $ThrottleLimit = 100,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {

        Write-Verbose $PSCmdlet.ParameterSetName

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VDC'

        $newAttribute = $Attribute
        if ( $All -and $Class ) {
            Write-Verbose "Getting attributes for class $Class"
            $newAttribute = Get-VdcClassAttribute -ClassName $Class | Select-Object -ExpandProperty Name -Unique
        }

        $allItems = [System.Collections.Generic.List[hashtable]]::new()
    }

    process {

        if ( $PSCmdlet.ParameterSetName -eq 'Attribute') {
            # small number of attributes so focus parallelism on the objects
            # this is done in the end block
            $allItems.Add(
                @{
                    Path      = $Path | ConvertTo-VdcFullPath
                    Attribute = $newAttribute
                }
            )

            return
        }

        # All parameter set below

        # with -All there is a large list of attributes so focus parallelism on them

        $newPath = $Path | ConvertTo-VdcFullPath
        $thisObject = Get-VdcObject -Path $newPath

        if ( $Class -and ($thisObject.TypeName -ne 'Policy') ) {
            Write-Error ('You are attempting to retrieve policy attributes, but {0} is not a policy path' -f $newPath)
            return
        }

        $return = [pscustomobject] @{
            Name      = $thisObject.Name
            Path      = $newPath
            TypeName  = $thisObject.TypeName
            Guid      = $thisObject.Guid
            Attribute = [pscustomobject] @{}
        }

        if ( $Class ) {
            $return | Add-Member @{ 'ClassName' = $Class }
        }
        else {
            # get list of attributes for this specific class
            $newAttribute = Get-VdcClassAttribute -ClassName $thisObject.TypeName | Select-Object -ExpandProperty Name -Unique
        }

        $allAttributes = Invoke-VenafiParallel -InputObject $newAttribute -ScriptBlock {

            $thisAttribute = $PSItem

            if ( $using:Class ) {

                $params = @{
                    Method  = 'Post'
                    Body    = @{
                        Class         = $using:Class
                        ObjectDN      = $using:newPath
                        AttributeName = $thisAttribute
                    }
                    UriLeaf = 'config/FindPolicy'
                }
            }
            else {
                $params = @{
                    Method  = 'Post'
                    Body    = @{
                        ObjectDN      = $using:newPath
                        AttributeName = $thisAttribute
                    }
                    UriLeaf = 'config/ReadEffectivePolicy'
                }
            }

            Write-Verbose "Processing attribute $thisAttribute"

            $customField = $null

            if ( -not $using:NoLookup ) {
                # parallel lookup
                $customField = $VenafiSession.CustomField | Where-Object { $_.Label -eq $thisAttribute -or $_.Guid -eq $thisAttribute }

                if ( -not $customField ) {
                    # sequential lookup
                    $customField = $VenafiSessionNested.CustomField | Where-Object { $_.Label -eq $thisAttribute -or $_.Guid -eq $thisAttribute }
                }

                if ( $customField ) {
                    $params.Body.AttributeName = $customField.Guid
                }
            }

            # disabled is a special kind of attribute which cannot be read with readeffectivepolicy
            if ( $params.Body.AttributeName -eq 'Disabled' ) {
                $oldUri = $params.UriLeaf
                $params.UriLeaf = 'Config/Read'
                $response = Invoke-VenafiRestMethod @params
                $params.UriLeaf = $oldUri
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

        } -ThrottleLimit $ThrottleLimit -ProgressTitle 'Getting attributes'

        $return.Attribute = @($allAttributes)
        $return
    }

    end {

        # parallelism is focused on the objects, not attributes
        # used when -Attribute is provided, not -All
        Invoke-VenafiParallel -InputObject $allItems -ScriptBlock {

            $newPath = $PSItem.Path
            $thisObject = Get-VdcObject -Path $newPath

            if ( $using:Class -and ($thisObject.TypeName -ne 'Policy') ) {
                Write-Error ('You are attempting to retrieve policy attributes, but {0} is not a policy path' -f $newPath)
                return
            }

            $newAttribute = $PSItem.Attribute

            $return = [pscustomobject] @{
                Name      = $thisObject.Name
                Path      = $newPath
                TypeName  = $thisObject.TypeName
                Guid      = $thisObject.Guid
                Attribute = [pscustomobject] @{}
            }

            if ( $using:Class ) {
                $return | Add-Member @{ 'ClassName' = $using:Class }

                $params = @{
                    Method  = 'Post'
                    Body    = @{
                        Class    = $using:Class
                        ObjectDN = $newPath
                    }
                    UriLeaf = 'config/FindPolicy'
                }
            }
            else {
                $params = @{
                    Method  = 'Post'
                    Body    = @{
                        ObjectDN = $newPath
                    }
                    UriLeaf = 'config/ReadEffectivePolicy'
                }
            }

            $allAttributes = foreach ($thisAttribute in $newAttribute) {

                Write-Verbose "Processing attribute $thisAttribute"

                $params.Body.AttributeName = $thisAttribute
                $customField = $null

                if ( -not $using:NoLookup ) {
                    # parallel lookup
                    $customField = $VenafiSession.CustomField | Where-Object { $_.Label -eq $thisAttribute -or $_.Guid -eq $thisAttribute }

                    if ( -not $customField ) {
                        # sequential lookup
                        $customField = $VenafiSessionNested.CustomField | Where-Object { $_.Label -eq $thisAttribute -or $_.Guid -eq $thisAttribute }
                    }

                    if ( $customField ) {
                        $params.Body.AttributeName = $customField.Guid
                    }
                }

                # disabled is a special kind of attribute which cannot be read with readeffectivepolicy
                if ( $params.Body.AttributeName -eq 'Disabled' ) {
                    $oldUri = $params.UriLeaf
                    $params.UriLeaf = 'Config/Read'
                    $response = Invoke-VenafiRestMethod @params
                    $params.UriLeaf = $oldUri
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
                        $return | Add-Member @{ $customField.Label = $valueOut }
                    }

                }
                else {

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
                if ( -not $using:Class ) {
                    $newProp | Add-Member @{ 'Overridden' = $response.Overridden }
                }

                $newProp
            }

            $return.Attribute = @($allAttributes)
            $return

        } -ThrottleLimit $ThrottleLimit -ProgressTitle 'Getting attributes'
    }
}