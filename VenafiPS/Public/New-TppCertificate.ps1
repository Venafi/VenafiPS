<#
.SYNOPSIS
Enrolls or provisions a new certificate

.DESCRIPTION
Enrolls or provisions a new certificate

.PARAMETER Path
The folder DN path for the new certificate. If the value is missing, use the system default

.PARAMETER Name
Name of the certifcate.  If not provided, the name will be the same as the subject.

.PARAMETER CommonName
Subject Common Name.  If Name isn't provided, CommonName will be used.

.PARAMETER CertificateType
Type of certificate to be created.
No value provided will default to X.509 Server Certificate.

.PARAMETER CertificateAuthorityDN
The Distinguished Name (DN) of the Trust Protection Platform Certificate Authority Template object for enrolling the certificate. If the value is missing, use the default CADN

.PARAMETER CertificateAuthorityAttribute
Name/value pairs providing any CA attributes to store with the Certificate object.
During enrollment, these values will be submitted to the CA.

.PARAMETER ManagementType
The level of management that Trust Protection Platform applies to the certificate:
- Enrollment: Default. Issue a new certificate, renewed certificate, or key generation request to a CA for enrollment. Do not automatically provision the certificate.
- Provisioning:  Issue a new certificate, renewed certificate, or key generation request to a CA for enrollment. Automatically install or provision the certificate.
- Monitoring:  Allow Trust Protection Platform to monitor the certificate for expiration and renewal.
- Unassigned: Certificates are neither enrolled or monitored by Trust Protection Platform.

.PARAMETER SubjectAltName
A list of Subject Alternate Names.
The value must be 1 or more hashtables with the SAN type and value.
Acceptable SAN types are OtherName, Email, DNS, URI, and IPAddress.
You can provide more than 1 of the same SAN type with multiple hashtables.

.PARAMETER CustomField
Hashtable of custom field(s) to be updated when creating the certificate.
This is required when the custom fields are mandatory.
The key is the name, not guid, of the custom field.

.PARAMETER PassThru
Return a TppObject representing the newly created certificate.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
None

.OUTPUTS
TppObject, if PassThru is provided

.EXAMPLE
New-TppCertificate -Path '\ved\policy\folder' -Name 'mycert.com' -CertificateAuthorityDN '\ved\policy\CA Templates\my template'
Create certificate by name

.EXAMPLE
New-TppCertificate -Path '\ved\policy\folder' -Name 'mycert.com' -CertificateAuthorityDN '\ved\policy\CA Templates\my template' -CustomField @{''=''}
Create certificate and update custom fields

.EXAMPLE
New-TppCertificate -Path '\ved\policy\folder' -CommonName 'mycert.com' -CertificateAuthorityDN '\ved\policy\CA Templates\my template' -PassThru
Create certificate using common name.  Return the created object.

.EXAMPLE
New-TppCertificate -Path '\ved\policy\folder' -Name 'mycert.com' -CertificateAuthorityDN '\ved\policy\CA Templates\my template' -SubjectAltName @{'Email'='me@x.com'},@{'IPAddress'='1.2.3.4'}
Create certificate including subject alternate names

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/New-TppCertificate/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-TppCertificate.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Certificates-request.php

