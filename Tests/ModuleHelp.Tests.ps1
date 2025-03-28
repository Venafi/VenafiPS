BeforeDiscovery {
    . $PSScriptRoot/ModuleCommon.ps1

    $shouldProcessParameters = 'WhatIf', 'Confirm'
    
    # Generate command list for generating Context / TestCases
    $Module = Get-Module $ModuleName
    $CommandList = @(
        $Module.ExportedFunctions.Keys
        $Module.ExportedCmdlets.Keys
    )

    $allData = foreach ($Command in $CommandList) {

        #region Discovery

        $Help = @{ Help = Get-Help -Name $Command -Full | Select-Object -Property * }
        $Parameters = Get-Help -Name $Command -Parameter * -ErrorAction Ignore |
            Where-Object { $_.Name -and $_.Name -notin $shouldProcessParameters } |
            ForEach-Object {
                @{
                    Name        = $_.name
                    Description = $_.Description.Text
                }
            }

        # handle paging parameters via SupportsPaging
        if ($Parameters.Name -contains 'First' -and $Parameters.Name -contains 'Skip' -and $Parameters.Name -contains 'IncludeTotalCount') {
            $Parameters = $Parameters | Where-Object { $_.Name -notin @("First", "Skip", "IncludeTotalCount") }
        }
            
        $Ast = @{
            # Ast will be $null if the command is a compiled cmdlet
            Ast        = (Get-Content -Path "function:/$Command" -ErrorAction Ignore).Ast
            Parameters = $Parameters
        }
        $Examples = $Help.Help.Examples.Example | ForEach-Object { @{ Example = $_ } }

        @{
            Command    = $Command
            Help       = $Help
            Parameters = $Parameters
            Ast        = $Ast
            Examples   = $Examples
        }
    }
}

Describe "$ModuleName Sanity Tests - Help Content" -Tags 'Module' -ForEach $allData {

    Context "$Command - Help Content" {

        It "has help content for $Command" -TestCases $Help {
            $Help | Should -Not -BeNullOrEmpty
        }

        It "contains a synopsis for $Command" -TestCases $Help {
            $Help.Synopsis | Should -Not -BeNullOrEmpty
        }

        It "contains a description for $Command" -TestCases $Help {
            $Help.Description | Should -Not -BeNullOrEmpty
        }

        It "has a help entry for all parameters of $Command" -TestCases $Ast -Skip:(-not ($Parameters -and $Ast.Ast)) {
            @($Parameters).Count | Should -Be $Ast.Body.ParamBlock.Parameters.Count -Because 'the number of parameters in the help should match the number in the function script'
        }

        It "has a description for $Command parameter -<Name>" -TestCases $Parameters -Skip:(-not $Parameters) {
            $Description | Should -Not -BeNullOrEmpty -Because "parameter $Name should have a description"
        }

        It "has at least one usage example for $Command" -TestCases $Help {
            $Help.Examples.Example.Code.Count | Should -BeGreaterOrEqual 1
        }

        It "lists a description for $Command example: <Title>" -TestCases $Examples {
            $Example.Remarks | Should -Not -BeNullOrEmpty -Because "example $($Example.Title) should have a description!"
        }
    }
}