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
    If not provided, details will be provided to the pipeline.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

    .INPUTS
    ID

    .OUTPUTS
    PSCustomObject

    .EXAMPLE
    Export-VdcVaultObject -ID 12345

    Get vault object details

    .EXAMPLE
    Find-VdcObject -Path '\VED\Intermediate and Root Certificates\Trusted Root Certification Authorities' | Get-VdcAttribute -Attribute 'Certificate Vault Id' | Export-VdcVaultObject

    Get intermediate or root certificates.  Export to the pipeline instead of to a file.

    .EXAMPLE
    Get-VdcCertificate -Path 'certificates\www.greg.com' -IncludePreviousVersions | Export-VdcVaultObject

    Export historical certificates
    
    .EXAMPLE
    Export-VdcVaultObject -ID 12345 -OutPath 'c:\temp'

    Get vault object and save to a file

    #>

    [CmdletBinding(DefaultParameterSetName = 'ToPipeline')]

    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('VaultId', 'Certificate Vault Id', 'PreviousVersions')]
        [psobject] $ID,

        [Parameter(Mandatory, ParameterSetName = 'ToFile')]
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
        [ValidateNotNullOrEmpty()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession $PSCmdlet.MyInvocation
    }

    process {

        foreach ($thisId in $ID) {
            $vaultId = if ( $thisId.VaultId ) { $thisId.VaultId } else { $thisId }
            $response = Invoke-VenafiRestMethod -Method 'Post' -UriLeaf 'SecretStore/Retrieve' -Body @{ 'VaultID' = $vaultId }
    
            if ( $response.Result -ne 0 ) {
                Write-Error "Failed to retrieve vault object with a result code of $($response.Result).  Look up this code at https://docs.venafi.com/Docs/currentSDK/TopNav/Content/SDK/WebSDK/r-SDK-SecretStore-ResultCodes.php."
                return
            }
    
            $ext = $format = $null
    
            switch ( $response.VaultType ) {
                { $_ -in 2, 1073741826 } {
                    $ext = 'cer'
                    $format = 'Base64'
                }
    
                { $_ -in 4, 1073741828 } {
                    $ext = 'p12'
                    $format = 'PKCS12'
                }
    
                { $_ -in 32, 1073741856 } {
                    $format = 'Password'
                }
    
                { $_ -in 256, 1073742080 } {
                    $ext = 'key'
                    $format = 'PKCS8'
                }

                { $_ -in 512, 1073742336 } {
                    $ext = 'csr'
                    $format = 'PKCS10'
                }

                default {
                    Write-Verbose "Unknown vault type $_"
                }
            }
    
            if ( $OutPath ) {
                if ( $ext ) {
    
                    $outFile = Join-Path -Path (Resolve-Path -Path $OutPath) -ChildPath ('{0}.{1}' -f $ID, $ext)
                    $bytes = [Convert]::FromBase64String($response.Base64Data)
                    [IO.File]::WriteAllBytes($outFile, $bytes)
        
                    Write-Verbose "Saved $outFile"
                }
                else {
                    # unhandled type
                    Write-Warning "Unhandled vault type $($response.VaultType).  See https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-SecretStore-VaultTypes.php for the data type."
                }
            }
            else {
                [pscustomobject]@{
                    VaultId = $vaultId
                    Data    = $response.Base64Data
                    Format  = $format
                    TypeId  = $response.VaultType
                }
            }
        }
    }
}
