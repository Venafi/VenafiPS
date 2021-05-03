<#
.SYNOPSIS
Get detailed certificate information

.DESCRIPTION
Get detailed certificate information

.PARAMETER InputObject
TppObject which represents a unique certificate

.PARAMETER Path
Path to a certificate

.PARAMETER Guid
Guid representing a certificate

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
InputObject, Path, Guid

.OUTPUTS
PSCustomObject with the following properties:
    Name
    TypeName
    Path
    Guid
    ParentPath
    Approver
    CertificateAuthorityDN
    CertificateDetails
    Contact
    CreatedOn
    CustomFields
    ManagementType
    ProcessingDetails
    RenewalDetails
    ValidationDetails

.EXAMPLE
$cert | Get-TppCertificateDetail
Get detailed certificate info via pipeline

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppCertificateDetail/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Get-TppCertificateDetail.ps1

.LINK
https://docs.venafi.com/Docs/20.3SDK/TopNav/Content/SDK/WebSDK/r-SDK-GET-Certificates-guid.php?tocpath=Web%20SDK%20reference%7CCertificates%20programming%20interface%7C_____10

.LINK
https://msdn.microsoft.com/en-us/library/system.web.httputility(v=vs.110).aspx

#>
function Get-TppCertificateDetail {

    [CmdletBinding()]
    param (

        [Parameter(Mandatory, ParameterSetName = 'ByObject', ValueFromPipeline)]
        [TppObject] $InputObject,

        [Parameter(Mandatory, ParameterSetName = 'ByPath', ValueFromPipeline)]
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

        [Parameter(Mandatory, ParameterSetName = 'ByGuid', ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [guid] $Guid,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate()

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Get'
        }
    }

    process {

        if ( $PSBoundParameters.ContainsKey('InputObject') ) {
            $thisGuid = $InputObject.Guid
        }
        elseif ( $PSBoundParameters.ContainsKey('Path') ) {
            $thisGuid = $Path | ConvertTo-TppGuid -VenafiSession $VenafiSession
        }
        else {
            $thisGuid = $Guid
        }

        $params.UriLeaf = [System.Web.HttpUtility]::HtmlEncode("certificates/{$thisGuid}")
        $response = Invoke-TppRestMethod @params

        $selectProps = @{
            Property        =
            @{
                n = 'Name'
                e = {$_.Name}
            },
            @{
                n = 'TypeName'
                e = {$_.SchemaClass}
            },
            @{
                n = 'Path'
                e = {$_.DN}
            }, @{
                n = 'Guid'
                e = {[guid]$_.guid}
            }, @{
                n = 'ParentPath'
                e = {$_.ParentDN}
            },
            '*'
            ExcludeProperty = 'DN', 'GUID', 'ParentDn', 'SchemaClass', 'Name'
        }
        $response | Select-Object @selectProps
    }
}
