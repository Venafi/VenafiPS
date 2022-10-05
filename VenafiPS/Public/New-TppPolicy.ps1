function New-TppPolicy {
    <#
    .SYNOPSIS
    Add a new policy folder

    .DESCRIPTION
    Add a new policy folder(s).  Add attributes or policy attributes at the same time.

    .PARAMETER Path
    Full path to the new policy folder.
    If the root path is excluded, \ved\policy will be prepended.
    If used with -Name, this will be the root path and subfolders will be created.

    .PARAMETER Name
    One of more policy folders to create under -Path.

    .PARAMETER Attribute
    Hashtable with names and values to be set.
    If setting a custom field, you can use either the name or guid as the key.
    To clear a value overwriting policy, set the value to $null.

    .PARAMETER Class
    Set -Attribute as policy attributes.
    If unsure of the class name, add the value through the TPP UI and go to Support->Policy Attributes to find it.

    .PARAMETER Description
    Policy description

    .PARAMETER PassThru
    Return a TppObject representing the newly created policy.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .INPUTS
    Path

    .OUTPUTS
    TppObject, if PassThru provided

    .EXAMPLE
    $newPolicy = New-TppPolicy -Path '\VED\Policy\Existing Policy Folder\New Policy Folder' -PassThru
    Create policy returning the policy object created

    .EXAMPLE
    New-TppPolicy -Path '\VED\Policy\Existing Policy Folder\New Policy Folder' -Description 'this is awesome'
    Create policy with description

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/New-TppPolicy/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-TppPolicy.ps1

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/New-TppObject/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-TppObject.ps1

    #>

    [CmdletBinding(SupportsShouldProcess)]

    param (
        [Parameter(Mandatory, ParameterSetName = 'Path', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Name', ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'PathWithPolicyAttribute', Mandatory, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'NameWithPolicyAttribute', Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Path,

        [Parameter(Mandatory, ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'NameWithPolicyAttribute', Mandatory)]
        [string[]] $Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String] $Description,

        [Parameter()]
        [hashtable] $Attribute,

        [Parameter(ParameterSetName = 'PathWithPolicyAttribute', Mandatory)]
        [Parameter(ParameterSetName = 'NameWithPolicyAttribute', Mandatory)]
        [hashtable] $PolicyAttribute,

        [Parameter(ParameterSetName = 'PathWithPolicyAttribute', Mandatory)]
        [Parameter(ParameterSetName = 'NameWithPolicyAttribute', Mandatory)]
        [string] $Class,

        [Parameter()]
        [switch] $Force,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        $params = @{
            Class         = 'Policy'
            PassThru      = $true
            VenafiSession = $VenafiSession
            Force         = $Force
        }

        if ( $PSBoundParameters.ContainsKey('Description') -or $PSBoundParameters.ContainsKey('Attribute') ) {
            $params.Attribute = @{}

            if ( $PSBoundParameters.ContainsKey('Description') ) {
                $params.Attribute += @{'Description' = $Description }
            }

            if ( $PSBoundParameters.ContainsKey('Attribute') ) {
                $params.Attribute += $Attribute
            }
        }
    }

    process {

        $newPath = $Path | ConvertTo-TppFullPath

        if ( $PSCmdlet.ParameterSetName -in 'Path', 'PathWithPolicyAttribute' ) {

            $params.Path = $newPath

            if ( $PSCmdlet.ShouldProcess($newPath, 'Create Policy') ) {

                $response = New-TppObject @params

                if ( $PSBoundParameters.ContainsKey('Class') ) {
                    $response | Set-TppAttribute -Attribute $PolicyAttribute -Class $Class -VenafiSession $VenafiSession
                }

                if ( $PassThru ) {
                    $response
                }
            }
        } else {
            foreach ($thisName in $Name) {
                $PSBoundParameters['Path'] = Join-Path -Path $newPath -ChildPath $thisName
                $null = $PSBoundParameters.Remove('Name')

                New-TppPolicy @PSBoundParameters
            }
        }

    }
}
