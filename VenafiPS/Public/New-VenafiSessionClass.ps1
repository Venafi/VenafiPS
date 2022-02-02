<#
.SYNOPSIS
    Create a new VenafiSession class
.DESCRIPTION
    Use this function to workaround PS issues with class loading.
    This is helpful for many uses including parallel processing where new runspaces are created.
.PARAMETER Session
    Existing TPP/VaaS session
.EXAMPLE
    $newSession = $VenafiSession | New-VenafiSessionClass
    Use existing session to create new session in current scope.
#>
function New-VenafiSessionClass {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [psobject] $Session
    )

    if ( $Session ) {
        if ( $Session.GetType().Name -ne 'VenafiSession' ) {
            throw 'Only VenafiSession objects are permitted'
        }
        [VenafiSession]::new($Session)
    }
    else {
        [VenafiSession]::new()
    }
}