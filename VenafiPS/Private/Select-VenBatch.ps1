function Select-VenBatch {
    <#
    .SYNOPSIS
    Batches pipeline input.

    .DESCRIPTION
    Batches up pipeline input into consistently sized List[T]s of objects. Used to ensure that processing occurs in specific sized batches.
    Useful for not recieving API timouts due to sending more objects than can be processed in the connection timeout period.

    .PARAMETER InputObject
    The pipeline input objects binds to this parameter one by one.
    Do not use it directly.

    .PARAMETER BatchSize
    The size of the batches to separate the pipeline input into.

    .PARAMETER BatchType
    Type of object to group things into. Defaults to a Powershell custom object

    Valid Values: "pscustomobject", "string", "int", "guid"

    .OUTPUTS
    System.Collections.Generic.List[T]

    .EXAMPLE
    1..6000 | Select-VenBatch -batchsize 1000 -BatchType string

    #>

    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject,

        [Parameter(Mandatory)]
        [int] $BatchSize,

        [Parameter(Mandatory, Position = 0)]
        [ValidateSet("pscustomobject", "string", "int", "guid")]
        [string] $BatchType = "pscustomobject"

    )

    Begin {
        switch ($BatchType) {
            'string' {
                $Batch = [System.Collections.Generic.Queue[string]]::new($BatchSize)
            }
            'int' {
                $Batch = [System.Collections.Generic.Queue[int]]::new($BatchSize)
            }
            'guid' {
                $Batch = [System.Collections.Generic.Queue[guid]]::new($BatchSize)
            }
            'pscustomobject' {
                $Batch = [System.Collections.Generic.Queue[pscustomobject]]::new($BatchSize)
            }
        }

        $count = 0
    }

    Process {

        $count++

        $Batch.Enqueue($_)

        if ($Batch.Count -eq $BatchSize) {
            'Processing batch {0}, items {1}-{2}' -f ($count / $BatchSize), ($count - $BatchSize + 1), $count | Write-Verbose
            , ($Batch)
            $Batch.Clear() # start next batch
        }
    }

    end {
        # process any remaining items, eg. we didn't have a full batch
        if ( $Batch.Count ) {
            $batchNum = [math]::Ceiling($count / $BatchSize)
            'Processing batch {0}, items {1}-{2}' -f $batchNum, ((($batchNum - 1) * $BatchSize) + 1), $count | Write-Verbose
            , ($Batch)
            $Batch.Clear()
            Remove-Variable Batch
        }
    }
}