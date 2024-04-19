function Set-VdcCredential {
    <#
    .SYNOPSIS
    Update credential values

    .DESCRIPTION
    Update values for credential objects in TLSPDC.
    The values allowed to be updated are specific to the object type.
    See https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Credentials-FriendlyName.php for details.

    .PARAMETER Path
    The full path to the credential object

    .PARAMETER Value
    Hashtable containing the keys/values to be updated.
    This parameter will be deprecated in a future release.  Use specific parameters for the credential type.

    .PARAMETER Password
    New password for a password, username/password, or certificate credential.  Provide a string, SecureString, or PSCredential.

    .PARAMETER Username
    New username for a username/password credential.
    A password is also required.

    .PARAMETER Certificate
    New certificate for a certificate credential.  Provide a Base64 encoded PKCS#12.
    A private key password is also required for -Password.

    .PARAMETER Expiration
    Expiration date in UTC for the credential.  Provide a DateTime object.
    This can be set for all credential types.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

    .INPUTS
    Path

    .OUTPUTS
    None

    .EXAMPLE
    Set-VdcCredential -Path '\VED\Policy\Password Credential' -Password 'my-new-password'

    Set a new password for a password credential

    .EXAMPLE
    Set-VdcCredential -Path '\VED\Policy\UsernamePassword Credential' -Password 'my-new-password' -Username 'greg'

    Set a new password for a username/password credential

    .EXAMPLE
    Set-VdcCredential -Path '\VED\Policy\Certificate Credential' -Password 'my-pk-password' -Certificate $p12

    Set a new certificate for a certificate credential

    .EXAMPLE
    Set-VdcCredential -Path '\VED\Policy\Password Credential' -Password 'my-new-password' -Expiration (Get-Date).AddDays(30)

    Set a new password for a password credential and set the expiration date to 30 days from now

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Set-VdcCredential/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Set-VdcCredential.ps1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Credentials-update.php

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Credentials-FriendlyName.php

    #>

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Password')]
    [Alias('Set-TppCredential')]

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

        [Parameter(ParameterSetName = 'Password', Mandatory)]
        [Parameter(ParameterSetName = 'UsernamePassword', Mandatory)]
        [Parameter(ParameterSetName = 'Certificate', Mandatory)]
        [psobject] $Password,

        [Parameter(ParameterSetName = 'UsernamePassword', Mandatory)]
        [string] $Username,

        [Parameter(ParameterSetName = 'Certificate', Mandatory)]
        [string] $Certificate,

        [Parameter()]
        [datetime] $Expiration,

        [Parameter(ParameterSetName = 'OldValue', Mandatory)]
        [hashtable] $Value,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VDC'

        $params = @{

            Method  = 'Post'
            UriLeaf = 'Credentials/Update'
            Body    = @{
                Values = @()
            }
        }

        if ( $PSBoundParameters.ContainsKey('Password') ) {
            $newPassword = if ( $Password -is [string] ) { $Password }
            elseif ($Password -is [securestring]) { ConvertFrom-SecureString -SecureString $Password -AsPlainText }
            elseif ($Password -is [pscredential]) { $Password.GetNetworkCredential().Password }
            else { throw 'Unsupported type for -Password.  Provide either a String, SecureString, or PSCredential.' }

            $params.Body.Values += @{
                'Name'  = 'Password'
                'Type'  = 'string'
                'Value' = $newPassword
            }
        }

        if ( $Username ) {
            $params.Body.Values += @{
                'Name'  = 'Username'
                'Type'  = 'string'
                'Value' = $Username
            }
        }

        if ( $Certificate ) {
            $params.Body.Values += @{
                'Name'  = 'Certificate'
                'Type'  = 'byte[]'
                'Value' = $Certificate
            }
        }

        if ( $Expiration ) {
            $params.Body.Expiration = '/Date({0})/' -f [int64]($Expiration.ToUniversalTime() - [datetime]'1970-01-01T00:00:00Z').TotalMilliseconds
        }

        # used with -Value parameter, to be deprecated
        $CredTypes = @{
            'Password Credential'          = @{
                'FriendlyName' = 'Password'
                'ValueName'    = @{
                    'Password' = 'string'
                }
            }
            'Username Password Credential' = @{
                'FriendlyName' = 'UsernamePassword'
                'ValueName'    = @{
                    'Username' = 'string'
                    'Password' = 'string'
                }
            }
            'Certificate Credential'       = @{
                'FriendlyName' = 'Certificate'
                'ValueName'    = @{
                    'Certificate' = 'byte[]'
                    'Password'    = 'string'
                }
            }
        }
    }

    process {

        # lookup path so we know the type of cred we're dealing with
        $tppObject = Get-VdcObject -Path $Path
        $thisType = $tppObject.TypeName


        # ensure the values looking to be updated are appropriate for this object type
        if ( $Values ) {
            Write-Warning "-Value will be deprecated in a future release.  Use specific parameters for the credential type instead."

            if ( -not $CredTypes[$thisType] ) {
                throw "Credential type '$thisType' is not supported yet.  Submit an enhancement request."
            }

            $friendlyName = $CredTypes[$thisType].FriendlyName
            $params.Body.FriendlyName = $friendlyName

            $newValues = $Value.GetEnumerator() | ForEach-Object {
                $thisValue = $CredTypes[$thisType].ValueName[$_.Key]
                if ( $thisValue ) {
                    @{
                        'Name'  = $_.Key
                        'Type'  = $thisValue
                        'Value' = $_.Value
                    }
                }
                else {
                    throw ('''{0}'' is not a valid item for type ''{1}''' -f $_.Key, $thisType)
                }
            }

            $params.Body.Values = @($newValues)
        }
        else {
            switch ($tppObject.TypeName) {
                'Password Credential' {
                    $params.Body.FriendlyName = 'Password'
                }
                'Username Password Credential' {
                    $params.Body.FriendlyName = 'UsernamePassword'
                }
                'Certificate Credential' {
                    $params.Body.FriendlyName = 'Certificate'
                }
                Default {
                    Write-Error "$Path : credential type '$thisType' is not supported yet.  Submit an enhancement request."
                    continue
                }
            }

            if ( $params.Body.FriendlyName -ne $PSCmdlet.ParameterSetName ) {
                Write-Error "$Path : the credential type for this object, $thisType, does not match the parameters provided"
                continue
            }
        }

        $params.Body.CredentialPath = $Path

        if ( $PSCmdlet.ShouldProcess( $Path )) {
            $response = Invoke-VenafiRestMethod @params

            if ( $response.Result -ne 1 ) {
                Write-Error $response.Error
            }
        }
    }
}