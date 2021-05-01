<#
.SYNOPSIS
Search for identity details

.DESCRIPTION
Returns information about individual identity, group identity, or distribution groups from a local or non-local provider such as Active Directory.
You can specify individual identity types to search for or all

.PARAMETER Name
The individual identity, group identity, or distribution group name to search for

.PARAMETER Limit
Limit how many items are returned, the default is 500, but is limited by the provider.

.PARAMETER IncludeUsers
Include user identity type in search

.PARAMETER IncludeSecurityGroups
Include security group identity type in search

.PARAMETER IncludeDistributionGroups
Include distribution group identity type in search

.PARAMETER Me
Returns the identity of the authenticated user and all associated identities.  Will be deprecated in a future release, use Get-TppIdentity -Me instead.

.PARAMETER TppSession
Session object created from New-TppSession method.  The value defaults to the script session object $TppSession.

.INPUTS
Name

.OUTPUTS
PSCustomObject with the following properties:
    Name
    ID
    Path

.EXAMPLE
Find-TppIdentity -Name 'greg' -IncludeUsers

Find user identities with the name greg

.EXAMPLE
'greg', 'brownstein' | Find-TppIdentity

Find all identity types with the name greg and brownstein

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppIdentity/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Find-TppIdentity.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Browse.php?tocpath=Web%20SDK%7CIdentity%20programming%20interface%7C_____5
#>
function Find-TppIdentity {

    [CmdletBinding(DefaultParameterSetName = 'Find')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Find', ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [String[]] $Name,

        [Parameter(ParameterSetName = 'Find')]
        [int] $Limit = 500,

        [Parameter(ParameterSetName = 'Find')]
        [Switch] $IncludeUsers,

        [Parameter(ParameterSetName = 'Find')]
        [Switch] $IncludeSecurityGroups,

        [Parameter(ParameterSetName = 'Find')]
        [Switch] $IncludeDistributionGroups,

        [Parameter(Mandatory, ParameterSetName = 'Me')]
        [Switch] $Me,

        [Parameter()]
        [TppSession] $TppSession = $Script:TppSession
    )

    begin {
        $TppSession.Validate()

        $identityType = 0
        # determine settings to use
        if ( $PSBoundParameters.ContainsKey('IncludeUsers') ) {
            $identityType += [TppIdentityType]::User
        }
        if ( $PSBoundParameters.ContainsKey('IncludeSecurityGroups') ) {
            $identityType += [TppIdentityType]::SecurityGroups
        }
        if ( $PSBoundParameters.ContainsKey('IncludeDistributionGroups') ) {
            $identityType += [TppIdentityType]::DistributionGroups
        }

        # if no types to include were provided, include all
        if ( $identityType -eq 0 ) {
            $identityType = [TppIdentityType]::User + [TppIdentityType]::SecurityGroups + [TppIdentityType]::DistributionGroups
        }

        Switch ($PsCmdlet.ParameterSetName)	{
            'Find' {
                $params = @{
                    TppSession = $TppSession
                    Method     = 'Post'
                    UriLeaf    = 'Identity/Browse'
                    Body       = @{
                        Filter       = 'placeholder'
                        Limit        = $Limit
                        IdentityType = $identityType
                    }
                }
            }

            'Me' {
                Write-Warning 'The -Me parameter will be deprecated in a future release.  Please update your code to use Get-TppIdentity -Me.'
                $params = @{
                    TppSession = $TppSession
                    Method     = 'Get'
                    UriLeaf    = 'Identity/Self'
                }
            }
        }
    }

    process {

        Switch ($PsCmdlet.ParameterSetName)	{
            'Find' {
                $response = $Name.ForEach{
                    $params.Body.Filter = $_
                    Invoke-TppRestMethod @params
                }
                $ids = $response.Identities
            }

            'Me' {
                $response = Invoke-TppRestMethod @params

                $ids = $response.Identities | Select-Object -First 1
            }
        }

        if ( $ids ) {
            $ids | Select-Object `
            @{
                n = 'Name'
                e = { $_.Name }
            },
            @{
                n = 'ID'
                e = { $_.PrefixedUniversal }
            },
            @{
                n = 'Path'
                e = { $_.FullName }
            }
        }
    }
}
