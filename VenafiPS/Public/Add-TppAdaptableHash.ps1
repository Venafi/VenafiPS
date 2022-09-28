function Add-TppAdaptableHash {
    <#
    .SYNOPSIS
    Adds or updates the hash value for an adaptable script

    .DESCRIPTION
    TPP stores a base64 encoded hash of the file contents of an adaptable script in the Secret Store. This is referenced by
    the Attribute 'PowerShell Script Hash Vault Id' on the DN of the adaptable script. This script retrieves the hash (if
    present) from the Secret Store and compares it to the hash of the file in one of the scripts directories. It then adds 
    a new or updated hash if required. When updating an existing hash, it removes the old one from the Secret Store.

    .PARAMETER Path
    Required. Path to the object to add or update the hash.
    Note: For an adaptable app or an onboard discovery, 'Path' must always be a policy folder as this is where
    the hash is saved.

    .PARAMETER Keyname
    The name of the Secret Encryption Key (SEK) to used when encrypting this item. Default is "Software:Default"

    .PARAMETER FilePath
    Required. The full path to the adaptable script file. This should normally be in a 
    '<drive>:\Program Files\Venafi\Scripts\<subdir>' directory for TPP to recognize the script.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    None

    .OUTPUTS
    None

    .EXAMPLE
    Add-TppAdaptableHash -Path $Path -FilePath 'C:\Program Files\Venafi\Scripts\AdaptableApp\AppDriver.ps1'

    Update the hash on an adaptable app object.
    
    Note: For an adaptable app or an onboard discovery, 'Path' must always be a policy folder as this is where
    the hash is saved.

    .EXAMPLE
    Add-TppAdaptableHash -Path $Path -FilePath 'C:\Program Files\Venafi\Scripts\AdaptableLog\Generic-LogDriver.ps1'

    Update the hash on an adaptable log object.

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Add-TppAdaptableHash/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Add-TppAdaptableHash.ps1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Secretstore-add.php

    .LINK
    https://docs.venafi.com/Docs/currentSDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Secretstore-ownerdelete.php

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Secretstore-retrieve.php
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

        $TypeName = (Get-TppObject -Path $Path -VenafiSession $VenafiSession).TypeName

        if ( $TypeName -eq 'Policy' ) {
            $retrieveVaultID = ( Get-TppAttribute -Path $Path -Class 'Adaptable App' -Attribute 'PowerShell Script Hash Vault Id' ).'PowerShell Script Hash Vault Id'
        } else {
            $retrieveVaultID = ( Get-TppAttribute -Path $Path -Attribute 'PowerShell Script Hash Vault Id' ).'PowerShell Script Hash Vault Id'
        }

        $bytes = [Text.Encoding]::UTF32.GetBytes([IO.File]::ReadAllText($FilePath))
        $hash = Get-FileHash -InputStream ([System.IO.MemoryStream]::New($bytes))
        $base64data = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($hash.hash.ToLower()))

    }

    process {
        if ( -not $PSCmdlet.ShouldProcess($Path) ) {
            continue
        }

        if ( $retrieveVaultID ) {
            $paramsretrieve = $params.Clone()
            $paramsretrieve.UriLeaf = 'SecretStore/retrieve'
            $paramsretrieve.Body = @{
                VaultID = $retrieveVaultID
            }

            $retrieveResponse = Invoke-VenafiRestMethod @paramsretrieve

            if ( $retrieveResponse.Result -ne [TppSecretStoreResult]::Success ) {
                Write-Error ("Error retrieving VaultID: {0}" -f [enum]::GetName([TppSecretStoreResult], $retrieveResponse.Result)) -ErrorAction Stop
            }

            if($null -ne $retrieveResponse.Base64Data) {
                $retrieveBase64 = $retrieveResponse.Base64Data
            }
        }

        if ( $base64data -eq $retrieveBase64 ){
            Write-Verbose "PowerShell Script Hash Vault Id unchanged for $($Path)."
            continue
        } else {
            $paramsadd = $params.Clone()
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
                Write-Error ("Error adding VaultID: {0}" -f [enum]::GetName([TppSecretStoreResult], $addResponse.Result)) -ErrorAction Stop
            }

            if ( $AdaptableApp ) {
                Set-TppAttribute -Path $Path -PolicyClass 'Adaptable App' -Attribute @{ 'PowerShell Script Hash Vault Id' = [string]$addresponse.VaultID } -Lock -VenafiSession $VenafiSession -ErrorAction Stop
            } else {
                Set-TppAttribute -Path $Path -Attribute @{ 'PowerShell Script Hash Vault Id' = [string]$addresponse.VaultID } -VenafiSession $VenafiSession -ErrorAction Stop
            }
            Write-Verbose "PowerShell Script Hash Vault Id for $($Path) set to $($addresponse.VaultID)."
        }

        if (( $retrieveBase64 ) -and ( $addresponse.VaultID )) {
            $paramsdelete = $params.Clone()
            $paramsdelete.UriLeaf = 'SecretStore/OwnerDelete'
            $paramsdelete.Body = @{
                Namespace = 'Config'
                Owner = $Path
                VaultID = $retrieveVaultID
            }

            $deleteResponse = Invoke-VenafiRestMethod @paramsdelete

            if ( $deleteResponse.Result -ne [TppSecretStoreResult]::Success ) {
                Write-Error ("Error removing VaultID: {0}" -f [enum]::GetName([TppSecretStoreResult], $deleteResponse.Result)) -ErrorAction Stop
            }
        }
    }
}