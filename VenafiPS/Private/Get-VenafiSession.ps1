function Get-VenafiSession {

    process {
        # find out if a session was passed in as a parameter from the calling function in the stack.
        # this should only come from the first function which was initiated by the user

        # this provides 2 benefits:
        # - nested functions do not need VenafiSession provided
        # - we can pipe between functions which use different sessions, eg. export from server1 -> import to server2.
        #   this is only possible when core function processing occurs in the end block as the call stack during the process
        #   block including the calling and current function and their parameters.  there shouldn't be too many functions
        #   where we need to go between environments anyway, mainly export and import.  perhaps revisit this in the future if needed.

        # if a session isn't explicitly provided, fallback to the script scope session variable created with New-VenafiSession

        $venafiSessionNested = (Get-PSCallStack).InvocationInfo.BoundParameters.VenafiSession | Select-Object -First 1

        if ($venafiSessionNested) {
            $sess = $venafiSessionNested
            Write-Debug 'Using nested session from call stack'
        }
        elseif ( $script:VenafiSession ) {
            $sess = $script:VenafiSession
            Write-Debug 'Using script session'
        }
        elseif ( $env:VDC_TOKEN ) {
            $sess = $env:VDC_TOKEN
            Write-Debug 'Using TLSPDC token environment variable'
        }
        elseif ( $env:VC_KEY ) {
            $sess = $env:VC_KEY
            Write-Debug 'Using TLSPC key environment variable'
        }
        else {
            throw [System.ArgumentException]::new('Please run New-VenafiSession or provide a TLSPC key or TLSPDC token to -VenafiSession.')
        }

        if ( $sess.Token.Expires -and $sess.Token.Expires -lt (Get-Date).ToUniversalTime() ) {
            throw 'TLSPDC token has expired.  Execute New-VenafiSession and rerun your command.'
        }
        
        $sess
    }
}