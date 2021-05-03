<#
.SYNOPSIS
Create a new Venafi TPP or Venafi as a Service session

.DESCRIPTION
Authenticate a user and create a new session with which future calls can be made.
Key based username/password and windows integrated are supported as well as token-based integrated, oauth, and certificate.
Note, key-based authentication will be fully deprecated in v20.4.

.PARAMETER Server
Server or url to access vedsdk, venafi.company.com or https://venafi.company.com.
If AuthServer is not provided, this will be used to access vedauth as well for token-based authentication.
If just the server name is provided, https:// will be appended.

.PARAMETER Credential
Username and password used for key and token-based authentication.  Not required for integrated authentication.

.PARAMETER Certificate
Certificate for token-based authentication

.PARAMETER ClientId
Applcation Id configured in Venafi for token-based authentication

.PARAMETER Scope
Hashtable with Scopes and privilege restrictions.
The key is the scope and the value is one or more privilege restrictions separated by commas, @{'certificate'='delete,manage'}.
Scopes include Agent, Certificate, Code Signing, Configuration, Restricted, Security, SSH, and statistics.
For no privilege restriction or read access, use a value of $null.
For a scope to privilege mapping, see https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/AuthSDK/r-SDKa-OAuthScopePrivilegeMapping.php?tocpath=Auth%20SDK%20reference%20for%20token%20management%7C_____5

.PARAMETER State
A session state, redirect URL, or random string to prevent Cross-Site Request Forgery (CSRF) attacks

.PARAMETER AccessToken
Access token retrieved outside this module.  Provide a credential object with the access token as the password.

.PARAMETER AuthServer
If you host your authentication service, vedauth, on a separate server than vedsdk, use this parameter to specify the url eg., venafi.company.com or https://venafi.company.com.
If AuthServer is not provided, the value provided for Server will be used.
If just the server name is provided, https:// will be appended.

.PARAMETER PassThru
Optionally, send the session object to the pipeline instead of script scope.

.OUTPUTS
VenafiSession, if PassThru is provided

.EXAMPLE
New-VenafiSession -Server venafitpp.mycompany.com
Create key-based session using Windows Integrated authentication

.EXAMPLE
New-VenafiSession -Server venafitpp.mycompany.com -Credential $cred
Create key-based session using Windows Integrated authentication

.EXAMPLE
New-VenafiSession -Server venafitpp.mycompany.com -ClientId MyApp -Scope @{'certificate'='manage'}
Create token-based session using Windows Integrated authentication with a certain scope and privilege restriction

.EXAMPLE
New-VenafiSession -Server venafitpp.mycompany.com -AuthServer tppauth.mycompany.com -ClientId MyApp -Credential $cred
Create token-based session using oauth authentication where the vedauth and vedsdk are hosted on different servers

.EXAMPLE
$sess = New-VenafiSession -Server venafitpp.mycompany.com -Credential $cred -PassThru
Create session and return the session object instead of setting to script scope variable

.EXAMPLE
New-VenafiSession -Server venafitpp.mycompany.com -AccessToken $cred
Create session using an access token obtained outside this module

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/New-VenafiSession/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/New-VenafiSession.ps1

.LINK
https://docs.venafi.com/Docs/19.4/TopNav/Content/SDK/WebSDK/API_Reference/r-SDK-POST-Authorize.php?tocpath=Topics%20by%20Guide%7CDeveloper%27s%20Guide%7CWeb%20SDK%20reference%7CAuthentication%20programming%20interfaces%7C_____1

.LINK
https://docs.venafi.com/Docs/19.4/TopNav/Content/SDK/WebSDK/API_Reference/r-SDK-GET-Authorize-Integrated.php?tocpath=Topics%20by%20Guide%7CDeveloper%27s%20Guide%7CWeb%20SDK%20reference%7CAuthentication%20programming%20interfaces%7C_____3

