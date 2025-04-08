
$ModuleName = 'VenafiPS'
$ModulePath = "$PSScriptRoot/../VenafiPS/VenafiPS.psd1"
Remove-Module $ModuleName -ErrorAction SilentlyContinue
Import-Module $ModulePath -Force

