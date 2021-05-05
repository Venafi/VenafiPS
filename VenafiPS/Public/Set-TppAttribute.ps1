<#
.SYNOPSIS
Adds a value to an attribute

.DESCRIPTION
Write a value to the object's configuration.  This function will append by default.  Attributes can have multiple values which may not be the intended use.  To ensure you only have one value for an attribute, use the Overwrite switch.

.PARAMETER ObjectDN
Path to the object to modify

.PARAMETER AttributeName
Name of the attribute to modify.  If modifying a custom field, use the Label.

.PARAMETER Value
Value or list of values to write to the attribute.

.PARAMETER NoClobber
Append existing values as opposed to replacing which is the default

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Path

.OUTPUTS
PSCustomObject with the following properties:
    DN = path to object
    Success = boolean indicating success or failure
    Error = Error message in case of failure

.EXAMPLE
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com -AttributeName 'My custom field Label' -Value 'new custom value'
Set value on custom field.  This will add to any existing value.

.EXAMPLE
Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com -AttributeName 'Consumers' -Value '\VED\Policy\myappobject.company.com' -Overwrite
Set value on a certificate by overwriting any existing values

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppAttribute/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Set-TppAttribute.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-addvalue.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____4

#>
function Set-TppAttribute {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
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
        [ValidateNotNullOrEmpty()]
        [String] $AttributeName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String[]] $Value,

        [Parameter()]
        [Switch] $NoClobber,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate() | Out-Null

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
        }

        if ($NoClobber) {
            $params += @{
                UriLeaf = 'config/AddValue'
            }
        }
        else {
            $params += @{
                UriLeaf = 'config/Write'
            }
        }
    }

    process {

        foreach ($thisDn in $Path) {

            $realAttributeName = $AttributeName
            $field = $VenafiSession.CustomField | Where-Object {$_.Label -eq $AttributeName}
            if ( $field ) {
                $realAttributeName = $field.Guid
                Write-Verbose ("Updating custom field.  Name: {0}, Guid: {1}" -f $AttributeName, $field.Guid)
            }

            $params.Body = @{
                ObjectDN      = $thisDn
                AttributeName = $realAttributeName
            }

            # overwrite can accept multiple values at once so pass in the entire list
            # adding values can not so we must loop
            if ($NoClobber) {
                foreach ($thisValue in $Value) {

                    $params.Body += @{
                        Value = $thisValue
                    }

                    if ( $PSCmdlet.ShouldProcess($thisDn, 'Add attribute values') ) {
                        $response = Invoke-TppRestMethod @params

                        [PSCustomObject] @{
                            DN      = $thisDn
                            Success = $response.Result -eq [TppConfigResult]::Success
                            Error   = $response.Error
                        }
                    }
                }
            }
            else {
                $params.Body += @{
                    Values = $Value
                }

                if ( $PSCmdlet.ShouldProcess($thisDn, 'Overwrite attribute values') ) {

                    $response = Invoke-TppRestMethod @params

                    [PSCustomObject] @{
                        DN      = $thisDn
                        Success = $response.Result -eq [TppConfigResult]::Success
                        Error   = $response.Error
                    }
                }
            }
        }
    }
}