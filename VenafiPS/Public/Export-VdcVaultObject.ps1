function Export-VdcVaultObject {
    <#
    .SYNOPSIS
    Export an object from the vault

    .DESCRIPTION
    Export different object types from the vault.
    The currently supported types are certificate, key, and PKCS12.
    If the type is not supported, the base64 data will be returned as is.

    .PARAMETER ID
    ID of the vault object to export

    .PARAMETER OutPath
    Folder path to save the certificate/key to.  The name of the file will be determined automatically.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

    .INPUTS
    ID

    .OUTPUTS
    PSCustomObject if unhandled type, otherwise saves the object to a file

    .EXAMPLE
    Export-VdcVaultObject -ID 12345 -OutPath 'c:\temp'

    Get vault object and save to a file

    #>

    [CmdletBinding()]

    param (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('VaultId')]
        [int] $ID,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if (Test-Path $_ -PathType Container) {
                    $true
                }
                else {
                    Throw "Output path '$_' does not exist"
                }
            })]
        [String] $OutPath,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession $PSCmdlet.MyInvocation
    }

    process {
        $response = Invoke-VenafiRestMethod -Method 'Post' -UriLeaf 'SecretStore/Retrieve' -Body @{ 'VaultID' = $ID }

        if ( $response.Result -ne 0 ) {
            Write-Error "Failed to retrieve vault object with a result code of $($response.Result).  Look up this code at https://docs.venafi.com/Docs/currentSDK/TopNav/Content/SDK/WebSDK/r-SDK-SecretStore-ResultCodes.php."
            return
        }

        $ext = $null

        switch ( $response.VaultType ) {
            { $_ -in 2, 1073741826 } {
                # certificate
                $ext = 'cer'
            }

            { $_ -in 4, 1073741828 } {
                # PKCS12
                $ext = 'p12'
            }

            { $_ -in 256, 1073742080 } {
                # PKCS8
                $ext = 'key'
            }
        }

        if ( $ext ) {
            $outFile = Join-Path -Path (Resolve-Path -Path $OutPath) -ChildPath ('{0}.{1}' -f $ID, $ext)
            $bytes = [Convert]::FromBase64String($response.Base64Data)
            [IO.File]::WriteAllBytes($outFile, $bytes)

            Write-Verbose "Saved $outFile"
        }
        else {
            # unhandled type, send data as is
            Write-Verbose "Unhandled vault type $($response.VaultType), returning data as is"
            $response | Select-Object -Property *, @{'n' = 'VaultID'; 'e' = { $ID } } -ExcludeProperty Result
        }

    }
}
