function Test-VenafiSession {
    <#
    .SYNOPSIS
    Validate authentication session/key/token

    .DESCRIPTION
    Validate authentication session from New-VenafiSession, a VaaS key, or TPP token.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TPP token or VaaS key can also provided.
    If providing a TPP token, an environment variable named TPP_SERVER must also be set.

    .PARAMETER Platform
    Platform, either TPP or Vaas, to validate VenafiSession against.

    .PARAMETER AuthType
    Authentication type, either Key or Token, to validate VenafiSession against.

    .PARAMETER PassThru
    Provide the determined platform from VenafiSession

    .OUTPUTS
    String - if PassThru provided

    .EXAMPLE
    Test-VenafiSession -VenafiSession $VenafiSession
    Test a session

    .EXAMPLE
    Test-VenafiSession -VenafiSession $VenafiSession -PassThru
    Test a session and return the platform type found

    .EXAMPLE
    Test-VenafiSession -VenafiSession $key
    Test a VaaS key

    .EXAMPLE
    Test-VenafiSession -VenafiSession $VenafiSession -Platform TPP
    Test session ensuring the platform is TPP

    .EXAMPLE
    Test-VenafiSession -VenafiSession $VenafiSession -Platform TPP -AuthType Token
    Test session ensuring the platform is TPP and authentication type is token

    #>

    [CmdletBinding(DefaultParameterSetName = 'All')]

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [Alias('Key', 'AccessToken')]
        [psobject] $VenafiSession,

        [Parameter(Mandatory, ParameterSetName = 'Platform')]
        [Parameter(Mandatory, ParameterSetName = 'AuthType')]
        [ValidateSet('VaaS', 'TPP')]
        [string] $Platform,

        [Parameter(Mandatory, ParameterSetName = 'AuthType')]
        [ValidateSet('Key', 'Token')]
        [string] $AuthType,

        [Parameter()]
        [switch] $PassThru
    )

    process {

        if ( -not $VenafiSession ) {
            if ( $env:TPP_TOKEN ) {
                $VenafiSession = $env:TPP_TOKEN
            } elseif ( $env:VAAS_KEY ) {
                $VenafiSession = $env:VAAS_KEY
            } else {
                throw 'Please run New-VenafiSession or provide a VaaS key or TPP token.'
            }
        }

        switch ($VenafiSession.GetType().Name) {
            'VenafiSession' {

                Write-Verbose 'Session is VenafiSession'

                if ( $AuthType ) {
                    $VenafiSession.Validate($Platform, $AuthType)
                } elseif ($Platform) {
                    $VenafiSession.Validate($Platform)
                } else {
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
                } else {

                    # TPP access token
                    Write-Verbose 'Session is TPP token'
                    if ( $Platform -and $Platform -ne 'TPP' ) {
                        throw "This function or parameter set is only accessible for $Platform"
                    }
                    # get server from environment variable
                    if ( -not $env:TPP_SERVER ) {
                        throw 'TPP token provided, but TPP_SERVER environment variable was not found'
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