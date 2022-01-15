function Get-VenafiAuthType {

    [CmdletBinding()]
    [OutputType([System.String])]

    param (

        [Parameter(Mandatory, ValueFromPipeline)]
        [VenafiSession] $VenafiSession
    )

    begin {}

    process {
        if ( $VenafiSession.ServerUrl -eq $script:CloudUrl ) {
            'vaas'
        } else {
            if ($VenafiSession.token) {
                'token'
            } else {
                'key'
            }
        }
    }

    end {}
}
