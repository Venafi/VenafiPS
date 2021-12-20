<#
.SYNOPSIS
Remove permissions from TPP objects

.DESCRIPTION
Remove permissions from TPP objects
You can opt to remove permissions for a specific user or all assigned

.PARAMETER Path
Full path to an object.  You can also pipe in a TppObject

.PARAMETER IdentityId
Prefixed Universal Id of the user or group to have their permissions removed

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Path, Guid, IdentityId

.OUTPUTS
None

.EXAMPLE
Find-TppObject -Path '\VED\Policy\My folder' | Remove-TppPermission
Remove all permissions from a specific object

.EXAMPLE
Find-TppObject -Path '\VED' -Recursive | Remove-TppPermission -IdentityId 'AD+blah:879s8d7f9a8ds7f9s8d7f9'
Remove all permissions for a specific user

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Remove-TppPermission/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Remove-TppPermission.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-DELETE-Permissions-object-guid-principal.php?tocpath=Web%20SDK%7CPermissions%20programming%20interface%7C_____6

#>
function Remove-TppPermission {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'ByGuid')]
    param (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByPath')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                } else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [String[]] $Path,

        [Parameter(Mandatory, ParameterSetName = 'ByGuid', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('ObjectGuid')]
        [guid[]] $Guid,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript( {
                if ( $_ | Test-TppIdentityFormat ) {
                    $true
                } else {
                    throw "'$_' is not a valid Prefixed Universal Id format.  See https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-IdentityInformation.php."
                }
            })]
        [Alias('PrefixedUniversalId')]
        [string[]] $IdentityId,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate() | Out-Null

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Delete'
            UriLeaf    = 'placeholder'
        }
    }

    process {

        Write-Verbose ('Parameter set: {0}' -f $PSCmdLet.ParameterSetName)

        if ( $PSCmdLet.ParameterSetName -eq 'ByPath' ) {
            $inputObject = $Path
        } else {
            $inputObject = $Guid
        }

        foreach ($thisInputObject in $inputObject) {
            if ( $PSCmdLet.ParameterSetName -eq 'ByPath' ) {
                $thisGuid = $thisInputObject | ConvertTo-TppGuid
            } else {
                $thisGuid = $thisInputObject
            }

            $uriBase = "Permissions/object/{$thisGuid}"
            $params.UriLeaf = $uriBase

            if ( $PSBoundParameters.ContainsKey('IdentityId') ) {
                $identities = $IdentityId
            } else {
                # get list of identities permissioned to this object
                $getParams = $params.Clone()
                $getParams.Method = 'Get'
                $identities = Invoke-TppRestMethod @getParams
            }

            foreach ( $thisIdentity in $identities ) {

                $params.UriLeaf = $uriBase

                if ( $thisIdentity.StartsWith('local:') ) {
                    # format of local is local:universalId
                    $type, $id = $thisIdentity.Split(':')
                    $params.UriLeaf += "/local/$id"
                } else {
                    # external source, eg. AD, LDAP
                    # format is type+name:universalId
                    $type, $name, $id = $thisIdentity -Split { $_ -in '+', ':' }
                    $params.UriLeaf += "/$type/$name/$id"
                }

                if ( $PSCmdlet.ShouldProcess($thisGuid, "Remove permissions for $thisIdentity") ) {
                    try {
                        Invoke-TppRestMethod @params
                    } catch {
                        Write-Error ("Failed to remove permissions on path $thisGuid, user/group $thisIdentity.  $_")
                    }
                }
            }
        }
    }
}
