function Select-VenBatch {
    <#
    .SYNOPSIS
    Batches pipeline input. 

    .DESCRIPTION
    Divides large arrays of objects into batches of consistent size or batches up pipeline input into consistently sized arrays ob objects.
    Used to ensure that processing occurs in specific sized batches. Useful for not recieving API timouts due to sending more 
    objects than can be processed in the connection timeout period.

    Returns 

    .PARAMETER InputObject 
    The pipeline input objects binds to this parameter one by one.
    Do not use it directly.

    .PARAMETER BatchSize
    The size of the batchs the separate input into. 

    .PARAMETER BatchType
    Type of object to batch things into. Defaults to a Powershell custom object

    Valid Values: "pscustomobject", "string", "int", "guid"

    .OUTPUTS
    System.Collections.Generic.List[T]

    .EXAMPLE
    1..6000 | Select-VenBatch -batchsize 1000

    #>

    [CmdletBinding(PositionalBinding = $false)]
    param (
      [Parameter(ValueFromPipeline)] 
      $InputObject,

      [Parameter(Mandatory)]
      [int] $BatchSize,

      [Parameter(Mandatory, Position = 0)]
      [ValidateSet("pscustomobject","string","int","guid")]
      [string] $BatchType = "pscustomobject"

      )

    Begin {
        switch ($BatchType) {
            'string'         {
                $Batch = [System.Collections.Generic.Queue[string]]::new($BatchSize)
                $OutList =  [System.Collections.Generic.List[string]]::new()
            }
            'int'            {
                $Batch = [System.Collections.Generic.Queue[int]]::new($BatchSize)
                $OutList =  [System.Collections.Generic.List[int]]::new()
            }
            'guid'           {
                $Batch = [System.Collections.Generic.Queue[guid]]::new($BatchSize)
                $OutList =  [System.Collections.Generic.List[guid]]::new()
            }
            'pscustomobject' {
                $Batch = [System.Collections.Generic.Queue[pscustomobject]]::new($BatchSize)
                $OutList =  [System.Collections.Generic.List[pscustomobject]]::new()
            }
        }
    }

    Process {
        $Batch.Enqueue($_)
        if ($Batch.Count -eq $BatchSize) { 
            $OutList.AddRange($Batch)
            ,$OutList
            $Batch.Clear() # start next batch
            $OutList.clear()
        }
    }

    end {
        if ($batch.Count) { #scriptblock geos here. 
            $OutList.AddRange($Batch)
            ,$OutList
            $Batch.Clear() # start next batch
            $OutList.clear()
        }
    }
}