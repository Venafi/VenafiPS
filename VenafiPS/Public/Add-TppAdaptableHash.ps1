function Add-TppAdaptableHash {
    <#
    .SYNOPSIS
    Sets a value on an objects attribute or policies (policy attributes)

    .DESCRIPTION
    Set the value on an objects attribute.  The attribute can either be built-in or custom.
    You can also set policies (policy attributes).

    .PARAMETER Path
    Path to the object to modify

    .PARAMETER Attribute
    Hashtable with names and values to be set.
    If setting a custom field, you can use either the name or guid as the key.
    To clear a value overwriting policy, set the value to $null.

    .PARAMETER BypassValidation
    Bypass data validation.  Only applicable to custom fields.

    .PARAMETER Policy
    Set policies (aka policy attributes) instead of object attributes

    .PARAMETER ClassName
    Required when setting policy attributes.  Provide the class name to set the value for.
    If unsure of the class name, add the value through the TPP UI and go to Support->Policy Attributes to find it.

    .PARAMETER Lock
    Lock the value on the policy.  Only applicable to setting policies.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    Path

    .OUTPUTS
    None

    .EXAMPLE
    Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com' -Attribute @{'Consumers'='\VED\Policy\myappobject.company.com'}

    Set the value on an object

    .EXAMPLE
    Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com' -Attribute @{'Management Type'=$null}

    Clear the value on an object, reverting to policy if applicable

    .EXAMPLE
    Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com' -Attribute @{'My custom field Label'='new custom value'}

    Set the value on a custom field

    .EXAMPLE
    Set-TppAttribute -Path '\VED\Policy\My Folder\app.company.com' -Attribute @{'My custom field Label'='new custom value'} -BypassValidation

    Set the value on a custom field bypassing field validation

    .EXAMPLE
    Set-TppAttribute -Path '\VED\Policy\My Folder' -PolicyClass 'X509 Certificate' -Attribute @{'Notification Disabled'='0'}

    Set a policy attribute

    .EXAMPLE
    Set-TppAttribute -Path '\VED\Policy\My Folder' -PolicyClass 'X509 Certificate' -Attribute @{'Notification Disabled'='0'} -Lock

    Set a policy attribute and lock the value

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppAttribute/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Set-TppAttribute.ps1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-Set.php

    .LINK
    https://docs.venafi.com/Docs/currentSDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-SetPolicy.php

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-write.php

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-writepolicy.php
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
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

        [Parameter()]
        [ValidateSet('Adaptable App')]
        [ValidateNotNullOrEmpty()]
        [string] $Class,

        [Parameter()]
		[string] $Keyname = "Software:Default",

        [Parameter(Mandatory)]
        [Alias('File')]
        [string] $FilePath,

        [Parameter()]
        [psobject] $VenafiSession = $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
        }

        if ($Class) {
            $retrieveVaultID = (Get-TppAttribute -Path $Path -Class $Class -Attribute 'PowerShell Script Hash Vault Id').'PowerShell Script Hash Vault Id'
        } else {
            $retrieveVaultID = (Get-TppAttribute -Path $Path -Attribute 'PowerShell Script Hash Vault Id').'PowerShell Script Hash Vault Id'
        }

        $bytes = [Text.Encoding]::UTF32.GetBytes([IO.File]::ReadAllText($FilePath))
        $hash = Get-FileHash -InputStream ([System.IO.MemoryStream]::New($bytes))
        $base64data = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($hash.hash.ToLower()))

    }

    process {
        if ( -not $PSCmdlet.ShouldProcess($Path) ) {
            continue
        }

        if ($retrieveVaultID) {
            $paramsretrieve = $params
            $paramsretrieve.UriLeaf = 'SecretStore/retrieve'
            $paramsretrieve.Body = @{
                VaultID = $retrieveVaultID
            }

            $retrieveResponse = Invoke-VenafiRestMethod @paramsretrieve

            if ( $retrieveResponse.Result -ne [TppSecretStoreResult]::Success ) {
                Write-Error ("Error retrieving VaultID: {0}" -f [enum]::GetName([TppSecretStoreResult], $retrieveResponse.Result))
            }

            if($null -ne $retrieveResponse.Base64Data) {
                $retrieveBase64 = $retrieveResponse.Base64Data
            }
        } else {
            Write-Error "Unable to get VaultID from $($Path)." -ErrorAction Stop
        }

        if( $base64data -eq $retrieveBase64 ){
            Write-Verbose "PowerShell Script Hash Vault Id unchanged for $($Path)."
        } else {
            $paramsadd = $params
            $paramsadd.UriLeaf = 'SecretStore/Add'
            $paramsadd.Body = @{
                VaultType = '128'
                Keyname = $Keyname
                Base64Data = $Base64Data
                Namespace = 'Config'
                Owner = $Path
            }
    
            $addresponse = Invoke-VenafiRestMethod @paramsadd

            if ( $addresponse.Result -ne [TppSecretStoreResult]::Success ) {
                Write-Error ("Error adding VaultID: {0}" -f [enum]::GetName([TppSecretStoreResult], $addResponse.Result))
            }

            Set-TppAttribute -Path $Path -Class $Class -Attribute @{ 'PowerShell Script Hash Vault Id' = $addresponse.VaultID } -Lock -ErrorAction Stop

            $paramsdelete = $params
            $paramsdelete.UriLeaf = 'SecretStore/OwnerDelete'
            $paramsdelete.Body = @{
                Namespace = 'Config'
                Owner = $Path
                VaultID = $retrieveVaultID
            }

            $deleteResponse = Invoke-VenafiRestMethod @paramsdelete

            if ( $deleteResponse.Result -ne [TppSecretStoreResult]::Success ) {
                Write-Error ("Error removing VaultID: {0}" -f [enum]::GetName([TppSecretStoreResult], $deleteResponse.Result))
            }
            Write-Verbose "PowerShell Script Hash Vault Id for $($Path) set to $($addresponse.VaultID)."
        }
    }

}