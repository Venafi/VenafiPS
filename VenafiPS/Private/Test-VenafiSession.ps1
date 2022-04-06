<#
.SYNOPSIS
Validate authentication session/key/token

.DESCRIPTION
Validate authentication session from New-VenafiSession, a VaaS key, or TPP token.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.
A TPP token or VaaS key can also provided.

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
Test-VenafiSession -VenafiSession $key
Test a VaaS key

.EXAMPLE
Test-VenafiSession -VenafiSession $VenafiSession -Platform TPP
Test session ensuring the platform is TPP

.EXAMPLE
Test-VenafiSession -VenafiSession $VenafiSession -Platform TPP -AuthType Token
Test session ensuring the platform is TPP and authentication type is token

#>

function Test-VenafiSession {

    [CmdletBinding(DefaultParameterSetName = 'All')]

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('Key', 'AccessToken')]
        [psobject] $VenafiSession,

        [Parameter(Mandatory, ParameterSetName = 'Platform')]
        [Parameter(Mandatory, ParameterSetName = 'AuthType')]
        [Alias('VaaS', 'TPP')]
        [string] $Platform,

        [Parameter(Mandatory, ParameterSetName = 'AuthType')]
        [Alias('Key', 'Token')]
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