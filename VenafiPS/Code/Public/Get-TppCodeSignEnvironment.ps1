<#
.SYNOPSIS
Get a code sign environment

.DESCRIPTION
Get code sign environment details

.PARAMETER Path
Path of the environment to get

.PARAMETER TppSession
Session object created from New-TppSession method.  The value defaults to the script session object $TppSession.

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
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Get-TppCodeSignEnvironment.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/CodeSignSDK/r-SDKc-POST-Codesign-GetEnvironment.php?tocpath=CodeSign%20Protect%20Admin%20REST%C2%A0API%7CProjects%20and%20environments%7C_____9

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
        [TppSession] $TppSession = $Script:TppSession
    )

    begin {
        $TppSession.Validate('token')

        $params = @{
            TppSession = $TppSession
            Method     = 'Post'
            UriLeaf    = 'Codesign/GetEnvironment'
            Body       = @{ }
        }
    }

    process {

        $params.Body.Dn = $Path
        $response = Invoke-TppRestMethod @params

        if ( $response.Success ) {
            Write-Debug $response.CertificateEnvironment
            $response.CertificateEnvironment | ConvertTo-TppCodeSignEnvironment
        } else {
            Write-Error ('{0} : {1} : {2}' -f $response.Result, [enum]::GetName([TppCodeSignResult], $response.Result), $response.Error)
        }
    }
}
