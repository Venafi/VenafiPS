<#
.SYNOPSIS
DEPRECATED - Validate session object

.DESCRIPTION
Verifies that an APIKey is still valid. If the session has expired due to a timeout, the session will be reestablished and a new key retrieved.  The new session will replace the old script scope session object.

.PARAMETER TppSession
Session object created from New-TppSession.  Defaults to current session object.

.OUTPUTS
none

.EXAMPLE
Test-TppSession
Validate current session set as script variable

#>
function Test-TppSession {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $TppSession = $Script:TppSession
    )

    begin {

        if ( -not ($TppSession.PSobject.Properties.name -contains "APIKey") ) {
            throw "Valid TppSession was not provided.  Please authenticate with New-TppSession."
        }

        If ($TppSession.ValidUntil -lt (Get-Date).ToUniversalTime()) {
            # we need to re-authenticate
            Write-Verbose "Session timeout, re-authenticating"
            $newSession = New-TppSession -ServerUrl $TppSession.ServerUrl -Credential $TppSession.Credential -PassThrough
        }
    }

    process {

        if ( $newSession ) {
            $newSession
        } else {
            $TppSession
        }
    }

}
