<#
.SYNOPSIS
Sets a value on an objects attribute or policies (policy attributes)

.DESCRIPTION
Set the value on an objects attribute.  The attribute can either be built-in or custom.
You can also set policies (policy attributes).

.PARAMETER Path
Path to the object to modify

.PARAMETER Attribute
Hashtable with names and values to be set.  If setting a custom field, you can use either the name or guid as the key.

.PARAMETER BypassValidation
Bypass data validation.  Only appicable to custom fields.

.PARAMETER Policy
Set policies (aka policy attributes) instead of object attributes

.PARAMETER ClassName
Required when setting policy attributes.  Provide the class name to set the value for.
If unsure of the class name, add the value through the TPP UI and go to Support->Policy Attributes to find it.

.PARAMETER Lock
Lock the value on the policy.  Only applicable to setting policies.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Path

.OUTPUTS
None

.EXAMPLE
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com' -Attribute @{'Consumers'='\VED\Policy\myappobject.company.com'}
Set a value on an object

.EXAMPLE
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com' -Attribute @{'My custom field Label'='new custom value'}
Set value on custom field

.EXAMPLE
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com' -Attribute @{'My custom field Label'='new custom value'} -BypassValidation
Set value on custom field bypassing field validation

.EXAMPLE
Set-TppAttribute -Path '\VED\Policy\My Folder' -Policy -ClassName 'X509 Certificate' -Attribute @{'Notification Disabled'='0'}
Set a policy attribute

.EXAMPLE
Set-TppAttribute -Path '\VED\Policy\My Folder' -Policy -ClassName 'X509 Certificate' -Attribute @{'Notification Disabled'='0'} -Lock
Set a policy attribute and lock the value

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppAttribute/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Set-TppAttribute.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-Set.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-write.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-writepolicy.php
#>
function Set-TppAttribute {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Object')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Being flagged incorrectly')]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
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

        [Parameter(Mandatory)]
        [hashtable] $Attribute,

        [Parameter(ParameterSetName = 'Object')]
        [switch] $BypassValidation,

        [Parameter(Mandatory, ParameterSetName = 'Policy')]
        [switch] $Policy,

        [Parameter(Mandatory, ParameterSetName = 'Policy')]
        [string] $ClassName,

        [Parameter(ParameterSetName = 'Policy')]
        [switch] $Lock,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
        }

        if ( -not $Policy ) {

            $baseFields = @()
            $customFields = @()

            $Attribute.GetEnumerator() | ForEach-Object {

                $thisKey = $_.Key
                $thisValue = $_.Value
                $customFieldError = $null

                $customField = $VenafiSession.CustomField | Where-Object { $_.Label -eq $thisKey -or $_.Guid -eq $thisKey }
                if ( $customField ) {
                    switch ( $customField.Type.ToString() ) {
                        '1' {
                            # string
                            if ( $customField.RegularExpression -and $thisValue -notmatch $customField.RegularExpression ) {
                                $customFieldError = 'regular expression ''{0}'' validation failed' -f $customField.RegularExpression
                            }
                        }

                        '2' {
                            # list
                            if ( $thisValue -notin $customField.AllowedValues ) {
                                $customFieldError = 'value is not in the list of allowed values ''{0}''' -f $customField.AllowedValues
                            }
                        }

                        '5' {
                            # identity
                            if ( -not ($thisValue | Test-TppIdentity -ExistOnly -VenafiSession $VenafiSession) ) {
                                $customFieldError = 'value is not a valid identity'
                            }
                        }

                        '4' {
                            # date/time
                            try {
                                [datetime] $thisValue
                            }
                            catch {
                                $customFieldError = 'value is not a valid date'
                            }
                        }

                        Default {
                            $customFieldError = 'unknown custom field type'
                        }
                    }

                    if ( $customFieldError -and -not $BypassValidation.IsPresent ) {
                        Write-Error ('The value ''{0}'' for field ''{1}'' encountered an error, {2}' -f $thisValue, $thisKey, $customFieldError)
                    }
                    else {
                        $customFields += @{
                            ItemGuid = $customField.Guid
                            List     = @($thisValue)
                        }
                    }
                }
                else {
                    $baseFields += @{
                        Name  = $thisKey
                        Value = @($thisValue)
                    }
                }
            }
        }
    }

    process {

        if ( -not $PSCmdlet.ShouldProcess($Path) ) {
            continue
        }

        if ( $Policy ) {
            $Attribute.GetEnumerator() | ForEach-Object {

                $params.UriLeaf = 'config/WritePolicy'
                $params.Body = @{
                    ObjectDN      = $Path
                    Class         = $ClassName
                    AttributeName = $_.Key
                    Values        = @($_.Value)
                    Locked        = [int]$Lock.ToBool()
                }

                $response = Invoke-VenafiRestMethod @params

                if ( $response.Result -ne [TppConfigResult]::Success ) {
                    Write-Error $response.Error
                }
            }
        }

        # built-in fields and custom fields have different APIs and payloads

        if ( $baseFields.Count -gt 0 ) {

            $params.UriLeaf = 'config/Write'
            $params.Body = @{
                ObjectDN      = $Path
                AttributeData = $baseFields
            }

            $response = Invoke-VenafiRestMethod @params

            if ( $response.Result -ne [TppConfigResult]::Success ) {
                Write-Error $response.Error
            }
        }

        if ( $customFields.Count -gt 0 ) {

            $params.UriLeaf = 'Metadata/Set'
            $params.Body = @{
                DN           = $Path
                GuidData     = $customFields
                KeepExisting = $true
            }

            $response = Invoke-VenafiRestMethod @params

            if ( $response.Result -ne 0 ) {
                Write-Error $response.Error
            }
        }
    }
}