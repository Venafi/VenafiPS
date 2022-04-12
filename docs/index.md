# VenafiPS - Automate your Venafi Trust Protection Platform and Venafi as a Service platforms!

Welcome to VenafiPS.  Here you will find a PowerShell module to automate Venafi Trust Protection Platform core functionality as well as code signing.  Support for Venafi as a Service has also recently been added.  Please let us know how you are using this module and what we can do to make it better!  Ask questions or provide feedback in the Discussions section or feel free to submit an issue.

!!! note

As of version 4.0, the license has changed and is now Apache 2.0

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

As the module supports both TPP and Venafi as a Service, you will note different names for the functions.  Functions with `-Tpp` are for TPP only, `-Vaas` are for Venafi as a Service only, and `-Venafi` are for both.

Start a new PowerShell prompt (even if you have one from the install-module step) and create a new VenafiPS session with

```powershell
$cred = Get-Credential

# obtain new oauth token
New-VenafiSession -Server 'venafi.mycompany.com' -Credential $cred -ClientId 'MyApp' -Scope @{'certificate'='manage'}

# obtain new oauth token and store access token for later use
New-VenafiSession -Server 'venafi.mycompany.com' -Credential $cred -ClientId 'MyApp' -Scope @{'certificate'='manage'} -VaultAccessTokenName TppAccessToken

# obtain new oauth token and store refresh token for later use
New-VenafiSession -Server 'venafi.mycompany.com' -Credential $cred -ClientId 'MyApp' -Scope @{'certificate'='manage'} -VaultRefreshTokenName TppRefreshToken

# create a session for VaaS
New-VenafiSession -VaasKey $cred
```

The above will create a session which will be used by default in other functions.
View the help on all the ways you can create a new Venafi session with `help New-VenafiSession -full`.

For VaaS, your API key can be found in your user profile->preferences.

Helpful with devops scenarios including pipelines, you can provide either a VaaS key or TPP token for `-VenafiSession` for all function calls with no need to execute `New-VenafiSession` first.  If using TPP, an environment variable named `TppServer` must be set first.

### Examples
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

To perform many of the core certificate actions, we will use `Invoke-VenafiCertificateAction`.  For example, to create a new session and renew a certificate, use the following:

```powershell
New-VenafiSession -Server 'venafi.mycompany.com' -Credential $cred -ClientId 'MyApp' -Scope @{'certificate'='manage'}
Invoke-VenafiCertificateAction -CertificateId '\VED\Policy\My folder\app.mycompany.com' -Renew
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

## Token/Key Secret Storage

To securely store and retrieve secrets, VenafiPS has added support for the [PowerShell SecretManagement module](https://github.com/PowerShell/SecretManagement).  This can be used to store your access tokens, refresh tokens, or vaas key.  To use this feature, a vault will need to be created.  You can use [SecretStore](https://github.com/PowerShell/SecretStore) provided by the PowerShell team or any other vault type.  All of this functionality has been added to `New-VenafiSession`.  To prepare your environment, execute the following:
- `Install-Module Microsoft.PowerShell.SecretManagement`
- `Install-Module Microsoft.PowerShell.SecretStore` or whichever vault you would like to use
- `Register-SecretVault -Name VenafiPS -ModuleName Microsoft.PowerShell.SecretStore`.  If you are using a different vault type, replace the value for `-ModuleName`.
- If using the vault Microsoft.PowerShell.SecretStore, execute `Set-SecretStoreConfiguration -Authentication None -Confirm:$false`.  Note, although the vault authentication is set to none, this just turns off the password required to access the vault, it does not mean your secrets are not encrypted.  This is required for automation purposes.  If using a different vault type, ensure you turn off any features which inhibit automation.
- Check out the help for `New-VenafiSession` for the many ways you can store and retrieve secrets from the vault, but the easiest way to get started is:
  - `New-VenafiSession -Server my.venafi.com -Credential $myCred -ClientId MyApp -Scope $scope -VaultRefreshTokenName tpp-token -VaultMetadata`.  This will create a new token based session and store the refresh token in the vault.  `-VaultMetadata` will store the server and clientid with the refresh token as metadata.  Scope does not need to be stored as it is inherent in the token.
  - To create a new session going forward, `New-VenafiSession -VaultRefreshTokenName tpp-token`.  This will retrieve the refresh token and associated metadata from the vault, retrieve a new access token based on that refresh token and create a new session.

Note, extension vaults are registered to the current logged in user context, and will be available only to that user (unless also registered to other users).

## Contributing

Please feel free to log an issue for any new features you would like, bugs you come across, or just simply a question.  I am happy to have people contribute to the codebase as well.