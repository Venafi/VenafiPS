function Invoke-VenafiParallel {

    <#
    .SYNOPSIS
        Helper function to execute a scriptblock in parallel

    .DESCRIPTION
        This is a wrapper around ForEach-Object -Parallel

    .PARAMETER InputObject
    List of items to iterate over

    .PARAMETER ScriptBlock
    Scriptblock to execute against the list of items

    .PARAMETER ThrottleLimit
    Max number of threads at once.  The default is 20.

    .PARAMETER ProgressTitle
    Message displayed on the progress bar

    .PARAMETER NoProgress
    Do not display the progress bar

    .PARAMETER VenafiSession
    Authentication for the function.

    .NOTES
    PowerShell v7+ is supported

    .EXAMPLE
    Invoke-VenafiParallel -InputObject $myObjects -ScriptBlock { Do-Something $PSItem }

    Execute in parallel.  Reference each item in the scriptblock as $PSItem or $_.

    .EXAMPLE
    Invoke-VenafiParallel -InputObject $myObjects -ScriptBlock { Do-Something $PSItem } -ThrottleLimit 5

    Only run 5 threads at a time instead of the default of 20.

    .EXAMPLE
    Invoke-VenafiParallel -InputObject $myObjects -ScriptBlock { Do-Something $PSItem } -NoProgress

    Execute in parallel with no progress bar.

    #>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [psobject] $InputObject,

        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock,

        [Parameter()]
        [int] $ThrottleLimit = 20,

        [Parameter()]
        [string] $ProgressTitle = 'Performing action',

        [Parameter()]
        [switch] $NoProgress,

        [Parameter(Mandatory)]
        [psobject] $VenafiSession

    )

    begin {

        if ($PSVersionTable.PSVersion.Major -lt 7) { throw 'PowerShell v7 or greater is required for this function' }

        if ( -not $NoProgress ) {
            Write-Progress -Activity $ProgressTitle -Status "Initializing..."
        }
    }

    process {
    }

    end {

        $thisDir = $PSScriptRoot
        $starterSb = {
            Import-Module (Join-Path -Path (Split-Path $using:thisDir -Parent) -ChildPath 'VenafiPS.psd1') -Force

            # grab the api key as passing VenafiSession as is causes powershell to hang
            $VenafiSession = if ( ($using:VenafiSession).GetType().Name -eq 'VenafiSession' ) {
                ($using:VenafiSession).Key.GetNetworkCredential().Password
            }
            else {
                $using:VenafiSession
            }
        }

        $newSb = ([ScriptBlock]::Create($starterSb.ToString() + $ScriptBlock.ToString()))

        $job = $InputObject | Foreach-Object -AsJob -ThrottleLimit $ThrottleLimit -Parallel $newSb

        if ( -not $job.ChildJobs ) {
            return
        }

        do {

            # Sleep a bit to allow the threads to run - adjust as desired.
            Start-Sleep -Seconds 1

            # Determine how many jobs have completed so far.
            $completedJobsCount =
            $job.ChildJobs.Where({ $_.State -notin 'NotStarted', 'Running' }).Count

            # Relay any pending output from the child jobs.
            $job | Receive-Job

            if ( -not $NoProgress ) {
                # Update the progress display.
                [int] $percent = ($completedJobsCount / $job.ChildJobs.Count) * 100
                Write-Progress -Activity $ProgressTitle -Status "$percent% complete" -PercentComplete $percent
            }

        } while ($completedJobsCount -lt $job.ChildJobs.Count)
    }
}