#>
function New-TppCertificate {

    [CmdletBinding(DefaultParameterSetName = 'ByName', SupportsShouldProcess)]

    param (

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('PolicyDN')]
        [String] $Path,

        [Parameter(Mandatory, ParameterSetName = 'ByName', ValueFromPipeline)]
        [String] $Name,

        [Parameter(ParameterSetName = 'ByName')]
        [Parameter(Mandatory, ParameterSetName = 'BySubject')]
        [Alias('Subject')]
        [String] $CommonName,

        [Parameter()]
        [String] $CertificateType,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('CertificateAuthorityDN')]
        [Alias('CADN')]
        [String] $CertificateAuthorityPath,

        [Parameter()]
        [Hashtable] $CertificateAuthorityAttribute,

        [Parameter()]
        [TppManagementType] $ManagementType,

        [Parameter()]
        [Hashtable[]] $SubjectAltName,

        [Parameter()]
        [Hashtable] $CustomField,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {

        $VenafiSession.Validate('TPP')

        if ( $PSBoundParameters.ContainsKey('SubjectAltName') ) {

            $errors = $SubjectAltName | ForEach-Object {
                $_.GetEnumerator() | ForEach-Object {

                    $thisKey = $_.Key
                    $thisValue = $_.Value

                    switch ($thisKey) {
                        'OtherName' {
                            # no validaton
                        }

                        'Email' {
                            try {
                                $null = [mailaddress]$thisValue
                            }
                            catch {
                                ('''{0}'' is not a valid email' -f $thisValue)
                            }
                        }

                        'DNS' {
                            # no validaton
                        }

                        'URI' {
                            # no validaton
                        }

                        'IPAddress' {
                            try {
                                $null = [ipaddress]$thisValue
                            }
                            catch {
                                ('''{0}'' is not a valid IP Address' -f $thisValue)
                            }
                        }

                        Default {
                            # invalid type name provided
                            ('''{0}'' is not a valid SAN type.  Valid values include OtherName, Email, DNS, URI, and IPAddress.' -f $thisKey)
                        }
                    }
                }
            }

            if ( $errors ) {
                throw $errors
            }
        }

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriLeaf       = 'certificates/request'
            Body          = @{
                PolicyDN             = $Path
                Origin               = 'VenafiPS'
                CASpecificAttributes = @(
                    @{
                        'Name'  = 'Origin'
                        'Value' = 'VenafiPS'
                    }
                )
            }
        }

        if ( $CertificateType ) {
            $params.Body.Add('CertificateType', $CertificateType)
        }

        if ( $PSBoundParameters.ContainsKey('CertificateAuthorityAttribute') ) {
            $CertificateAuthorityAttribute.GetEnumerator() | ForEach-Object {

                $params.Body.CASpecificAttributes +=
                @{
                    'Name'  = $_.Key
                    'Value' = $_.Value
                }
            }
        }

        if ( $PSBoundParameters.ContainsKey('CertificateAuthorityPath') ) {
            $params.Body.Add('CADN', $CertificateAuthorityPath)
        }

        if ( $PSBoundParameters.ContainsKey('CommonName') ) {
            $params.Body.Add('Subject', $CommonName)
        }

        if ( $PSBoundParameters.ContainsKey('ManagementType') ) {
            $params.Body.Add('ManagementType', [enum]::GetName([TppManagementType], $ManagementType))
        }

        if ( $PSBoundParameters.ContainsKey('SubjectAltName') ) {
            $newSan = @($SubjectAltName | ForEach-Object {
                    $_.GetEnumerator() | ForEach-Object {
                        @{
                            'TypeName' = $_.Key
                            'Name'     = $_.Value
                        }
                    }
                }
            )
            $params.Body.Add('SubjectAltNames', $newSan)
        }

        if ( $PSBoundParameters.ContainsKey('CustomField') ) {
            $newCf = $CustomField.GetEnumerator() | ForEach-Object {

                @{
                    'Name'   = $_.Key
                    'Values' = @($_.Value)
                }
            }
            $params.Body.Add('CustomFields', @($newCf))
        }

    }

    process {

        $params.Body.ObjectName = $Name

        if ( $PSCmdlet.ShouldProcess($Path, 'Create new certificate') ) {

            try {
                $response = Invoke-VenafiRestMethod @params
                Write-Verbose ($response | Out-String)

                if ( $PassThru ) {
                    Get-TppObject -Path $response.CertificateDN -VenafiSession $VenafiSession
                }
            }
            catch {
                Write-Error $_
                continue
            }
        }
    }
}
