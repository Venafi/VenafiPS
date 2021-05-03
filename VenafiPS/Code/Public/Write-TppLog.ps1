<#
.SYNOPSIS
Write entries to the TPP log

.DESCRIPTION
Write entries to the log for custom event groups.
It is not permitted to write to the default log.

.PARAMETER CustomEventGroup
Custom Event Group ID, 4 characters.

.PARAMETER EventId
Event ID from within the EventGroup provided.  Only provide the 4 character event id, do not precede with group ID.

.PARAMETER Component
Path to the item this event is associated with

.PARAMETER Severity
Severity of the event

.PARAMETER SourceIp
The IP that originated the event

.PARAMETER ComponentID
Component ID that originated the event

.PARAMETER ComponentSubsystem
Component subsystem that originated the event

.PARAMETER Text1
String data to write to log.  See link for event ID messages for more info.

.PARAMETER Text2
String data to write to log.  See link for event ID messages for more info.

.PARAMETER Value1
Integer data to write to log.  See link for event ID messages for more info.

.PARAMETER Value2
Integer data to write to log.  See link for event ID messages for more info.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
none

.OUTPUTS
none

.EXAMPLE
Write-TppLog -CustomEventGroup '0200' -EventId '0001' -Component '\ved\policy\mycert.com'
Log an event to a custom group

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/Write-TppLog/

.LINK
https://github.com/gdbarron/VenafiPS/blob/main/VenafiPS/Code/Public/Write-TppLog.ps1

.LINK
https://docs.venafi.com/Docs/20.4SDK/TopNav/Content/SDK/WebSDK/r-SDK-POST-Log.php?tocpath=Web%20SDK%7CLog%20programming%20interface%7C_____3

#>
function Write-TppLog {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'DefaultGroup')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'DefaultGroup')]
        [string] $EventGroup,

        [Parameter(Mandatory, ParameterSetName = 'CustomGroup')]
        [ValidateLength(4, 4)]
        [string] $CustomEventGroup,

        [Parameter(Mandatory)]
        [ValidateLength(4, 4)]
        [string] $EventId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Component,

        [Parameter()]
        [TppEventSeverity] $Severity,

        [Parameter()]
        [ipaddress] $SourceIp,

        [Parameter()]
        [int] $ComponentID,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $ComponentSubsystem,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Text1,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Text2,

        [Parameter()]
        [int] $Value1,

        [Parameter()]
        [int] $Value2,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    if ( $PSCmdlet.ParameterSetName -eq 'DefaultGroup' ) {
        throw 'Writing to built-in event groups is no longer supported by Venafi.  You can write to custom event groups.'
    }

    $VenafiSession.Validate()

    # the event id is the group id coupled with the event id
    $fullEventId = "$CustomEventGroup$EventId"

    # convert the hex based eventid to decimal equivalent
    $decEventId = [System.Convert]::ToInt64($fullEventId, 16)

    $params = @{
        VenafiSession = $VenafiSession
        Method     = 'Post'
        UriLeaf    = 'Log/'
        Body       = @{
            GroupID   = $CustomEventGroup
            ID        = $decEventId
            Component = $Component
        }
    }

    if ( $PSBoundParameters.ContainsKey('Severity') ) {
        $params.Body.Add('Severity', [TppEventSeverity]::$Severity)
    }

    if ( $PSBoundParameters.ContainsKey('SourceIp') ) {
        $params.Body.Add('SourceIp', $SourceIp.ToString())
    }

    if ( $PSBoundParameters.ContainsKey('ComponentID') ) {
        $params.Body.Add('ComponentID', $ComponentID)
    }

    if ( $PSBoundParameters.ContainsKey('ComponentSubsystem') ) {
        $params.Body.Add('ComponentSubsystem', $ComponentSubsystem)
    }

    if ( $PSBoundParameters.ContainsKey('Text1') ) {
        $params.Body.Add('Text1', $Text1)
    }

    if ( $PSBoundParameters.ContainsKey('Text2') ) {
        $params.Body.Add('Text2', $Text2)
    }

    if ( $PSBoundParameters.ContainsKey('Value1') ) {
        $params.Body.Add('Value1', $Value1)
    }

    if ( $PSBoundParameters.ContainsKey('Value2') ) {
        $params.Body.Add('Value2', $Value2)
    }

    if ( $PSCmdlet.ShouldProcess($Component, 'Write log entry') ) {

        $response = Invoke-TppRestMethod @params

        if ( $response.LogResult -eq 1 ) {
            throw "Writing to the TPP log failed.  Ensure you have View permission and Read permission to the default SQL channel object."
        }
    }
}