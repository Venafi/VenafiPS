<#
.SYNOPSIS
Search for identity details

.DESCRIPTION
Returns information about individual identity, group identity, or distribution groups from a local or non-local provider such as Active Directory.
You can specify individual identity types to search for or all

.PARAMETER Name
The individual identity, group identity, or distribution group name to search for

.PARAMETER First
First how many items are returned, the default is 500, but is limited by the provider.

.PARAMETER IncludeUsers
Include user identity type in search

.PARAMETER IncludeSecurityGroups
Include security group identity type in search

.PARAMETER IncludeDistributionGroups
Include distribution group identity type in search

.PARAMETER Me
Returns the identity of the authenticated user and all associated identities.  Will be deprecated in a future release, use Get-TppIdentity -Me instead.

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
Name

.OUTPUTS
PSCustomObject with the following properties:
    Name
    ID
    Path

.EXAMPLE
Find-TppIdentity -Name 'greg' -IncludeUsers
Find only user identities with the name greg

.EXAMPLE
'greg', 'brownstein' | Find-TppIdentity
Find all identity types with the name greg and brownstein

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppIdentity/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppIdentity.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Browse.php
#>
function Find-TppIdentity {

    [CmdletBinding(DefaultParameterSetName = 'Find')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Find', ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [String[]] $Name,

        [Parameter(ParameterSetName = 'Find')]
        [Alias('Limit')]
        [int] $First = 500,

        [Parameter(ParameterSetName = 'Find')]
        [Switch] $IncludeUsers,

        [Parameter(ParameterSetName = 'Find')]
        [Switch] $IncludeSecurityGroups,

        [Parameter(ParameterSetName = 'Find')]
        [Switch] $IncludeDistributionGroups,

        [Parameter(Mandatory, ParameterSetName = 'Me')]
        [Switch] $Me,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'

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
                    VenafiSession = $VenafiSession
                    Method     = 'Post'
                    UriLeaf    = 'Identity/Browse'
                    Body       = @{
                        Filter       = 'placeholder'
                        Limit        = $First
                        IdentityType = $identityType
                    }
                }
            }

            'Me' {
                Write-Warning 'The -Me parameter will be deprecated in a future release.  Please update your code to use Get-TppIdentity -Me.'
                $params = @{
                    VenafiSession = $VenafiSession
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
                    Invoke-VenafiRestMethod @params
                }
                $ids = $response.Identities
            }

            'Me' {
                $response = Invoke-VenafiRestMethod @params

                $ids = $response.Identities | Select-Object -First 1
            }
        }

        if ( $ids ) {
            $ids | ConvertTo-TppIdentity
        }
    }
}
