<#
.SYNOPSIS
Set permissions for TPP objects

.DESCRIPTION
Adds or modifies permissions on TPP objects

.PARAMETER Path
Path to an object.  Can pipe output from many other functions.

.PARAMETER Guid
Guid representing a unique object

.PARAMETER IdentityId
The id that represents the user or group.  You can use Find-TppIdentity or Get-TppPermission to get the id.

.PARAMETER Permission
TppPermission object.  You can create a new object or get existing object from Get-TppPermission.

.PARAMETER Force
Overwrite an existing permission if one exists

.PARAMETER TppSession
Session object created from New-TppSession method.  The value defaults to the script session object $TppSession.

.INPUTS
Path, Guid, IdentityId

.OUTPUTS
None

.EXAMPLE
Set-TppPermission -Guid '1234abcd-g6g6-h7h7-faaf-f50cd6610cba' -IdentityId 'AD+mydomain.com:azsxdcfvgbhnjmlk09877654321' -Permission $TppPermObject

Permission a user/group on an object specified by guid

.EXAMPLE
Set-TppPermission -Path '\ved\policy\my folder' -IdentityId 'AD+mydomain.com:azsxdcfvgbhnjmlk09877654321' -Permission $TppPermObject

Permission a user/group on an object specified by path

.EXAMPLE
$id = Find-TppIdentity -Name 'brownstein' | Select-Object -ExpandProperty IdentityId
Find-TppObject -Path '\VED' -Recursive | Get-TppPermission -IdentityId $id | Set-TppPermission -Permission $TppPermObject -Force

Reset permissions for a specific user/group for all objects.  Note the use of -Force to overwrite existing permissions.

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Set-TppPermission/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Set-TppPermission.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Permissions-object-guid-principal.php?tocpath=Web%20SDK%7CPermissions%20programming%20interface%7C_____8

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-PUT-Permissions-object-guid-principal.php?tocpath=Web%20SDK%7CPermissions%20programming%20interface%7C_____9

.NOTES
Confirmation impact is set to Medium, set ConfirmPreference accordingly.
#>
function Set-TppPermission {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'ByGuid')]
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
        [Alias('DN')]
        [String[]] $Path,

        [Parameter(Mandatory, ParameterSetName = 'ByGuid', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('ObjectGuid')]
        [guid[]] $Guid,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript( {
                if ( $_ | Test-TppIdentityFormat ) {
                    $true
                } else {
                    throw "'$_' is not a valid Prefixed Universal Id format.  See https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-IdentityInformation.php."
                }
            })]
        [Alias('PrefixedUniversalId', 'ID')]
        [string[]] $IdentityId,

        [Parameter(Mandatory)]
        [TppPermission] $Permission,

        [Parameter()]
        [switch] $Force,

        [Parameter()]
        [TppSession] $TppSession = $Script:TppSession
    )

    begin {
        $TppSession.Validate()

        $params = @{
            TppSession = $TppSession
            Method     = 'Post'
            UriLeaf    = 'placeholder'
            Body       = $Permission.ToHashtable()
        }
    }

    process {

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

            $params.UriLeaf = "Permissions/object/{$thisGuid}"

            foreach ( $thisId in $IdentityId ) {

                if ( $thisId.StartsWith('local:') ) {
                    # format of local is local:universalId
                    $type, $id = $thisId.Split(':')
                    $params.UriLeaf += "/$type/$id"
                } else {
                    # external source, eg. AD, LDAP
                    # format is type+name:universalId
                    $type, $name, $id = $thisId -Split { $_ -in '+', ':' }
                    $params.UriLeaf += "/$type/$name/$id"
                }

                if ( $PSCmdlet.ShouldProcess($thisInputObject, "Set permission for $thisId") ) {
                    try {

                        $response = Invoke-TppRestMethod @params

                        switch ($response.StatusCode.value__) {

                            '201' {
                                # success
                            }

                            '409' {
                                # user/group already has permissions defined on this object
                                # need to use a put method instead
                                if ( $Force ) {

                                    Write-Verbose "Existing user/group found and Force option provided, updating existing permissions"
                                    $params.Method = 'Put'
                                    $response = Invoke-TppRestMethod @params
                                    if ( $response.StatusCode.value__ -ne '200' ) {
                                        Write-Error ('Failed to update permission with error {0}' -f $response.StatusDescription)
                                    }
                                } else {
                                    # force option not provided, let the user know what's up
                                    Write-Error ('Permission for {0} already exists.  To override, provide the Force option.' -f $thisId)
                                }
                            }

                            default {
                                # Write-Error ($response | ConvertTo-Json)
                                Write-Error ('Failed to create permission with error {0}, URL {1}' -f $response.StatusDescription, $response.ResponseUri)
                            }
                        }
                    } catch {
                        Write-Error ("Failed to set permissions on object $thisInputObject, user/group $thisId.  $_")
                    }
                }
            }
        }
    }
}