.LINK
https://docs.venafi.com/Docs/20.1SDK/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-Authorize-Integrated.php?tocpath=Auth%20SDK%20reference%20for%20token%20management%7C_____10

.LINK
https://docs.venafi.com/Docs/20.1SDK/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-AuthorizeOAuth.php?tocpath=Auth%20SDK%20reference%20for%20token%20management%7C_____11

.LINK
https://docs.venafi.com/Docs/20.1/TopNav/Content/SDK/AuthSDK/r-SDKa-POST-AuthorizeCertificate.php?tocpath=Topics%20by%20Guide%7CDeveloper%27s%20Guide%7CAuth%20SDK%20reference%20for%20token%20management%7C_____9
#>
function New-VenafiSession {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'KeyIntegrated')]

    param(
        [Parameter(Mandatory, ParameterSetName = 'KeyCredential')]
        [Parameter(Mandatory, ParameterSetName = 'KeyIntegrated')]
        [Parameter(Mandatory, ParameterSetName = 'TokenOAuth')]
        [Parameter(Mandatory, ParameterSetName = 'TokenIntegrated')]
        [Parameter(Mandatory, ParameterSetName = 'TokenCertificate')]
        [Parameter(Mandatory, ParameterSetName = 'AccessToken')]
        # [Parameter(Mandatory, ParameterSetName = 'TppToken', ValueFromPipelineByPropertyName)]
        [ValidateScript( {
                if ( $_ -match '^(https?:\/\/)?(((?!-))(xn--|_{1,1})?[a-z0-9-]{0,61}[a-z0-9]{1,1}\.)*(xn--)?([a-z0-9][a-z0-9\-]{0,60}|[a-z0-9-]{1,30}\.[a-z]{2,})$' ) {
                    $true
                } else {
                    throw "'$_' is not a valid server url, it should look like https://venafi.company.com or venafi.company.com"
                }
            }
        )]
        [Alias('ServerUrl', 'Url')]
        [string] $Server,

        [Parameter(Mandatory, ParameterSetName = 'KeyCredential')]
        [Parameter(Mandatory, ParameterSetName = 'TokenOAuth')]
        [System.Management.Automation.PSCredential] $Credential,

        [Parameter(Mandatory, ParameterSetName = 'TokenIntegrated')]
        [Parameter(Mandatory, ParameterSetName = 'TokenOAuth')]
        # [Parameter(Mandatory, ParameterSetName = 'TppToken', ValueFromPipelineByPropertyName)]
        [string] $ClientId,

        [Parameter(Mandatory, ParameterSetName = 'TokenIntegrated')]
        [Parameter(Mandatory, ParameterSetName = 'TokenOAuth')]
        # [Parameter(Mandatory, ParameterSetName = 'TppToken', ValueFromPipelineByPropertyName)]
        [hashtable] $Scope,

        [Parameter(ParameterSetName = 'TokenIntegrated')]
        [Parameter(ParameterSetName = 'TokenOAuth')]
        [string] $State,

        # [Parameter(Mandatory, ParameterSetName = 'TppToken')]
        # [ValidateScript( {
        #         if ( $_.AccessToken -and $_.AuthUrl -and $_.ClientId  ) {
        #             $true
        #         } else {
        #             throw 'Object provided for TppToken is not valid.  Please request a new token with New-TppToken.'
        #         }
        #     }
        # )]
        # [pscustomobject] $TppToken,

        # [Parameter(Mandatory, ParameterSetName = 'TppToken', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'AccessToken', ValueFromPipelineByPropertyName)]
        [PSCredential] $AccessToken,

        [Parameter(Mandatory, ParameterSetName = 'TokenCertificate')]
        [X509Certificate] $Certificate,

        [Parameter(ParameterSetName = 'TokenOAuth')]
        [Parameter(ParameterSetName = 'TokenIntegrated')]
        [ValidateScript( {
                if ( $_ -match '^(https?:\/\/)?(((?!-))(xn--|_{1,1})?[a-z0-9-]{0,61}[a-z0-9]{1,1}\.)*(xn--)?([a-z0-9][a-z0-9\-]{0,60}|[a-z0-9-]{1,30}\.[a-z]{2,})$' ) {
                    $true
                } else {
                    throw 'Please enter a valid server, https://venafi.company.com or venafi.company.com'
                }
            }
        )]
        [string] $AuthServer,

        [Parameter(Mandatory, ParameterSetName = 'Vaas')]
        [guid] $VaasKey,

        [Parameter()]
        [switch] $PassThru
    )

    $isVerbose = if ($PSBoundParameters.Verbose -eq $true) { $true } else { $false }

    $serverUrl = $Server
    # add prefix if just server url was provided
    if ( $Server -notlike 'https://*') {
        $serverUrl = 'https://{0}' -f $serverUrl
    }

    $newSession = [VenafiSession] @{
        ServerUrl = $serverUrl
    }

    Write-Verbose ('Parameter set: {0}' -f $PSCmdlet.ParameterSetName)

    if ( $PSCmdlet.ShouldProcess($Server, 'New session') ) {
        Switch -Wildcard ($PsCmdlet.ParameterSetName)	{

            "Key*" {

                Write-Warning 'Key-based authentication will be deprecated in release 20.4 in favor of token-based'

                if ( $PsCmdlet.ParameterSetName -eq 'KeyCredential' ) {
                    $newSession.Connect($Credential)
                } else {
                    # integrated
                    $newSession.Connect($null)
                }

            }

            'Token*' {
                $params = @{
                    AuthServer = $serverUrl
                    ClientId   = $ClientId
                    Scope      = $Scope
                }

                # in case the auth server isn't the same as vedsdk...
                if ( $AuthServer ) {
                    $params.AuthServer = $AuthServer
                }

                if ($Credential) {
                    $params.Credential = $Credential
                }

                if ($Certificate) {
                    $params.Certificate = $Certificate
                }

                if ($State) {
                    $params.State = $State
                }

                $token = New-TppToken @params -Verbose:$isVerbose
                $newSession.Token = $token
                $newSession.Expires = $token.Expires
            }

            'TppToken' {
                $newSession.Token = [PSCustomObject]@{
                    AccessToken = $AccessToken
                    ClientId    = $ClientId
                    Scope       = $Scope
                }
            }

            'AccessToken' {
                $newSession.Token = [PSCustomObject]@{
                    AccessToken = $AccessToken
                }
            }

            'Vaas' {
                $newSession.ServerUrl = $script:CloudUrl
                # $newSession.Key = $VaasKey.ToString() | ConvertTo-SecureString -AsPlainText -Force
                $newSession.Key = New-Object System.Management.Automation.PSCredential('vaas', ($VaasKey.ToString() | ConvertTo-SecureString -AsPlainText -Force))
                # $newSession.Version = (Get-TppVersion -VenafiSession $newSession)
            }

            Default {
                throw ('Unknown parameter set {0}' -f $PSCmdlet.ParameterSetName)
            }
        }


        # will fail if user is on an older version
        # this isn't required so bypass on failure

        if ( $PSCmdlet.ParameterSetName -ne 'VaasKey' ) {
            $newSession.Version = (Get-TppVersion -VenafiSession $newSession -ErrorAction SilentlyContinue)
            $certFields = Get-TppCustomField -VenafiSession $newSession -Class 'X509 Certificate' -ErrorAction SilentlyContinue
            $deviceFields = Get-TppCustomField -VenafiSession $newSession -Class 'Device' -ErrorAction SilentlyContinue
            $allFields = $certFields.Items
            $allFields += $deviceFields.Items | Where-Object { $_.Guid -notin $allFields.Guid }
            $newSession.CustomField = $allFields
        }

        if ( $PassThru ) {
            $newSession
        } else {
            $Script:VenafiSession = $newSession
        }
    }
}
