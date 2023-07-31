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

        # if ($PSVersionTable.PSVersion.Major -lt 7) { throw 'PowerShell v7 or greater is required for this function' }

        if ( $PSVersionTable.PSVersion.Major -lt 7 ) {
            if ( -not $NoProgress ) {
                Write-Progress -Activity $ProgressTitle -Status "Initializing..."
            }

            # PS classes are not thread safe, https://github.com/PowerShell/PowerShell/issues/12801
            # so can't pass VenafiSession as is unless it's an token/key string
            $vs = if ( $VenafiSession.GetType().Name -eq 'VenafiSession' ) {
                $vsTemp = [pscustomobject]@{}
                $VenafiSession.psobject.properties | ForEach-Object { $vsTemp | Add-Member @{$_.name = $_.value } }
                $vsTemp
            }
            else {
                # token or api key provided directly
                $VenafiSession
            }
        }
    }

    process {
    }

    end {

        if ( $PSVersionTable.PSVersion.Major -lt 7 ) {
            Write-Warning 'Upgrade to PowerShell Core v7+ to make this function execute in parallel and be much faster!'

            # ensure no $using: vars
            ForEach-Object -InputObject $InputObject -Process [ScriptBlock]::Create(($ScriptBlock.ToString() -ireplace [regex]::Escape('$using:'), '$'))
        }
        else {

            $thisDir = $PSScriptRoot
            $starterSb = {

                # need to import module until https://github.com/PowerShell/PowerShell/issues/12240 is complete
                # import via path instead of just module name to support development work

                Import-Module (Join-Path -Path (Split-Path $using:thisDir -Parent) -ChildPath 'VenafiPS.psd1') -Force

                # grab the api key as passing VenafiSession as is causes powershell to hang
                # PS classes are not thread safe, https://github.com/PowerShell/PowerShell/issues/12801
                $VenafiSession = $using:vs
                # if ( $using:server ) { $env:TPP_SERVER = $using:server }
                # $VenafiSession = if ( ($using:VenafiSession).GetType().Name -eq 'VenafiSession' ) {
                #     ($using:VenafiSession).Key.GetNetworkCredential().Password
                # }
                # else {
                #     $using:VenafiSession
                # }
            }

            $newSb = ([ScriptBlock]::Create($starterSb.ToString() + $ScriptBlock.ToString()))

            $job = $InputObject | Foreach-Object -AsJob -ThrottleLimit $ThrottleLimit -Parallel $newSb

            if ( -not $job.ChildJobs ) {
                return
            }

            do {

                # Sleep a bit to allow the threads to run
                Start-Sleep -Seconds 1

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
}