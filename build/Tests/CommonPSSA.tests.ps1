Describe 'Testing against PSSA rules' {
    Context 'PSSA Standard Rules' {

        # load up my list of scripts to test
        $scripts = @( Get-ChildItem -Path .\*.ps1 -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.FullName -notmatch '\\Tests\\'} )

        Foreach($import in $scripts) {
            Try {
                write-output "Processing $import.fullname"
                $analysis = Invoke-ScriptAnalyzer -Path $import.fullname
                $scriptAnalyzerRules = Get-ScriptAnalyzerRule | Where-Object { $_.RuleName -ne 'PSUseOutputTypeCorrectly' }

                forEach ($rule in $scriptAnalyzerRules) {
                    It "Should pass $rule" {
                        If ($analysis.RuleName -contains $rule) {
                            $analysis |
                            Where-Object RuleName -EQ $rule -outvariable failures |
                            Out-Default
                            $failures.Count | Should Be 0
                        }
                    }
                }
            }
            Catch {
                Write-Error -Message "Failed to run test $($import.fullname): $_"
            }
        }

    }
}
