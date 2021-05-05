$ErrorActionPreference = 'stop'

Install-PackageProvider -Name Nuget -Scope CurrentUser -Force -Confirm:$false
Install-Module -Name Pester -Scope CurrentUser -Force -Confirm:$false -SkipPublisherCheck -MaximumVersion 4.999.999
Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force -Confirm:$false
Import-Module -Name Pester, PSScriptAnalyzer

$failure = $false

$tests = @{
    OutputFile   = 'TestResults.xml'
    OutputFormat = 'NUnitXml'
    Script       = '.'
    PassThru     = $true
}
$results = Invoke-Pester @tests
if ( $results.FailedCount -gt 0 ) {
    $failure = $true
}

$tests.OutputFile = 'PSSAResults.xml'
$tests.Script = "$PSScriptRoot\CommonPSSA.tests.ps1"
$results = Invoke-Pester @tests
if ( $results.FailedCount -gt 0 ) {
    $failure = $true
}

if ( $failure ) {
    throw "at least one test failed"
}
