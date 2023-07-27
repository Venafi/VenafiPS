switch ($true) {
    $IsLinux {
        Import-Module "$PSScriptRoot/linux-x64/PSSodium.dll"
    }
    $IsMacOS {
        if("$(sysctl -n machdep.cpu.brand_string)" -Like 'Apple*'){
            Import-Module "$PSScriptRoot/osx-arm64/PSSodium.dll"
        } else {
            Import-Module "$PSScriptRoot/osx-x64/PSSodium.dll"
        }
        
    }
    default {
        if ([System.Environment]::Is64BitProcess) {
            Import-Module "$PSScriptRoot/win-x64/PSSodium.dll"
        } else {
            Import-Module "$PSScriptRoot/win-x86/PSSodium.dll"
        }
    }
}
