<#
.SYNOPSIS
Get permissions for TPP objects

.DESCRIPTION
Get permissions for users and groups on any object.
The effective permissions will be retrieved by default, but inherited/explicit permissions can optionally be retrieved.
You can retrieve all permissions for an object or for a specific user/group.

.PARAMETER InputObject
TppObject representing an object in TPP, eg. from Find-TppObject or Get-TppObject

.PARAMETER Path
Full path to an object

.PARAMETER Guid
Guid representing a unique object

.PARAMETER IdentityId
Specifying this optional parameter will only return objects that have permissions assigned to this id.
You can use Find-TppIdentity to search for identities.

.PARAMETER Explicit
Get explicit (direct) and implicit (inherited) permissions instead of effective.

.PARAMETER Attribute
Retrieve identity attribute values for the users and groups.
Attributes include Group Membership, Name, Internet Email Address, Given Name, Surname.
This parameter will be deprecated in a future release.

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
InputObject, Path, Guid, IdentityId

.OUTPUTS
PSCustomObject with the following properties:
    Path
    Guid
    Name
    TypeName
    IdentityId
    IdentityPath
    IdentityName
    EffectivePermissions (if Explicit switch is not used)
    ExplicitPermissions (if Explicit switch is used)
    ImplicitPermissions (if Explicit switch is used)
    Attribute (if Attribute parameter provided, to be deprecated)

.EXAMPLE
Get-TppObject -Path '\VED\Policy\My folder' | Get-TppPermission

Get all assigned effective permissions for users/groups on a specific policy folder

.EXAMPLE
Get-TppObject -Path '\VED\Policy\My folder' | Get-TppPermission -Explicit

Get explicit and implicit permissions for users/groups on a specific policy folder

.EXAMPLE
Find-TppObject -Path '\VED' -Recursive | Get-TppPermission -IdentityId 'AD+myprov:jasdf87s9dfsdfhkashfg78f7'

Find assigned permissions for a specific user across all objects

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppPermission/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppPermission.ps1

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppIdentityAttribute.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Permissions-object-guid.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Permissions-object-guid-external.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Permissions-object-guid-local.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Permissions-object-guid-principal.php

#>
function Get-TppPermission {

    [CmdletBinding(DefaultParameterSetName = 'ByObject')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'ByObject', ValueFromPipeline)]
        [TppObject] $InputObject,

        [Parameter(Mandatory, ParameterSetName = 'ByPath', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('DN')]
        [String[]] $Path,

        [Parameter(Mandatory, ParameterSetName = 'ByGuid', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('ObjectGuid')]
        [guid[]] $Guid,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript( {
                if ( $_ | Test-TppIdentityFormat ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid Identity format.  See https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-IdentityInformation.php."
                }
            })]
        [Alias('PrefixedUniversalId', 'ID')]
        [string[]] $IdentityId,

        [Parameter()]
        [Alias('ExplicitImplicit')]
        [switch] $Explicit,

        [Parameter()]
        [ValidateSet('Group Membership', 'Name', 'Internet Email Address', 'Given Name', 'Surname')]
        [string[]] $Attribute,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Get'
            UriLeaf       = 'placeholder'
        }
    }

    process {

        switch ( $PsCmdLet.ParameterSetName) {
            'ByObject' {
                $newInputObject = $InputObject
            }

            'ByPath' {
                $newInputObject = $Path
            }

            'ByGuid' {
                $newInputObject = $Guid
            }

            Default {
                throw ('Unknown parameterset {0}' -f $PsCmdLet.ParameterSetName)
            }
        }

        foreach ( $thisInputObject in $newInputObject ) {

            switch ( $PsCmdLet.ParameterSetName) {
                'ByObject' {
                    $thisTppObject = $thisInputObject
                }

                Default {
                    $thisTppObject = [TppObject]::new($thisInputObject, $VenafiSession)
                }
            }

            $uriBase = ('Permissions/Object/{{{0}}}' -f $thisTppObject.Guid )
            $params.UriLeaf = $uriBase

            try {
                # get list of identities permissioned to this object
                $identities = Invoke-VenafiRestMethod @params
            }
            catch {
                Write-Error ('Couldn''t obtain list of permissions for {0}.  {1}' -f $thisTppObject.Path, $_ | Out-String)
                continue
            }

            if ( $PSBoundParameters.ContainsKey('IdentityId') ) {
                $identities = $identities | Where-Object { $_ -in $IdentityId }
            }

            foreach ( $thisId in $identities ) {

                Write-Verbose ('Path: {0}, Id: {1}' -f $thisTppObject.Path, $thisId)

                $params.UriLeaf = $uriBase

                if ( $thisId.StartsWith('local:') ) {
                    # format of local is local:universalId
                    $type, $id = $thisId.Split(':')
                    $params.UriLeaf += "/local/$id"
                }
                else {
                    # external source, eg. AD, LDAP
                    # format is type+name:universalId
                    $type, $name, $id = $thisId -Split { $_ -in '+', ':' }
                    $params.UriLeaf += "/$type/$name/$id"
                }

                if ( -not $Explicit.IsPresent ) {
                    $params.UriLeaf += '/Effective'
                }

                try {

                    $response = Invoke-VenafiRestMethod @params

                    # if no permissions are assigned, we won't get anything back
                    if ( $response ) {

                        $thisReturnObject = [PSCustomObject] @{
                            Path       = $thisTppObject.Path
                            Guid       = $thisTppObject.Guid
                            Name       = $thisTppObject.Name
                            TypeName   = $thisTppObject.TypeName
                            IdentityId = $thisId
                        }

                        # add in identity name and path to return object
                        $thisReturnObject | Add-Member @{
                            IdentityPath = $null
                            IdentityName = $null
                        }

                        $attribParams = @{
                            IdentityId    = $thisReturnObject.IdentityId
                            VenafiSession = $VenafiSession
                        }
                        try {
                            $attribResponse = Get-TppIdentityAttribute @attribParams
                            $thisReturnObject.IdentityPath = $attribResponse.Attributes.FullName
                            $thisReturnObject.IdentityName = $attribResponse.Attributes.Name
                        }
                        catch {
                            Write-Error "Couldn't obtain identity attributes for $($attribParams.IdentityId).  $_"
                        }

                        # old identity info, to be deprecated
                        if ( $PSBoundParameters.ContainsKey('Attribute') ) {

                            Write-Warning 'The Attribute parameter will soon be deprecated.  Identity name and path have been added by default to the return object.  For other attributes, please call Get-TppIdentityAttribute.'

                            $thisReturnObject | Add-Member @{
                                Attributes = $null
                            }

                            $attribParams.Attribute = $Attribute
                            $attribResponse = Get-TppIdentityAttribute @attribParams
                            $thisReturnObject.Attributes = $attribResponse.Attributes
                        }

                        # finally, add in the permissions depending on if explicit or not
                        if ( $Explicit.IsPresent ) {
                            $thisReturnObject | Add-Member @{
                                ExplicitPermissions = [TppPermission] $response.ExplicitPermissions
                                ImplicitPermissions = [TppPermission] $response.ImplicitPermissions
                            }
                        }
                        else {
                            $thisReturnObject | Add-Member @{
                                EffectivePermissions = [TppPermission] $response.EffectivePermissions
                            }
                        }

                        $thisReturnObject
                    }
                }
                catch {
                    Write-Error ('Couldn''t obtain permission set for path {0}, identity {1}.  {2}' -f $thisTppObject.Path, $thisId, $_)
                }
            }
        }
    }
}
