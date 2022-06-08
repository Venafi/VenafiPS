<#
.SYNOPSIS
Get credential details

.DESCRIPTION
Get credential details.
Object returned will depend on the credential type.

.PARAMETER Path
The full path to the credential object

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
Path

.OUTPUTS
Password/UsernamePassword Credential - PSCredential
Certificate Credential - X509Certificate2

.EXAMPLE
Get-TppCredential -Path '\VED\Policy\MySecureCred'
Get a credential

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppCredential/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppCredential.ps1

#>
function Get-TppCredential {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Generating cred from api call response data')]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [String] $Path,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriLeaf       = 'Credentials/Retrieve'
            Body          = @{}
        }

    }

    process {

        $params.Body.CredentialPath = $Path
        $response = Invoke-VenafiRestMethod @params

        if ( -not $response ) {
            continue
        }

        switch ($response.Classname) {
            'Password Credential' {
                $pw = $response.Values | Where-Object { $_.Name -eq 'Password' } | Select-Object -ExpandProperty Value
                New-Object System.Management.Automation.PSCredential((Split-Path -Path $Path -Leaf), ($pw | ConvertTo-SecureString -AsPlainText -Force))
            }

            'Username Password Credential' {
                $un = $response.Values | Where-Object { $_.Name -eq 'Username' } | Select-Object -ExpandProperty Value
                $pw = $response.Values | Where-Object { $_.Name -eq 'Password' } | Select-Object -ExpandProperty Value
                New-Object System.Management.Automation.PSCredential($un, ($pw | ConvertTo-SecureString -AsPlainText -Force))
            }

            'Certificate Credential' {
                $cert = $response.Values | Where-Object { $_.Name -eq 'Certificate' } | Select-Object -ExpandProperty Value
                $pw = $response.Values | Where-Object { $_.Name -eq 'Password' } | Select-Object -ExpandProperty Value
                [System.Security.Cryptography.X509Certificates.X509Certificate2]::new([system.convert]::FromBase64String($cert), $pw)
            }

            Default {
                throw "Credential type '$_' is not supported yet.  Submit an enhancement request."
            }
        }
    }
}