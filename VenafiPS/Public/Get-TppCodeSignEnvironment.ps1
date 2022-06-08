<#
.SYNOPSIS
Get a code sign environment

.DESCRIPTION
Get code sign environment details

.PARAMETER Path
Path of the environment to get

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
Path

.OUTPUTS
PSCustomObject with the following properties:
    AllowUserKeyImport
    Disabled
    Guid
    Id
    CertificateStatus
    CertificateStatusText
    CertificateTemplate
    SynchronizeChain
    Path
    Name
    TypeName
    OrganizationalUnit
    IPAddressRestriction
    KeyUseFlowPath
    TemplatePath
    CertificateAuthorityPath
    CertificatePath
    CertificateSubject
    City
    KeyAlgorithm
    KeyStorageLocation
    Organization
    OrganizationUnit
    SANEmail
    State
    Country

.EXAMPLE
Get-TppCodeSignEnvironment -Path '\ved\code signing\projects\my_project\my_env'
Get a code sign environment

.EXAMPLE
$envObj | Get-TppCodeSignEnvironment
Get a environment after searching using Find-TppCodeSignEnvironment

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppCodeSignEnvironment/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppCodeSignEnvironment.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-GetEnvironment.php

#>
function Get-TppCodeSignEnvironment {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                } else {
                    throw "'$_' is not a valid path"
                }
            })]
        [String] $Path,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP' -AuthType 'token'

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'Codesign/GetEnvironment'
            Body       = @{ }
        }
    }

    process {

        $params.Body.Dn = $Path
        $response = Invoke-VenafiRestMethod @params

        if ( $response.Success ) {
            Write-Debug $response.CertificateEnvironment
            $response.CertificateEnvironment | ConvertTo-TppCodeSignEnvironment
        } else {
            Write-Error ('{0} : {1} : {2}' -f $response.Result, [enum]::GetName([TppCodeSignResult], $response.Result), $response.Error)
        }
    }
}
