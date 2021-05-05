# VenafiPS - Automate your Venafi Trust Protection Platform and Venafi as a Service platforms!

[![Build Status](https://dev.azure.com/gd-barron/VenafiTppPS/_apis/build/status/VenafiPS?branchName=main)](https://dev.azure.com/gd-barron/VenafiTppPS/_build/latest?definitionId=6&branchName=main)
[![Documentation Status](https://readthedocs.org/projects/venafips/badge/?version=latest)](https://venafips.readthedocs.io/en/latest/?badge=latest)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/VenafiPS?style=plastic)](https://www.powershellgallery.com/packages/VenafiPS)
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/VenafiPS?style=plastic)

## Documentation

Documentation can be found at [http://VenafiPS.readthedocs.io](http://VenafiPS.readthedocs.io) or by using built-in PowerShell help.  Every effort has been made to document each parameter and provide good examples.

## Supported Platforms

| OS             | PowerShell Version Tested | Status  |
| -------------- |--------------------| -----|
| Windows        | 5.1                | **Working!** |
| Windows        | Core 6.2.3+         | **Working!** |
| MacOS          | Core 6.2.3+         | **Working!** |
| Linux (Ubuntu 18.04) | Core 6.2.3+         | **Working!** |

## Install Module

VenafiPS is published to the PowerShell Gallery.  The most recent version is listed in the badge 'powershell gallery' above and can be viewed by clicking on it.  To install the module, you need to have PowerShell installed first.  On Windows, PowerShell will already be installed.  For [Linux](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7) or [macOS](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powershell-7), you will need to install PowerShell Core; follow those links for guidance.  Once PowerShell is installed, start a PowerShell prompt and execute `Install-Module -Name VenafiPS` which will install from the gallery.

## Usage

Start a new PowerShell prompt (even if you have one from the Install Module step) and create a new VenafiPS session with

```powershell
$cred = Get-Credential
New-VenafiSession -Server 'venafi.mycompany.com' -Credential $cred -ClientId 'MyApp' -Scope @{'certificate'='manage'}
```

This will create a session which will be used by default in other functions.
You can also use integrated authentication, simply exclude `-Credential $cred`.
Beginning with v3.0, you can connect to Venafi as a Service as well with `New-VenafiSession -Server 'venafi.mycompany.com' -VaasKey $apikeyCred`.  Your API key can be found in your user profile->preferences.
View the help on all the ways you can create a new Venafi session with `help New-VenafiSession -full`.

One of the easiest ways to get started is to use `Find-TppObject`:

```powershell
$allPolicy = Find-TppObject -Path '\ved\policy' -Recursive
```

This will return all objects in the Policy folder.  You can also search from the root folder, \ved.

To find a certificate object, not retrieve an actual certificate, use:
```powershell
$cert = Find-TppCertificate -Limit 1
```

Check out the parameters for `Find-TppCertificate` as there's an extensive list to search on.

Now you can take that certificate 'TppObject' and find all log entries associated with it:

```powershell
$cert | Read-TppLog
```

You can also have multiple sessions at once, either to the same server with different credentials or different servers.
This can be helpful to determine the difference between what different users can access or perhaps compare folder structures across environments.  The below will compare the objects one user can see vs. another.

```powershell
# assume you've created 1 session already as shown above...

$user2Cred = Get-Credential # specify credentials for a different/limited user

# get a session as user2 and save the session in a variable
$user2Session = New-VenafiSession -ServerUrl 'https://venafi.mycompany.com' -Credential $user2Cred -PassThru

# get all objects in the Policy folder for the first user
$all = Find-TppObject -Path '\ved\policy' -Recursive

# get all objects in the Policy folder for user2
$all2 = Find-TppObject -Path '\ved\policy' -Recursive -VenafiSession $user2Session

Compare-Object -ReferenceObject $all -DifferenceObject $all2 -Property Path
```

## Contributing

Please feel free to log an issue for any new features you would like, bugs you come across, or just simply a question.  I am happy to have people contribute to the codebase as well.
