<#
.SYNOPSIS
Get identity details

.DESCRIPTION
Returns information about individual identity, group identity, or distribution groups from a local or non-local provider such as Active Directory.

.PARAMETER ID
The individual identity, group identity, or distribution group prefixed universal id

.PARAMETER IncludeAssociated
Include all associated identity groups and folders

.PARAMETER GetMembers
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
    Members (if -GetMembers provided)
.EXAMPLE
Get-TppIdentity -ID 'AD+myprov:asdfgadsf9g87df98g7d9f8g7'

Get identity details from an id

.EXAMPLE
Get-TppIdentity -ID 'AD+myprov:asdfgadsf9g87df98g7d9f8g7' -GetMembers

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
https://https://docs.venafi.com/Docs/21.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-GetMembers.php

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
        [Switch] $GetMembers,

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
                        $associated = Invoke-VenafiRestMethod @params -UriLeaf 'Identity/GetAssociatedEntries'
                        $response | Add-Member @{ 'Associated' = $associated.Identities }
                    }

                    if (($response.IsGroup) -and ($GetMembers))  {
                        $params.UriLeaf = 'Identity/GetMembers'
                        $params.Body.Add("ResolveNested","1");
                        $members = Invoke-VenafiRestMethod @params
                        $response | Add-Member @{ 'Members' = $members.Identities}
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
            $idOut | Select-Object `
            @{
                n = 'ID'
                e = { $_.PrefixedUniversal }
            },
            @{
                n = 'Path'
                e = { $_.FullName }
            }, * -ExcludeProperty PrefixedUniversal, FullName, Prefix, PrefixedName, Type, Universal
        }
    }
}
