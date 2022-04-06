<#
.SYNOPSIS
Import a certificate

.DESCRIPTION
Import a certificate with or without private key.

.PARAMETER PolicyPath
Policy path to import the certificate to

.PARAMETER CertificatePath
Path to a certificate file.  Provide either this or CertificateData.

.PARAMETER CertificateData
Contents of a certificate to import.  Provide either this or CertificatePath.

.PARAMETER EnrollmentAttribute
A hashtable providing any CA attributes to store with the Certificate object, and then submit to the CA during enrollment

.PARAMETER Name
Optional name for the certificate object.
If not provided, the certificate Common Name (CN) is used.
The derived certificate object name references an existing object (of any class).
If another certificate has the same CN, a dash (-) integer appends to the CertificateDN. For example, test.venafi.example - 3.
If not provided and the CN is also missing, the name becomes the first Domain Name System (DNS) Subject Alternative Name (SAN).
Finally, if none of the above are found, the serial number is used.

.PARAMETER PrivateKey
Private key data; requires a value for Password.
For a PEM certificate, the private key is in either the RSA or PKCS#8 format.
Do not provide for a PKCS#12 certificate as the private key is already included.

.PARAMETER Password
Password required if the certificate has a private key.

.PARAMETER Reconcile
Controls certificate and corresponding private key replacement.
By default, this function will import and replace the certificate regardless of whether a past, future, or same version of the certificate exists in Trust Protection Platform.
By using this parameter, this function will import, but use newest. Only import the certificate when no Certificate object exists with a past, present, or current version of the imported certificate.
If a match is found between the Certificate object and imported certificate, activate the certificate with the most current 'Valid From' date.
Archive the unused certificate, even if it is the imported certificate, to the History tab.
See https://github.com/Venafi/VenafiPS/issues/88#issuecomment-600134145 for a flowchart of the reconciliation algorithm.

.PARAMETER PassThru
Return a TppObject representing the newly imported object.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.
A TPP token or VaaS key can also provided.

.EXAMPLE
Import-TppCertificate -PolicyPath \ved\policy\mycerts -CertificatePath c:\www.VenafiPS.com.cer
Import a certificate

.INPUTS
None

.OUTPUTS
TppObject, if PassThru provided

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-Import.php
#>
function Import-TppCertificate {
    [CmdletBinding(DefaultParameterSetName = 'ByFile')]
    param (

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid Policy path"
                }
            })]
        [String] $PolicyPath,

        [Parameter(Mandatory, ParameterSetName = 'ByFile')]
        [Parameter(Mandatory, ParameterSetName = 'ByFileWithPrivateKey')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-Path ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid path"
                }
            })]
        [String] $CertificatePath,

        [Parameter(Mandatory, ParameterSetName = 'ByData')]
        [Parameter(Mandatory, ParameterSetName = 'ByDataWithPrivateKey')]
        [ValidateNotNullOrEmpty()]
        [String] $CertificateData,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Hashtable] $EnrollmentAttribute,

        [Parameter(Mandatory, ParameterSetName = 'ByFileWithPrivateKey')]
        [Parameter(Mandatory, ParameterSetName = 'ByDataWithPrivateKey')]
        [ValidateNotNullOrEmpty()]
        [String] $PrivateKey,

        [Parameter(ParameterSetName = 'ByFile')]
        [Parameter(ParameterSetName = 'ByData')]
        [Parameter(Mandatory, ParameterSetName = 'ByFileWithPrivateKey')]
        [Parameter(Mandatory, ParameterSetName = 'ByDataWithPrivateKey')]
        [ValidateNotNullOrEmpty()]
        [SecureString] $Password,

        [Parameter()]
        [switch] $Reconcile,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

    }

    process {

        Write-Verbose $PSCmdlet.ParameterSetName

        if ( $PSBoundParameters.ContainsKey('CertificatePath') ) {
            # get cert data from file
            if ($PSVersionTable.PSVersion.Major -lt 6) {
                $cert = Get-Content $CertificatePath -Encoding Byte
            }
            else {
                $cert = Get-Content $CertificatePath -AsByteStream
            }

            $thisCertData = [System.Convert]::ToBase64String($cert)
        }
        else {
            $thisCertData = $CertificateData
        }

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriLeaf       = 'certificates/import'
            Body          = @{
                PolicyDN        = $PolicyPath
                CertificateData = $thisCertData
            }
        }

        if ( $PSBoundParameters.ContainsKey('EnrollmentAttribute') ) {
            $updatedAttribute = @($EnrollmentAttribute.GetEnumerator() | ForEach-Object { @{'Name' = $_.name; 'Value' = $_.value } })
            $params.Body.CASpecificAttributes = $updatedAttribute
        }

        if ( $Reconcile.IsPresent ) {
            $params.Body.Reconcile = 'true'
        }

        if ( $PSBoundParameters.ContainsKey('Name') ) {
            $params.Body.ObjectName = $Name
        }


        if ( $PSBoundParameters.ContainsKey('Password') ) {
            $params.Body.Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
        }

        if ( $PSBoundParameters.ContainsKey('PrivateKey') ) {
            $params.Body.PrivateKeyData = $PrivateKey
        }

        $response = Invoke-VenafiRestMethod @params
        Write-Verbose ('Successfully imported certificate')

        if ( $PassThru.IsPresent ) {
            Get-TppObject -Guid $response.Guid
        }
    }
}
