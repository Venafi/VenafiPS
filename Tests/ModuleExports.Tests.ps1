BeforeAll {
    Remove-Module 'VenafiPS' -Force -ErrorAction SilentlyContinue
    $moduleInfo = Import-Module -Name './VenafiPS/VenafiPS.psd1' -Force -PassThru | Where-Object { $_.name -eq 'VenafiPS' }
}
Describe 'ExportedFunctions' {
    BeforeAll {
        $ps1FileNames = Get-ChildItem -Path "$($moduleInfo | Where-Object{$_.name -eq 'venafips'} | Select-Object -exp modulebase)\Public\*.ps1" -Exclude *tests.ps1, *profile.ps1 | Select-Object -ExpandProperty BaseName

        $exportedFunctions = Get-Command -Module $moduleInfo.Name -CommandType Function | Select-Object -ExpandProperty Name
    }

    Describe "FunctionsToExport for PowerShell module '$($moduleInfo.Name)'" {

        It 'Exports one function in the module manifest per PS1 file' {
            $moduleInfo.ExportedFunctions.Values.Name.Count | Should -Be $ps1FileNames.Count
        }

        It 'Exports functions with names that match the PS1 file base names' {
            Compare-Object -ReferenceObject $moduleInfo.ExportedFunctions.Values.Name -DifferenceObject $ps1FileNames | Should -BeNullOrEmpty
        }

        It 'Only exports functions listed in the module manifest' {
            $exportedFunctions.Count | Should -Be $ModuleInfo.ExportedFunctions.Values.Name.Count
        }

        It 'Contains the same function names as base file names' {
            Compare-Object -ReferenceObject $ps1FileNames -DifferenceObject $exportedFunctions | Should -BeNullOrEmpty
        }

    }

}
