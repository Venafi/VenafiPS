<#
.SYNOPSIS
Get VaaS User info

.DESCRIPTION
Get info for VaaS users

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.OUTPUTS
PSCustomObject

.EXAMPLE
Get-VaasUser
Get info for all users

#>
function Get-VaasUser {

    [CmdletBinding()]
    param (

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('VaaS')

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Get'
            UriLeaf       = 'useraccounts'
        }
    }

    process {

        $response = Invoke-VenafiRestMethod @params

        if ( $response.PSObject.Properties.Name -contains 'user' ) {
            $response | Select-Object -ExpandProperty user
        }
        else {
            $response
        }

    }
}
