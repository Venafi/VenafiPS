<#
.SYNOPSIS
Update credential values

.DESCRIPTION
Update values for credential objects in TPP.
The values allowed to be updated are specific to the object type.
See https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Credentials-FriendlyName.php for details.

.PARAMETER Path
The full path to the credential object

.PARAMETER Value
Hashtable containing the keys/values to be updated

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
Path

.OUTPUTS
None

.EXAMPLE
Set-TppCredential -Path '\VED\Policy\Password Credential' -Value @{'Password'='my-new-password'}
Set a value

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppCredential/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Set-TppCredential.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Credentials-update.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Credentials-FriendlyName.php

#>
function Set-TppCredential {

    [CmdletBinding(SupportsShouldProcess)]

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

        [Parameter(Mandatory)]
        [hashtable] $Value,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            UriLeaf       = 'Credentials/Update'
            Body          = @{}
        }

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
        $tppObject = Get-TppObject -Path $Path -VenafiSession $VenafiSession
        $thisType = $tppObject.TypeName
        if ( -not $CredTypes[$thisType] ) {
            throw "Credential type '$thisType' is not supported yet.  Submit an enhancement request."
        }
        $friendlyName = $CredTypes[$thisType].FriendlyName

        # ensure the values looking to be updated are appropriate for this object type
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

        $params.Body.CredentialPath = $Path
        $params.Body.FriendlyName = $friendlyName
        $params.Body.Values = @($newValues)

        if ( $PSCmdlet.ShouldProcess( $Path )) {
            $response = Invoke-VenafiRestMethod @params

            if ( $response.Result -ne 1 ) {
                Write-Error $response.Error
            }
        }
    }
}