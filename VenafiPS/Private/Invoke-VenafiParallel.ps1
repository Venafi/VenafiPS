function Invoke-VenafiParallel {

    <#
    .SYNOPSIS
    Helper function to execute a scriptblock in parallel

    .DESCRIPTION
    Execute a scriptblock in parallel.
    For PS v5, the ThreadJob module is required.

    .PARAMETER InputObject
    List of items to iterate over

    .PARAMETER ScriptBlock
    Scriptblock to execute against the list of items

    .PARAMETER ThrottleLimit
    Limit the number of threads when running in parallel; the default is 100.
    Setting the value to 1 will disable multithreading.
    On PS v5 the ThreadJob module is required.  If not found, multithreading will be disabled.

    .PARAMETER ProgressTitle
    Message displayed on the progress bar

    .PARAMETER VenafiSession
    Authentication for the function.

    .EXAMPLE
    Invoke-VenafiParallel -InputObject $myObjects -ScriptBlock { Do-Something $PSItem }

    Execute in parallel.  Reference each item in the scriptblock as $PSItem or $_.

    .EXAMPLE
    Invoke-VenafiParallel -InputObject $myObjects -ScriptBlock { Do-Something $PSItem } -ThrottleLimit 5

    Only run 5 threads at a time instead of the default of 100.

    .EXAMPLE
    $ProgressPreference = 'SilentlyContinue'
    Invoke-VenafiParallel -InputObject $myObjects -ScriptBlock { Do-Something $PSItem }

    Execute in parallel with no progress bar.

    .NOTES
    In your ScriptBlock:
    - Use either $PSItem or $_ to reference the current input object
    - Remember hashtables are reference types so be sure to clone if 'using' from parent

    #>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [AllowNull()]
        [psobject] $InputObject,

        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock,

        [Parameter()]
        [int32] $ThrottleLimit = 100,

        [Parameter()]
        [string] $ProgressTitle = 'Performing action',

        [Parameter()]
        [psobject] $VenafiSession

    )

    begin {

        if (-not $InputObject) { return }

        # if ThreadJob module is not available, throttle to 1 so multithreading isn't used
        if ( $PSVersionTable.PSVersion.Major -eq 5 ) {
            if ( -not $script:ThreadJobAvailable ) {
                $ThrottleLimit = 1
            }
        }

        if ( $script:VenafiSession ) {
            $VenafiSession = $script:VenafiSession
        }
        elseif ($script:VenafiSessionNested) {
            $VenafiSession = $script:VenafiSessionNested
        }
        elseif ( $env:VDC_TOKEN ) {
            $VenafiSession = $env:VDC_TOKEN
        }
        elseif ( $env:VC_KEY ) {
            $VenafiSession = $env:VC_KEY
        }
    }

    process {
    }

    end {

        if (-not $InputObject) { return }

        # throttle to 1 = no parallel
        if ( $ThrottleLimit -le 1 ) {
            # ensure no $using: vars given not threaded and not needed
            $InputObject | ForEach-Object -Process ([ScriptBlock]::Create(($ScriptBlock.ToString() -ireplace [regex]::Escape('$using:'), '$')))
            return
        }

        # parallel processing from here down
        $starterSb = {

            # need to import module until https://github.com/PowerShell/PowerShell/issues/12240 is complete
            # import via path instead of just module name to support non-standard paths, eg. development work

            # PSCommandPath is the path to the module psm1
            Import-Module $using:PSCommandPath -Force

            # bring in the venafi session from the calling ps session
            $script:VenafiSession = $using:VenafiSession

            # bring in verbose preference from calling ps session
            $VerbosePreference = $using:VerbosePreference
        }


        if ( $PSVersionTable.PSVersion.Major -eq 5 ) {
            # Start-ThreadJob does not have any child jobs for some reason so there will be no progress and just exist
            $sb = ([ScriptBlock]::Create($starterSb.ToString() + '$using:InputObject | % { ' + $ScriptBlock.ToString() + '}'))
            return Start-ThreadJob -ScriptBlock $sb -ThrottleLimit $ThrottleLimit | Receive-Job -Wait -AutoRemoveJob
        }
        else {
            $sb = ([ScriptBlock]::Create($starterSb.ToString() + $ScriptBlock.ToString()))

            # no progress, arguably faster
            if ( $ProgressPreference -ne 'Continue' ) {
                return $InputObject | Foreach-Object -AsJob -ThrottleLimit $ThrottleLimit -Parallel $sb | Receive-Job -Wait -AutoRemoveJob
            }
        }

        Write-Progress -Activity $ProgressTitle -Status "Initializing..."

        $job = $InputObject | Foreach-Object -AsJob -ThrottleLimit $ThrottleLimit -Parallel $sb

        if ( -not $job.ChildJobs ) {
            return
        }

        do {

            # let threads run
            Start-Sleep -Seconds 0.1

            $completedJobsCount = $job.ChildJobs.Where({ $_.State -notin 'NotStarted', 'Running' }).Count

            # get latest job info
            $job | Receive-Job

            if ( -not $NoProgress ) {
                [int] $percent = ($completedJobsCount / $job.ChildJobs.Count) * 100
                Write-Progress -Activity $ProgressTitle -Status "$percent% complete" -PercentComplete $percent
            }

        } while ($completedJobsCount -lt $job.ChildJobs.Count)

        Write-Progress -Completed -Activity 'done'
    }
}
