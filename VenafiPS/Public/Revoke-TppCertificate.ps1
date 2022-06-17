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

.PARAMETER Force
Bypass the confirmation prompt

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

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
$cert | Revoke-TppCertificate -Force
Revoke the certificate bypassing the confirmation prompt

.EXAMPLE
Revoke-TppCertificate -Path '\VED\Policy\My folder\app.mycompany.com' -Reason 2 -Wait
Revoke the certificate with a reason of the CA being compromised and wait for it to complete

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Revoke-TppCertificate/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Revoke-TppCertificate.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-revoke.php

#>
function Revoke-TppCertificate {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
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
        [switch] $Force,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'Certificates/Revoke'
            Body       = ''
        }
    }

    process {

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

        if ( $Force ) {
            $ConfirmPreference = 'None'
        }

        if ( $PSCmdlet.ShouldProcess($Path, 'Revoke certificate') ) {
            $response = Invoke-VenafiRestMethod @params

            if ( $Wait ) {
                while (-not $response.Revoked) {
                    Start-Sleep -Seconds 1
                    $response = Invoke-VenafiRestMethod @params
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
