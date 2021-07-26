<#
.SYNOPSIS
Sets a value on an attribute

.DESCRIPTION
Set a value on an attribute.  The attribute can either be built-in or custom.

.PARAMETER Path
Path to the object to modify

.PARAMETER Attribute
Hashtable with names and values to be set.  If setting a custom field, you can use either the name or guid as the key.

.PARAMETER BypassValidation
Bypass data validation.  Only appicable to custom fields.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Path

.OUTPUTS
None

.EXAMPLE
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com -Attribute @{'My custom field Label'='new custom value'}
Set value on custom field

.EXAMPLE
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com -Attribute @{'DateField'='hi'} -BypassValidation
Set value on custom field bypassing field validation

.EXAMPLE
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com -Attribute @{'Consumers'='\VED\Policy\myappobject.company.com'}
Set value on a certificate by overwriting any existing values

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppAttribute/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Set-TppAttribute.ps1

.LINK
https://docs.venafi.com/Docs/21.2/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-Set.php?tocpath=Platform%20SDK%7CWeb%20SDK%20REST%7CCertificate%20end%20points%20for%20TLS%7CMetadata%20custom%20fields%20API%7C_____17

.LINK
https://docs.venafi.com/Docs/21.2/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-write.php?tocpath=Platform%20SDK%7CWeb%20SDK%20REST%7CConfiguration%20end%20points%7CConfig%20API%7C_____36

#>
function Set-TppAttribute {

    [CmdletBinding(SupportsShouldProcess)]

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
        [String[]] $Path,

        [Parameter(Mandatory)]
        [hashtable] $Attribute,

        [Parameter()]
        [switch] $BypassValidation,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate() | Out-Null

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
        }

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
                    Value = $thisValue
                }
            }
        }
    }

    process {

        foreach ($thisDn in $Path) {

            if ( $PSCmdlet.ShouldProcess($thisDn) ) {

                # built-in fields and custom fields have different APIs and payloads

                if ( $baseFields.Count -gt 0 ) {

                    $params.UriLeaf = 'config/Write'
                    $params.Body = @{
                        ObjectDN      = $thisDn
                        AttributeData = $baseFields
                    }

                    $response = Invoke-TppRestMethod @params

                    if ( $response.Result -ne [TppConfigResult]::Success ) {
                        Write-Error $response.Error
                    }
                }

                if ( $customFields.Count -gt 0 ) {

                    $params.UriLeaf = 'Metadata/Set'
                    $params.Body = @{
                        DN           = $thisDn
                        GuidData     = $customFields
                        KeepExisting = $true
                    }

                    $response = Invoke-TppRestMethod @params

                    if ( $response.Result -ne 0 ) {
                        Write-Error $response.Error
                    }
                }
            }
        }
    }
}