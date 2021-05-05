$here = 'C:\data\code\VenafiPS\VenafiPS'
Write-Output "module path: $here"
# $here = Split-Path -Parent $MyInvocation.MyCommand.Path

$modulePath = $here
$moduleName = Split-Path -Path $modulePath -Leaf
Write-Output "module name: $moduleName"
Describe "'$moduleName' Module Analysis with PSScriptAnalyzer" {
    Context 'Standard Rules' {
        # Define PSScriptAnalyzer rules
        $scriptAnalyzerRules = Get-ScriptAnalyzerRule # Just getting all default rules

        # Perform analysis against each rule
        forEach ($rule in $scriptAnalyzerRules) {
            It "should pass '$rule' rule" {
                Invoke-ScriptAnalyzer -Path "$here\$moduleName.psm1" -IncludeRule $rule | Should -BeNullOrEmpty
            }
        }
    }
}

# Dynamically defining the functions to analyze
$functionPaths = @()
if (Test-Path -Path "$modulePath\Private\*.ps1") {
    $functionPaths += Get-ChildItem -Path "$modulePath\Private\*.ps1" -Exclude "*.Tests.*"
}
if (Test-Path -Path "$modulePath\Public\*.ps1") {
    $functionPaths += Get-ChildItem -Path "$modulePath\Public\*.ps1" -Exclude "*.Tests.*"
}

$TestCases = @()
$functionPaths.ForEach{$TestCases += @{FunctionPath = $_}}
Describe "Function Analysis with PSScriptAnalyzer" {
    Context 'Standard Rules' {
        # Define PSScriptAnalyzer rules
        $scriptAnalyzerRules = Get-ScriptAnalyzerRule # Just getting all default rules

        # Perform analysis against each rule
        forEach ($rule in $scriptAnalyzerRules) {
            It "should pass '$rule' rule" -TestCases $TestCases {
                Param($FunctionPath)
                Invoke-ScriptAnalyzer -Path $FunctionPath -IncludeRule $rule | Should -BeNullOrEmpty
            }
        }
    }
}

# Running the analysis for each function
# foreach ($functionPath in $functionPaths) {
#     $functionName = $functionPath.BaseName

#     Describe "'$functionName' Function Analysis with PSScriptAnalyzer" {
#         Context 'Standard Rules' {
#             # Define PSScriptAnalyzer rules
#             $scriptAnalyzerRules = Get-ScriptAnalyzerRule # Just getting all default rules

#             # Perform analysis against each rule
#             forEach ($rule in $scriptAnalyzerRules) {
#                 It "should pass '$rule' rule" {
#                     Invoke-ScriptAnalyzer -Path $functionPath -IncludeRule $rule | Should -BeNullOrEmpty
#                 }
#             }
#         }
#     }
# }