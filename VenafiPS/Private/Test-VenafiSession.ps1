function Test-VenafiSession {
    <#
    .SYNOPSIS
    Validate authentication session/key/token

    .DESCRIPTION
    Validate authentication session from New-VenafiSession, a TLSPC key, or TLSPDC token.

    .PARAMETER InvocationInfo
    InvocationInfo from calling function

    .EXAMPLE
    Test-VenafiSession $PSCmdlet.MyInvocation

    #>

    [CmdletBinding()]

    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Management.Automation.InvocationInfo] $InvocationInfo
    )

    process {

        if ( (Get-PSCallStack).Count -gt 3 -and -not $InvocationInfo.BoundParameters['VenafiSession'] ) {
            # nested function, no need to continue testing session since it was already done
            return
        }

        $Platform = if ( $InvocationInfo.MyCommand -match '-Vc' ) {
            'VC'
        }
        elseif ($InvocationInfo.MyCommand -match '-Vdc') {
            'VDC'
        }
        
        if ( $InvocationInfo.BoundParameters['VenafiSession'] ) {
            $VenafiSession = $InvocationInfo.BoundParameters['VenafiSession']
        }
        else {
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
            'PSCustomObject' {

                if ( -not $VenafiSession.Key -and -not $VenafiSession.Token ) {
                    throw "You must first connect to either TLSPC or a TLSPDC server with New-VenafiSession"
                }

                # make sure the auth type and url we have match
                # this keeps folks from calling a vaas function with a token and vice versa
                if ( $Platform -and $Platform -ne $VenafiSession.Platform ) {
                    throw ('{0} is only accessible for {1}' -f $InvocationInfo.InvocationName, $Platform)
                }

                if ( $Platform -eq 'VDC' ) {
                    if ( $VenafiSession.Token.Expires -and $VenafiSession.Token.Expires -lt (Get-Date).ToUniversalTime() ) {
                        throw 'TLSPDC token has expired.  Execute New-VenafiSession and rerun your command.'
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
                throw "Unknown session '$VenafiSession'.  Please run New-VenafiSession or provide a TLSPC key or TLSPDC access token."
            }
        }

        $script:VenafiSessionNested = $VenafiSession
        # $script:PlatformNested = $Platform
    }
}