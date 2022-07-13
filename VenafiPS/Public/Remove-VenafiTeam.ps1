<#
.SYNOPSIS
Remove a team

.DESCRIPTION
Remove a team from either VaaS or TPP

.PARAMETER ID
Team ID.  For VaaS, this is the team guid.  For TPP, this is the local ID.

.PARAMETER VenafiSession
Authentication for the function.
The value defaults to the script session object $VenafiSession created by New-VenafiSession.
A TPP token or VaaS key can also provided.
If providing a TPP token, an environment variable named TPP_SERVER must also be set.

.INPUTS
ID

.EXAMPLE
Remove-VenafiTeam -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'
Remove a VaaS team

.EXAMPLE
Remove-VenafiTeam -ID 'local:{803f332e-7576-4696-a5a2-8ac6be6b14e6}'
Remove a TPP team

.EXAMPLE
Remove-VenafiTeam -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Confirm:$false
Remove a team bypassing the confirmation prompt

#>
function Remove-VenafiTeam {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]

    param (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Guid')]
        [string] $ID,

        [Parameter()]
        [psobject] $VenafiSession = $script:VenafiSession
    )

    begin {
        $platform = Test-VenafiSession -VenafiSession $VenafiSession -PassThru

        $params = @{
            VenafiSession = $VenafiSession
            Method        = 'Delete'
        }
    }

    process {

        if ( $platform -eq 'VaaS' ) {

            $params.UriLeaf = "teams/$ID"
        }
        else {
            # check if just a guid or prefixed universal id
            if ( Test-TppIdentityFormat -ID $ID -Format 'Local' ) {
                $guid = [guid]($ID.Replace('local:', ''))
            }
            else {
                try {
                    $guid = [guid] $ID
                }
                catch {
                    Write-Error "$ID is not a valid team id"
                    Continue
                }
            }
            $params.UriLeaf = ('Teams/local/{{{0}}}' -f $guid.ToString())
        }

        if ( $PSCmdlet.ShouldProcess($ID, "Delete team") ) {
            Invoke-VenafiRestMethod @params | Out-Null
        }
    }
}
