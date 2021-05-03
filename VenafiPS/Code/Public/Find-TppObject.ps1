<#
.SYNOPSIS
Find objects by path, class, or pattern

.DESCRIPTION
Find objects by path, class, or pattern.

.PARAMETER Path
The path to start our search.

.PARAMETER Class
1 or more classes to search for

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
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
Path

.OUTPUTS
TppObject

.EXAMPLE
Find-TppObject -Path '\VED\Policy'
Get all objects in the root of a specific folder

.EXAMPLE
Find-TppObject -Path '\VED\Policy\My Folder' -Recursive
Get all objects in a folder and subfolders

.EXAMPLE
Find-TppObject -Path '\VED\Policy' -Pattern 'test'
Get items in a specific folder filtering the path

.EXAMPLE
Find-TppObject -Class 'iis6'
Get all objects of the type iis6

.EXAMPLE
Find-TppObject -Class 'iis6' -Pattern 'test*'
Get all objects of the type iis6 filtering the path

.EXAMPLE
Find-TppObject -Class 'iis6', 'capi'
Get all objects of the type iis6 or capi

.EXAMPLE
Find-TppObject -Pattern 'test*'
Find objects with the specific name.  All objects will be searched.

.EXAMPLE
Find-TppObject -Pattern 'test*' -Attribute 'Consumers'
Find all objects where the specific attribute matches the pattern

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Find-TppObject/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Find-TppObject.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-find.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____17

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-findobjectsofclass.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____19

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-enumerate.php?tocpath=Web%20SDK%7CConfig%20programming%20interface%7C_____13

#>
function Find-TppObject {

    [CmdletBinding()]
    [Alias('fto')]

    param (
        [Parameter(Mandatory, ParameterSetName = 'FindByPath', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'FindByClassAndPath', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath -AllowRoot ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('DN')]
        [String] $Path,

        [Parameter(ParameterSetName = 'FindByPath')]
        [Parameter(Mandatory, ParameterSetName = 'FindByPattern')]
        [Parameter(ParameterSetName = 'FindByClass')]
        [Parameter(ParameterSetName = 'FindByClassAndPath')]
        [Parameter(Mandatory, ParameterSetName = 'FindByAttribute')]
        [ValidateNotNullOrEmpty()]
        [String] $Pattern,

        [Parameter(ParameterSetName = 'FindByPath')]
        [Parameter(ParameterSetName = 'FindByClassAndPath')]
        [switch] $Recursive,

        [Parameter(Mandatory, ParameterSetName = 'FindByClass')]
        [Parameter(Mandatory, ParameterSetName = 'FindByClassAndPath')]
        [ValidateNotNullOrEmpty()]
        [String[]] $Class,

        [Parameter(Mandatory, ParameterSetName = 'FindByAttribute')]
        [ValidateNotNullOrEmpty()]
        [Alias('AttributeName')]
        [String[]] $Attribute,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {

        $VenafiSession.Validate() | Out-Null

        Write-Verbose $PsCmdlet.ParameterSetName

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'placeholder'
            Body       = @{ }
        }

        Switch -Wildcard ($PsCmdlet.ParameterSetName) {
            'FindByAttribute' {
                $params.UriLeaf = 'config/find'
            }

            'FindByPath' {
                $params.UriLeaf = 'config/enumerate'
            }

            'FindByPattern' {
                $params.UriLeaf = 'config/enumerate'
                $params.Body.Add( 'ObjectDN', '\VED' )
                $params.Body.Add( 'Recursive', 'true' )
            }

            'FindByClass*' {
                $params.UriLeaf = 'config/FindObjectsOfClass'
            }
        }

        # add filters
        if ( $PSBoundParameters.ContainsKey('Pattern') ) {
            $params.Body.Add( 'Pattern', $Pattern )
        }

        if ( $PSBoundParameters.ContainsKey('Attribute') ) {
            $params.Body.Add( 'AttributeNames', $Attribute )
        }

        if ( $PSBoundParameters.ContainsKey('Recursive') ) {
            $params.Body.Add( 'Recursive', 'true' )
        }
    }

    process {
        if ( $PSBoundParameters.ContainsKey('Path') ) {
            $params.Body['ObjectDN'] = $Path
        }

        if ( $PSBoundParameters.ContainsKey('Class') ) {
            # the rest api doesn't have the ability to search for multiple classes and path at the same time
            # loop through classes to get around this
            $params.Body['Class'] = ''
            $objects = $Class.ForEach{
                $thisClass = $_
                $params.Body.Class = $thisClass

                $response = Invoke-TppRestMethod @params

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
            $response = Invoke-TppRestMethod @params

            if ( $response.Result -eq [TppConfigResult]::Success ) {
                $objects = $response.Objects
            }
            else {
                Write-Error $response.Error
            }
        }

        foreach ($object in $objects) {
            [TppObject] @{
                Name     = $object.Name
                TypeName = $object.TypeName
                Path     = $object.DN
                Guid     = $object.Guid
            }
        }
    }
}