function Find-VdcObject {
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

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

    .INPUTS
    Name

    .OUTPUTS
    PSCustomObject with the following properties:
        Name
        ID
        Path

    .EXAMPLE
    Find-VdcIdentity -Name 'greg' -IncludeUsers
    Find only user identities with the name greg

    .EXAMPLE
    'greg', 'brownstein' | Find-VdcIdentity
    Find all identity types with the name greg and brownstein

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Identity-Browse.php
    #>

    [CmdletBinding(DefaultParameterSetName = 'FindByPath')]
    [Alias('fto', 'Find-TppObject')]

    param (
        [Parameter(ParameterSetName = 'FindByPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'FindByClass', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'FindByPattern', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('DN')]
        [String] $Path = '\ved\policy',

        [Parameter(Mandatory, ParameterSetName = 'FindByPattern')]
        [Parameter(ParameterSetName = 'FindByClass')]
        [Parameter(Mandatory, ParameterSetName = 'FindByAttribute')]
        [ValidateNotNull()]
        [AllowEmptyString()]
        [String] $Pattern,

        [Parameter(Mandatory, ParameterSetName = 'FindByClass')]
        [ValidateNotNullOrEmpty()]
        [Alias('TypeName')]
        [String[]] $Class,

        [Parameter(Mandatory, ParameterSetName = 'FindByAttribute')]
        [ValidateNotNullOrEmpty()]
        [Alias('AttributeName')]
        [String[]] $Attribute,

        [Parameter(ParameterSetName = 'FindByPath')]
        [Parameter(ParameterSetName = 'FindByClass')]
        [Parameter(ParameterSetName = 'FindByPattern')]
        [Alias('r')]
        [switch] $Recursive,

        [Parameter(ParameterSetName = 'FindByAttribute')]
        [switch] $NoLookup,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VDC'
    }

    process {

        $params = @{
            Method = 'Post'
            Body   = @{
                'ObjectDN' = $Path | ConvertTo-VdcFullPath
            }
        }

        Switch ($PsCmdlet.ParameterSetName) {

            'FindByAttribute' {

                $customField = $VenafiSessionNested.CustomField | Where-Object { $_.Label -eq $Attribute[0] -or $_.Guid -eq $Attribute[0] }

                # if attribute isn't a custom field or user doesn't want to perform a cf lookup for a conflicting attrib/cf name, perform standard find object
                if ( $NoLookup -or (-not $customField) ) {

                    $params.UriLeaf = 'config/find'
                    $params.Body = @{
                        AttributeNames = $Attribute
                    }
                }
                else {
                    # cf found
                    $params.UriLeaf = 'Metadata/Find'
                    $params.Body = @{
                        ItemGuid = $customField.Guid
                        Value    = $Pattern
                    }
                }
            }

            { $_ -in 'FindByPath', 'FindByPattern', 'FindByClass' } {
                # if a path wasn't provided, default to recursive enumeration of \ved\policy
                if ( -not $PSBoundParameters.ContainsKey('Path') ) {
                    $params.Body.Recursive = 'true'
                }
            }

            { $_ -in 'FindByPath', 'FindByPattern' } {
                $params.UriLeaf = 'config/enumerate'
            }

            'FindByClass' {
                $params.UriLeaf = 'config/FindObjectsOfClass'
            }

        }

        # pattern is not used by custom field lookup
        if ( $PSBoundParameters.ContainsKey('Pattern') -and ($params.UriLeaf -ne 'Metadata/Find') ) {
            $params.Body.Pattern = $Pattern
        }

        if ( $PSBoundParameters.ContainsKey('Recursive') ) {
            $params.Body.Recursive = 'true'
        }

        if ( $PSBoundParameters.ContainsKey('Class') ) {
            # the rest api doesn't have the ability to search for multiple classes and path at the same time
            # loop through classes to get around this
            $params.Body.Class = ''
            $objects = $Class.ForEach{
                $thisClass = $_
                $params.Body.Class = $thisClass

                $response = Invoke-VenafiRestMethod @params

                if ( $response.Result -eq 1 ) {
                    $response.Objects
                }
                else {
                    Write-Error ('Retrieval of class {0} failed with error {1}' -f $thisClass, $response.Error)
                    Continue
                }
            }
        }
        else {
            $response = Invoke-VenafiRestMethod @params

            # success for cf lookup is 0, all others are config calls and success is 1
            if ( $response.Result -in 0, 1 ) {
                $objects = $response.Objects
            }
            else {
                Write-Error $response.Error
            }
        }

        foreach ($object in $objects) {
            ConvertTo-VdcObject -Path $object.DN -Guid $object.Guid -TypeName $object.TypeName
        }
    }
}