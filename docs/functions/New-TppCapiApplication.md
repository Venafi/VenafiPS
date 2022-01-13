# New-TppCapiApplication

## SYNOPSIS
Create a new CAPI application

## SYNTAX

### NonIis (Default)
```
New-TppCapiApplication -Path <String> [-ApplicationName <String[]>] [-CertificatePath <String>]
 [-CredentialPath <String>] [-FriendlyName <String>] [-Description <String>] [-WinRmPort <Int32>] [-Disable]
 [-PushCertificate] [-SkipExistenceCheck] [-PassThru] [-VenafiSession <VenafiSession>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Iis
```
New-TppCapiApplication -Path <String> [-ApplicationName <String[]>] [-CertificatePath <String>]
 [-CredentialPath <String>] [-FriendlyName <String>] [-Description <String>] [-WinRmPort <Int32>] [-Disable]
 -WebSiteName <String> [-BindingIp <IPAddress>] [-BindingPort <Int32>] [-BindingHostName <String>]
 [-CreateBinding <Boolean>] [-PushCertificate] [-SkipExistenceCheck] [-PassThru]
 [-VenafiSession <VenafiSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Create a new CAPI application

## EXAMPLES

### EXAMPLE 1
```
New-TppCapiApplication -Path '\ved\policy\mydevice\capi' -CertificatePath $cert.Path -CredentialPath $cred.Path
Create a new application
```

### EXAMPLE 2
```
New-TppCapiApplication -Path '\ved\policy\mydevice\capi' -CertificatePath $cert.Path -CredentialPath $cred.Path -WebSiteName 'mysite' -BindingIp '1.2.3.4'
Create a new application and update IIS
```

### EXAMPLE 3
```
New-TppCapiApplication -Path '\ved\policy\mydevice\capi' -CertificatePath $cert.Path -CredentialPath $cred.Path -WebSiteName 'mysite' -BindingIp '1.2.3.4' -PushCertificate
Create a new application, update IIS, and push the certificate to the new app
```

### EXAMPLE 4
```
New-TppCapiApplication -Path '\ved\policy\mydevice\capi' -CertificatePath $cert.Path -CredentialPath $cred.Path -PassThru
Create a new application and return a TppObject for the newly created app
```

## PARAMETERS

### -Path
Full path, including name, to the application to be created. 
The application must be created under a device.
Alternatively, provide the path to the device and provide ApplicationName.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ApplicationName
1 or more application names to create. 
Path property must be a path to a device.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertificatePath
Path to the certificate to associate to the new application

```yaml
Type: String
Parameter Sets: (All)
Aliases: CertificateDN

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CredentialPath
Path to the associated credential which has rights to access the connected device

```yaml
Type: String
Parameter Sets: (All)
Aliases: CredentialDN

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FriendlyName
The Friendly Name that helps to uniquely identify the certificate after it has been installed in the Windows CAPI store

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
{{ Fill Description Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WinRmPort
WinRM port to connect to application on

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Disable
Set processing to disabled. 
It is enabled by default.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WebSiteName
The unique name of the IIS web site

```yaml
Type: String
Parameter Sets: Iis
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BindingIp
The IP address to bind the certificate to the IIS web site.
If not specified, the Internet Information Services (IIS) Manager console shows 'All Unassigned'.

```yaml
Type: IPAddress
Parameter Sets: Iis
Aliases: BindingIpAddress

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BindingPort
The TCP port 1 to 65535 to bind the certificate to the IIS web site

```yaml
Type: Int32
Parameter Sets: Iis
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -BindingHostName
The hostname to bind the certificate to the IIS web site.
Specifying this value will make it so the certificate is only accessible to clients using Server Name Indication (SNI)

```yaml
Type: String
Parameter Sets: Iis
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreateBinding
Specify that Trust Protection Platform should create an IIS web site binding if the one specified doesn't already exist.

```yaml
Type: Boolean
Parameter Sets: Iis
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PushCertificate
Push the certificate to the application. 
CertificatePath must be provided.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipExistenceCheck
By default, the paths for the new application, certifcate, and credential will be validated for existence.
Specify this switch to bypass this check.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Return a TppObject representing the newly created capi app.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -VenafiSession
Session object created from New-VenafiSession method. 
The value defaults to the script session object $VenafiSession.

```yaml
Type: VenafiSession
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $script:VenafiSession
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Path
## OUTPUTS

### TppObject, if PassThru provided
## NOTES

## RELATED LINKS

[http://VenafiPS.readthedocs.io/en/latest/functions/New-TppCapiApplication/](http://VenafiPS.readthedocs.io/en/latest/functions/New-TppCapiApplication/)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-TppCapiApplication.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-TppCapiApplication.ps1)

[https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-TppObject.ps1](https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-TppObject.ps1)

[http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppCertificate/](http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppCertificate/)

[http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppObject/](http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppObject/)

[https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-create.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____9](https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-create.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____9)

