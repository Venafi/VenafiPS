<#
.SYNOPSIS
Find objects by path, class, or pattern

.DESCRIPTION
Find objects by path, class, or pattern.

.PARAMETER Path
The path to start our search.  The default is \ved\policy.

.PARAMETER Class
1 or more classes/types to search for

.PARAMETER Pattern
Filter against object paths.
If the Attribute parameter is provided, this will filter against an object's attribute values instead of the path.

Follow the below rules:
- To list DNs that include an asterisk (*) or question mark (?), prepend two backslashes (\\). For example, \\*.MyCompany.net treats the asterisk as a literal character and returns only certificates with DNs that match *.MyCompany.net.
- To list DNs with a wildcard character, append a question mark (?). For example, "test_?.mycompany.net" counts test_1.MyCompany.net and test_2.MyCompany.net but not test12.MyCompany.net.
- To list DNs with similar names, prepend an asterisk. For example, *est.MyCompany.net, counts Test.MyCompany.net and West.MyCompany.net.
You can also use both literals and wildcards in a pattern.

.PARAMETER Attribute
A list of attribute names to limit the search against.  Only valid when searching by pattern.

.PARAMETER Recursive
Searches the subordinates of the object specified in Path.

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
Path

.OUTPUTS
TppObject

.EXAMPLE
Find-TppObject
Get all objects recursively starting from \ved\policy

.EXAMPLE
Find-TppObject -Path '\VED\Policy\certificates'
Get all objects in the root of a specific folder

.EXAMPLE
Find-TppObject -Path '\VED\Policy\My Folder' -Recursive
Get all objects in a folder and subfolders

.EXAMPLE
Find-TppObject -Path '\VED\Policy' -Pattern '*test*'
Get items in a specific folder filtering the path

.EXAMPLE
Find-TppObject -Class 'capi' -Path '\ved\policy\installations' -Recursive
Get objects of a specific type

.EXAMPLE
Find-TppObject -Class 'capi' -Pattern '*test*' -Path '\ved\policy\installations' -Recursive
Get all objects of a specific type where the path is of a specific pattern

.EXAMPLE
Find-TppObject -Class 'capi', 'iis6' -Pattern '*test*' -Path '\ved\policy\installations' -Recursive
Get objects for multiple types

.EXAMPLE
Find-TppObject -Pattern '*f5*'
Find objects with the specific name.  All objects under \ved\policy (the default) will be searched.

.EXAMPLE
Find-TppObject -Pattern 'awesome*' -Attribute 'Description'
Find objects where the specific attribute matches the pattern

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppObject/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-TppObject.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-find.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-findobjectsofclass.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-enumerate.php

#>
function Find-TppObject {

    [CmdletBinding(DefaultParameterSetName = 'FindByPath')]
    [Alias('fto')]
    [OutputType([TppObject])]

    param (
        [Parameter(ParameterSetName = 'FindByPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'FindByClass', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'FindByPattern', ValueFromPipeline, ValueFromPipelineByPropertyName)]
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

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'TPP'
    }

    process {

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Post'
            Body          = @{
                'ObjectDN' = $Path
            }
        }

        Switch ($PsCmdlet.ParameterSetName) {
            'FindByAttribute' {
                $params.UriLeaf = 'config/find'
                # this is the only api for this function which doesn't accept a path, let's remove it
                $params.Body.Remove('ObjectDN')
                $params.Body['AttributeNames'] = $Attribute
            }

            {$_ -in 'FindByPath', 'FindByPattern', 'FindByClass'} {
                # if a path wasn't provided, default to recursive enumeration of \ved\policy
                if ( -not $PSBoundParameters.ContainsKey('Path') ) {
                    $params.Body['Recursive'] = 'true'
                }
            }

            {$_ -in 'FindByPath', 'FindByPattern'} {
                $params.UriLeaf = 'config/enumerate'
            }

            'FindByClass' {
                $params.UriLeaf = 'config/FindObjectsOfClass'
            }

        }

        # add filters
        if ( $PSBoundParameters.ContainsKey('Pattern') ) {
            $params.Body.Add( 'Pattern', $Pattern )
        }

        if ( $PSBoundParameters.ContainsKey('Recursive') ) {
            $params.Body.Add( 'Recursive', 'true' )
        }

        if ( $PSBoundParameters.ContainsKey('Class') ) {
            # the rest api doesn't have the ability to search for multiple classes and path at the same time
            # loop through classes to get around this
            $params.Body['Class'] = ''
            $objects = $Class.ForEach{
                $thisClass = $_
                $params.Body.Class = $thisClass

                $response = Invoke-VenafiRestMethod @params

                if ( $response.Result -eq [TppConfigResult]::Success ) {
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

            if ( $response.Result -eq [TppConfigResult]::Success ) {
                $objects = $response.Objects
            }
            else {
                Write-Error $response.Error
            }
        }

        foreach ($object in $objects) {
            [TppObject] @{
                Path     = $object.DN
                TypeName = $object.TypeName
                Guid     = $object.Guid
            }
        }
    }
}