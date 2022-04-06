function Test-VenafiSession {

    [CmdletBinding(DefaultParameterSetName = 'All')]

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('Key', 'AccessToken')]
        [psobject] $VenafiSession,

        [Parameter(Mandatory, ParameterSetName = 'Platform')]
        [Parameter(Mandatory, ParameterSetName = 'AuthType')]
        [string] $Platform,

        [Parameter(Mandatory, ParameterSetName = 'AuthType')]
        [string] $AuthType,

        [Parameter()]
        [switch] $PassThru

    )

    process {

        switch ($VenafiSession.GetType().Name) {
            'VenafiSession' {

                Write-Verbose 'Session is VenafiSession'

                if ( $AuthType ) {
                    $VenafiSession.Validate($Platform, $AuthType)
                }
                elseif ($Platform) {
                    $VenafiSession.Validate($Platform)
                }
                else {
                    $VenafiSession.Validate()
                }

                $platformOut = $VenafiSession.Platform
                break
            }

            'String' {
                $objectGuid = [System.Guid]::empty

                if ( [System.Guid]::TryParse($VenafiSession, [System.Management.Automation.PSReference]$objectGuid) ) {

                    Write-Verbose 'Session is VaaS key'

                    if ( $Platform -and $Platform -ne 'VaaS' ) {
                        throw "This function or parameter set is only accessible for $Platform"
                    }

                    $platformOut = 'VaaS'
                }
                else {

                    # TPP access token
                    Write-Verbose 'Session is TPP token'
                    if ( $Platform -and $Platform -ne 'TPP' ) {
                        throw "This function or parameter set is only accessible for $Platform"
                    }
                    # get server from environment variable
                    if ( -not $env:TppServer ) {
                        throw 'TPP token provided for VenafiSession, but TppServer environment variable was not found'
                    }

                    $platformOut = 'TPP'
                }
            }

            Default {
                throw "Unknown session '$VenafiSession'.  Please run New-VenafiSession or provide a VaaS key or TPP token."
            }
        }

        if ( $PassThru ) {
            $platformOut
        }
    }
}