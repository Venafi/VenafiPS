function New-TppCapiApplication {
    <#
    .SYNOPSIS
    Create a new CAPI application

    .DESCRIPTION
    Create a new CAPI application

    .PARAMETER Path
    Full path, including name, to the application to be created.  The application must be created under a device.
    Alternatively, provide the path to the device and provide ApplicationName.

    .PARAMETER ApplicationName
    1 or more application names to create.  Path property must be a path to a device.

    .PARAMETER CertificatePath
    Path to the certificate to associate to the new application

    .PARAMETER CredentialPath
    Path to the associated credential which has rights to access the connected device

    .PARAMETER FriendlyName
    The Friendly Name that helps to uniquely identify the certificate after it has been installed in the Windows CAPI store

    .PARAMETER Descripion
    Application description

    .PARAMETER WinRmPort
    WinRM port to connect to application on

    .PARAMETER Disable
    Set processing to disabled.  It is enabled by default.

    .PARAMETER WebSiteName
    The unique name of the IIS web site

    .PARAMETER BindingIp
    The IP address to bind the certificate to the IIS web site. If not specified, the Internet Information Services (IIS) Manager console shows 'All Unassigned'.

    .PARAMETER BindingPort
    The TCP port 1 to 65535 to bind the certificate to the IIS web site

    .PARAMETER BindingHostName
    The hostname to bind the certificate to the IIS web site. Specifying this value will make it so the certificate is only accessible to clients using Server Name Indication (SNI)

    .PARAMETER CreateBinding
    Specify that Trust Protection Platform should create an IIS web site binding if the one specified doesn’t already exist.

    .PARAMETER PushCertificate
    Push the certificate to the application.  CertificatePath must be provided.

    .PARAMETER SkipExistenceCheck
    By default, the paths for the new application, certifcate, and credential will be validated for existence.
    Specify this switch to bypass this check.

    .PARAMETER PassThru
    Return a TppObject representing the newly created capi app.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    Path

    .OUTPUTS
    TppObject, if PassThru provided

    .EXAMPLE
    New-TppCapiApplication -Path '\ved\policy\mydevice\capi' -CertificatePath $cert.Path -CredentialPath $cred.Path
    Create a new application

    .EXAMPLE
    New-TppCapiApplication -Path '\ved\policy\mydevice\capi' -CertificatePath $cert.Path -CredentialPath $cred.Path -WebSiteName 'mysite' -BindingIp '1.2.3.4'
    Create a new application and update IIS

    .EXAMPLE
    New-TppCapiApplication -Path '\ved\policy\mydevice\capi' -CertificatePath $cert.Path -CredentialPath $cred.Path -WebSiteName 'mysite' -BindingIp '1.2.3.4' -PushCertificate
    Create a new application, update IIS, and push the certificate to the new app

    .EXAMPLE
    New-TppCapiApplication -Path '\ved\policy\mydevice\capi' -CertificatePath $cert.Path -CredentialPath $cred.Path -PassThru
    Create a new application and return a TppObject for the newly created app

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/New-TppCapiApplication/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-TppCapiApplication.ps1

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-TppObject.ps1

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppCertificate/

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppObject/

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-create.php

    #>

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'NonIis')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]

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
        [string] $Path,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]] $ApplicationName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                } else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('CertificateDN')]
        [String] $CertificatePath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                } else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('CredentialDN')]
        [String] $CredentialPath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String] $FriendlyName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String] $Description,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Int] $WinRmPort,

        [Parameter()]
        [Switch] $Disable,

        [Parameter(Mandatory, ParameterSetName = 'Iis')]
        [ValidateNotNullOrEmpty()]
        [String] $WebSiteName,

        [Parameter(ParameterSetName = 'Iis')]
        [ValidateNotNullOrEmpty()]
        [Alias('BindingIpAddress')]
        [ipaddress] $BindingIp,

        [Parameter(ParameterSetName = 'Iis')]
        [ValidateNotNullOrEmpty()]
        [Int] $BindingPort,

        [Parameter(ParameterSetName = 'Iis')]
        [ValidateNotNullOrEmpty()]
        [String] $BindingHostName,

        [Parameter(ParameterSetName = 'Iis')]
        [ValidateNotNullOrEmpty()]
        [bool] $CreateBinding,

        [Parameter()]
        [switch] $PushCertificate,

        [Parameter()]
        [switch] $SkipExistenceCheck,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        if ( $PushCertificate.IsPresent -and (-not $PSBoundParameters.ContainsKey('CertificatePath')) ) {
            throw 'A CertificatePath must be provided when using PushCertificate'
        }

        if ( -not $PSBoundParameters.ContainsKey('SkipExistenceCheck') ) {

            if ( $PSBoundParameters.ContainsKey('CertificatePath') ) {
                # issue 129
                $certName = $CertificatePath.Split('\')[-1]
                $certPath = $CertificatePath -replace ('\\+{0}' -f $certName), ''

                $certObject = Find-TppCertificate -Path $certPath -VenafiSession $VenafiSession

                if ( -not $certObject -or ($certName -notin $certObject.Name) ) {
                    throw ('A certificate object could not be found at ''{0}''' -f $CertificatePath)
                }
            }

            # ensure the credential exists and is actually of type credential
            if ( $PSBoundParameters.ContainsKey('CredentialPath') ) {

                $credObject = Get-TppObject -Path $CredentialPath -VenafiSession $VenafiSession

                if ( -not $credObject -or $credObject.TypeName -notlike '*credential*' ) {
                    throw ('A credential object could not be found at ''{0}''' -f $CredentialPath)
                }
            }
        }

        $params = @{
            Path          = ''
            Class         = 'CAPI'
            Attribute     = @{
                'Driver Name' = 'appcapi'
            }
            PassThru      = $true
            VenafiSession = $VenafiSession
        }

        if ( $PSBoundParameters.ContainsKey('FriendlyName') ) {
            $params.Attribute.Add('Friendly Name', $FriendlyName)
        }

        if ( $PSBoundParameters.ContainsKey('CertificatePath') ) {
            $params.Attribute.Add('Certificate', $CertificatePath)
        }

        if ( $PSBoundParameters.ContainsKey('CredentialPath') ) {
            $params.Attribute.Add('Credential', $CredentialPath)
        }

        if ( $Disable.IsPresent ) {
            $params.Attribute.Add('Disabled', '1')
        }

        if ( $PSBoundParameters.ContainsKey('WebSiteName') ) {
            $params.Attribute.Add('Update IIS', '1')
            $params.Attribute.Add('Web Site Name', $WebSiteName)
        }

        if ( $PSBoundParameters.ContainsKey('BindingIp') ) {
            $params.Attribute.Add('Binding IP Address', $BindingIp.ToString())
        }

        if ( $PSBoundParameters.ContainsKey('BindingPort') ) {
            $params.Attribute.Add('Binding Port', $BindingPort.ToString())
        }

        if ( $PSBoundParameters.ContainsKey('BindingHostName') ) {
            $params.Attribute.Add('Hostname', $BindingHostName)
        }

        if ( $PSBoundParameters.ContainsKey('CreateBinding') ) {
            $params.Attribute.Add('Create Binding', ([int]$CreateBinding).ToString())
        }

        if ( $PSBoundParameters.ContainsKey('WinRmPort') ) {
            $params.Attribute.Add('Port', $WinRmPort.ToString())
        }
    }

    process {

        if ( -not $PSBoundParameters.ContainsKey('SkipExistenceCheck') ) {

            # ensure the parent path exists and is of type device
            if ( $PSBoundParameters.ContainsKey('ApplicationName') ) {
                $devicePath = $Path
            } else {
                $deviceName = $Path.Split('\')[-1]
                $devicePath = $Path -replace ('\\+{0}' -f $deviceName), ''
            }

            $device = Get-TppObject -Path $devicePath -VenafiSession $VenafiSession

            if ( $device ) {
                if ( $device.TypeName -ne 'Device' ) {
                    throw ('A device object could not be found at ''{0}''' -f $devicePath)
                }
            } else {
                throw ('No object was found at the parent path ''{0}''' -f $devicePath)
            }
        }

        if ( $PSBoundParameters.ContainsKey('ApplicationName') ) {
            $appPaths = $ApplicationName | ForEach-Object {
                $Path + "\$_"
            }
        } else {
            $appPaths = @($Path)
        }

        if ( $PSCmdlet.ShouldProcess($Path, 'Create CAPI application(s)') ) {
            foreach ($thisPath in $appPaths) {

                $params.Path = $thisPath


                $response = New-TppObject @params

                if ( $PassThru ) {
                    $response
                }
            }

            if ( $PushCertificate.IsPresent ) {
                $params = @{
                    CertificatePath = $CertificatePath
                    ApplicationPath = $appPaths
                    VenafiSession   = $VenafiSession
                }

                Invoke-TppCertificatePush @params
            }

        }
    }

    end {}
}