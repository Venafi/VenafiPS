<#
.SYNOPSIS
Add a new policy folder

.DESCRIPTION
Add a new policy folder

.PARAMETER Path
DN path to the new policy

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
function New-TppPolicy {

    [CmdletBinding(SupportsShouldProcess)]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [Alias('PolicyDN')]
        [string] $Path,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String] $Description,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {

        $params = @{
            Path       = ''
            Class      = 'Policy'
            PassThru   = $true
            VenafiSession = $VenafiSession
        }

        if ( $PSBoundParameters.ContainsKey('Description') ) {
            $params.Add('Attribute', @{'Description' = $Description })
        }

    }

    process {
        $params.Path = $Path

        if ( $PSCmdlet.ShouldProcess($Path, 'Create Policy') ) {

            Write-Verbose ($params | Out-String)
            $response = New-TppObject @params

            if ( $PassThru ) {
                $response
            }
        }
    }
}
