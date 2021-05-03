<#
.SYNOPSIS
Revoke a certificate

.DESCRIPTION
Requests that an existing certificate be revoked.

.PARAMETER InputObject
TppObject which represents a certificate

.PARAMETER Path
Full path to a certificate

.PARAMETER Reason
The reason for revocation of the certificate:

    0: None
    1: User key compromised
    2: CA key compromised
    3: User changed affiliation
    4: Certificate superseded
    5: Original use no longer valid

.PARAMETER Comments
Optional details as to why the certificate is being revoked

.PARAMETER Disable
The setting to manage the Certificate object upon revocation.
Default is to allow a new certificate to be enrolled to replace the revoked one.
Provide this switch to mark the certificate as disabled and no new certificate will be enrolled to replace the revoked one.

.PARAMETER Wait
Wait for the requested revocation to be complete

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
TppObject or Path

.OUTPUTS
PSCustomObject with the following properties:
    Path - Path to the Certificate
    Status - InProgress, Revoked, or Error
    Warning/Error - additional info

.EXAMPLE
$cert | Revoke-TppCertificate -Reason 2
Revoke the certificate with a reason of the CA being compromised

.EXAMPLE
Revoke-TppCertificate -Path '\VED\Policy\My folder\app.mycompany.com' -Reason 2 -Wait
Revoke the certificate with a reason of the CA being compromised and wait for it to complete

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Revoke-TppCertificate/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Revoke-TppCertificate.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-revoke.php?tocpath=Web%20SDK%7CCertificates%20programming%20interface%7C_____24

#>
function Revoke-TppCertificate {
    [CmdletBinding(DefaultParameterSetName = 'ByObject', SupportsShouldProcess, ConfirmImpact = 'High')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'ByObject', ValueFromPipeline)]
        [TppObject] $InputObject,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'ByPath')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                } else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [alias('DN', 'CertificateDN')]
        [String] $Path,

        [Parameter()]
        [ValidateRange(0, 5)]
        [Int] $Reason,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String] $Comments,

        [Parameter()]
        [Switch] $Disable,

        [Parameter()]
        [Switch] $Wait,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate()

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'Certificates/Revoke'
            Body       = ''
        }
    }

    process {

        Write-Verbose $PsCmdlet.ParameterSetName

        if ( $PSBoundParameters.ContainsKey('InputObject') ) {
            $path = $InputObject.Path
        }

        Write-Verbose "Revoking $Path..."

        $params.Body = @{
            CertificateDN = $Path
        }

        if ( $Reason ) {
            $params.Body.Reason = $Reason
        }

        if ( $Comments ) {
            $params.Body.Comments = $Comments
        }

        if ( $Disable ) {
            $params.Body.Disable = $true
        }

        if ( $PSCmdlet.ShouldProcess($Path, 'Revoke certificate') ) {
            $response = Invoke-TppRestMethod @params

            if ( $Wait ) {
                while (-not $response.Revoked) {
                    Start-Sleep -Seconds 1
                    $response = Invoke-TppRestMethod @params
                }
            }

            # determine status that makes sense since API returns Success in addition to Revoked/Requested
            if ( $response.Error ) {
                $status = "Error"
            } else {
                if ( $response.Revoked ) {
                    $status = 'Revoked'
                } else {
                    $status = 'InProgress'
                }
            }

            $updatedResponse = $response |
            Select-Object -Property * -ExcludeProperty 'Revoked', 'Requested', 'Success' |
            Where-Object { $_.psobject.Properties.name -ne "*" }

            if ( $updatedResponse ) {
                $updatedResponse | Add-Member @{'Path' = $Path; 'Status' = $status } -PassThru
            } else {
                [PSCustomObject] @{
                    'Path'   = $Path
                    'Status' = $status
                }
            }
        }
    }
}
