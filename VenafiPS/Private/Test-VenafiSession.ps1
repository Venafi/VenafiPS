function Test-VenafiSession {
    <#
    .SYNOPSIS
    Validate authentication session/key/token

    .DESCRIPTION
    Validate authentication session from New-VenafiSession, a TLSPC key, or TLSPDC token.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token or TLSPC key can also provided.
    If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

    .PARAMETER Platform
    Platform, either TLSPDC or Vaas, to validate VenafiSession against.

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
    Test a TLSPC key

    .EXAMPLE
    Test-VenafiSession -VenafiSession $VenafiSession -Platform TLSPDC
    Test session ensuring the platform is TLSPDC

    .EXAMPLE
    Test-VenafiSession -VenafiSession $VenafiSession -Platform TLSPDC -AuthType Token
    Test session ensuring the platform is TLSPDC and authentication type is token

    #>

    [CmdletBinding(DefaultParameterSetName = 'All')]

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [Alias('Key', 'AccessToken')]
        [psobject] $VenafiSession,

        [Parameter(Mandatory, ParameterSetName = 'Platform')]
        [Parameter(Mandatory, ParameterSetName = 'AuthType')]
        # [ValidateSet('TLSPC', 'TLSPDC')]
        [string] $Platform,

        [Parameter(Mandatory, ParameterSetName = 'AuthType')]
        [ValidateSet('Key', 'Token')]
        [string] $AuthType
    )

    process {
        if ( (Get-PSCallStack).Count -gt 3 -and -not $VenafiSession ) {

            # nested function, no need to continue testing session since it was already done
            return
        }

        if ( -not $VenafiSession ) {
            if ( $env:VDC_TOKEN ) {
                $VenafiSession = $env:VDC_TOKEN
            }
            elseif ( $env:VC_KEY ) {
                $VenafiSession = $env:VC_KEY
            }
            elseif ( $script:VenafiSession ) {
                $VenafiSession = $script:VenafiSession
            }
            else {
                throw 'Please run New-VenafiSession or provide a TLSPC key or TLSPDC token.'
            }
        }

        switch ($VenafiSession.GetType().Name) {
            'VenafiSession' {

                if ( $PSBoundParameters.ContainsKey('Platform') ) {
                    $newPlatform = $Platform
                    if ( $Platform -match '^(vc|vdc)$' ) {
                        $newPlatform = $matches[1]
                    }
                }
                if ( $AuthType ) {
                    $VenafiSession.Validate($newPlatform, $AuthType)
                }
                elseif ($Platform) {
                    $VenafiSession.Validate($newPlatform)
                }
                else {
                    $VenafiSession.Validate()
                }

                break
            }

            'PSCustomObject' {

                if ( $PSBoundParameters.ContainsKey('Platform') ) {
                    $newPlatform = $Platform
                    if ( $Platform -match '^(vc|vdc)$' ) {
                        $newPlatform = $matches[1]
                    }
                }
                # don't perform .Validate as we do above since this
                # isn't the class, it's a converted pscustomobject
                # for Invoke-VenafiParallel usage
                break
            }

            'String' {

                if ( Test-IsGuid($VenafiSession) ) {

                    Write-Verbose 'Session is VC key'

                    if ( $Platform -and $Platform -notmatch '^VC$' ) {
                        throw "This function or parameter set is only accessible for $Platform"
                    }
                }
                else {

                    # TLSPDC access token
                    Write-Verbose 'Session is VDC token'
                    if ( $Platform -and $Platform -notmatch '^VDC' ) {
                        throw "This function or parameter set is only accessible for $Platform"
                    }
                    # get server from environment variable
                    if ( -not $env:VDC_SERVER ) {
                        throw 'TLSPDC token provided, but VDC_SERVER environment variable was not found'
                    }
                }
            }

            Default {
                throw "Unknown session '$VenafiSession'.  Please run New-VenafiSession or provide a TLSPC key or TLSPDC token."
            }
        }

        # at entry function call, not nested, set the temp variables
        # if ( $script:VenafiSessionNested ) {
        #     # append/update existing
        #     ($script:VenafiSessionNested).$($VenafiSession.Platform) = $VenafiSession
        # }
        # else {
        #     $script:VenafiSessionNested = @{
        #         $($VenafiSession.Platform) = $VenafiSession
        #     }
        # }
        $script:VenafiSessionNested = $VenafiSession
        $script:PlatformNested = $Platform
    }
}