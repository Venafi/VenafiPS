function ConvertTo-PlaintextString {
    <#
    .SYNOPSIS
    Convert a SecureString or PSCredential to a plaintext string/password.
    .EXAMPLE
    ConvertTo-PlaintextString -InputObject $mySecureString
    #>
    [Cmdletbinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [psobject] $InputObject
    )
    process {
        if ( $InputObject -is [string] ) {
            $InputObject
        }
        elseif ($InputObject -is [securestring]) {
            # use this workaround to support both v5 and v7
            (New-Object System.Management.Automation.PSCredential(0, $InputObject)).GetNetworkCredential().password
        }
        elseif ($InputObject -is [pscredential]) {
            $InputObject.GetNetworkCredential().Password
        }
        else {
            throw 'Unsupported type for -InputObject.  Provide either a String, SecureString, or PSCredential.'
        }
    }
}
