BeforeAll {
    Remove-Module 'VenafiPS' -Force -ErrorAction SilentlyContinue
    # Import-Module ./VenafiPS/VenafiPS.psd1
    $moduleInfo = Import-Module -Name './VenafiPS/VenafiPS.psd1' -Force -PassThru | Where-Object { $_.name -eq 'VenafiPS' }
}
Describe 'ExportedFunctions' {
    BeforeAll {
        $PS1FileNames = Get-ChildItem -Path "$($moduleInfo|Where-Object{$_.name -eq 'venafips'}|Select-Object -exp modulebase)\public\*.ps1" -Exclude *tests.ps1, *profile.ps1 |
        Select-Object -ExpandProperty BaseName

        $ExportedFunctions = Get-Command -Module $moduleInfo.Name -CommandType Function | Select-Object -ExpandProperty Name
    }

    Describe "FunctionsToExport for PowerShell module '$($ModuleInfo.Name)'" {

        It 'Exports one function in the module manifest per PS1 file' {
            $ModuleInfo.ExportedFunctions.Values.Name.Count | Should -Be $PS1FileNames.Count
        }

        It 'Exports functions with names that match the PS1 file base names' {
            Compare-Object -ReferenceObject $ModuleInfo.ExportedFunctions.Values.Name -DifferenceObject $PS1FileNames | Should -BeNullOrEmpty
        }

        It 'Only exports functions listed in the module manifest' {
            $ExportedFunctions.Count | Should -Be $ModuleInfo.ExportedFunctions.Values.Name.Count
        }

        It 'Contains the same function names as base file names' {
            Compare-Object -ReferenceObject $PS1FileNames -DifferenceObject $ExportedFunctions | Should -BeNullOrEmpty
        }

    }

}
