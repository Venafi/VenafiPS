<#
.SYNOPSIS
Get identity details

.DESCRIPTION
Returns information about individual identity, group identity, or distribution groups from a local or non-local provider such as Active Directory.

.PARAMETER ID
The individual identity, group identity, or distribution group prefixed universal id

.PARAMETER IncludeAssociated
Include all associated identity groups and folders

.PARAMETER IncludeMembers
Include all individual members if the ID is a group

.PARAMETER Me
Returns the identity of the authenticated user

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
ID

.OUTPUTS
PSCustomObject with the following properties:
    Name
    ID
    Path
    Associated (if -IncludeAssociated provided)
    Members (if -IncludeMembers provided)

.EXAMPLE
Get-TppIdentity -ID 'AD+myprov:asdfgadsf9g87df98g7d9f8g7'

Get identity details from an id
.EXAMPLE
Get-TppIdentity -ID 'AD+myprov:asdfgadsf9g87df98g7d9f8g7' -IncludeMembers

Get identity details and if the identity is a group it will also return the members

.EXAMPLE
Get-TppIdentity -ID 'AD+myprov:asdfgadsf9g87df98g7d9f8g7' -IncludeAssociated

Get identity details from an id and include associated groups/folders

.EXAMPLE
Get-TppIdentity -Me

Get identity details for user in the current session

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Get-TppIdentity/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Get-TppIdentity.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Validate.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-GET-Identity-Self.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-GetAssociatedEntries.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-GetMembers.php

#>
function Get-TppIdentity {

    [CmdletBinding(DefaultParameterSetName = 'Id')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '',	Justification = "Parameter is used")]

    param (
        [Parameter(Mandatory, ParameterSetName = 'Id', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String[]] $ID,

        [Parameter(ParameterSetName = 'Id')]
        [Switch] $IncludeAssociated,

        [Parameter(ParameterSetName = 'Id')]
        [Switch] $IncludeMembers,


        [Parameter(Mandatory, ParameterSetName = 'Me')]
        [Switch] $Me,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )



    begin {
        $VenafiSession.Validate('TPP')

        Switch ($PsCmdlet.ParameterSetName)	{
            'Id' {
                $params = @{
                    VenafiSession = $VenafiSession
                    Method        = 'Post'
                    UriLeaf       = 'Identity/Validate'
                    Body          = @{
                        'ID' = @{
                            'PrefixedUniversal' = ''
                        }
                    }
                }
            }

            'Me' {
                $params = @{
                    VenafiSession = $VenafiSession
                    Method        = 'Get'
                    UriLeaf       = 'Identity/Self'
                }
            }
        }
    }

    process {

        Switch ($PsCmdlet.ParameterSetName)	{
            'Id' {
                $idOut = foreach ( $thisId in $ID ) {

                    $params.Body.Id.PrefixedUniversal = $thisId

                    $response = Invoke-VenafiRestMethod @params | Select-Object -ExpandProperty ID

                    if ( $IncludeAssociated ) {
                        $assocParams = $params.Clone()
                        $assocParams.UriLeaf = 'Identity/GetAssociatedEntries'
                        $associated = Invoke-VenafiRestMethod @assocParams
                        $response | Add-Member @{ 'Associated' = $null }
                        $response.Associated = $associated.Identities | script:Format-Output
                    }

                    if ( $IncludeMembers ) {
                        $response | Add-Member @{ 'Members' = $null }
                        if ( $response.IsGroup ) {
                            $assocParams = $params.Clone()
                            $assocParams.UriLeaf = 'Identity/GetMembers'
                            $assocParams.Body.ResolveNested = "1"
                            $members = Invoke-VenafiRestMethod @assocParams
                            $response.Members = $members.Identities | script:Format-Output
                        }
                    }

                    $response
                }
            }

            'Me' {
                $response = Invoke-TppRestMethod @params

                $idOut = $response.Identities | Select-Object -First 1
            }
        }

        if ( $idOut ) {
            $idOut | script:Format-Output
        }
    }

}
filter script:Format-Output {
    $_ | Select-Object `
    @{
        n = 'ID'
        e = { $_.PrefixedUniversal }
    },
    @{
        n = 'Path'
        e = { $_.FullName }
    },
    @{
        n = 'IsGroup'
        e = {
            if ( $_.IsGroup) {
                $_.IsGroup
            }
            else {
                $false
            }
        }
    }, * -ExcludeProperty PrefixedUniversal, FullName, Prefix, PrefixedName, Type, Universal, IsGroup
}