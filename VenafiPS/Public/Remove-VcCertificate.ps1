function Remove-VcCertificate {
    <#
    .SYNOPSIS
    Remove a certificate

    .DESCRIPTION
    Remove a certificate

    .PARAMETER ID
    Certificate ID of a certificate that has been retired

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPC key can also provided.

    .INPUTS
    ID

    .EXAMPLE
    Remove-VcCertificate -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2'

    Remove a certificate

    .EXAMPLE
    Find-VcCertificate | Remove-VcCertificate

    Remove multiple certificates based on a search

    .EXAMPLE
    Remove-VcCertificate -ID 'ca7ff555-88d2-4bfc-9efa-2630ac44c1f2' -Confirm:$false

    Remove a certificate bypassing the confirmation prompt

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]

    param (

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('certificateId')]
        [string] $ID,

        [Parameter()]
        [int] $ThrottleLimit = 100,

        [Parameter()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession -VenafiSession $VenafiSession -Platform 'VaaS'
        $allObjects = [System.Collections.Generic.List[object]]::new()
    }

    process {
        if ( $PSCmdlet.ShouldProcess($ID, "Delete certificate") ) {
            $allObjects.Add($ID)
        }
    }

    end {

        # handle certs differently since you send them all in 1 call
        # and parallel functionality not needed
        $params = @{
            Method  = 'Post'
            UriRoot = 'outagedetection/v1'
            UriLeaf = 'certificates/deletion'
            Body    = @{
                certificateIds = $allObjects
            }
        }
        $null = Invoke-VenafiRestMethod @params
    }
}
