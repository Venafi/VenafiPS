<#
.SYNOPSIS
    Create standalone script with VenafiPS functionality, but without the module installed
.DESCRIPTION
    Search the provided script for VenafiPS references and create a new script with all the required VenafiPS code in it.
    Optionally, you can select the code from a specific VenafiPS version.  It must be installed already.
.EXAMPLE
    Set-VenafiStandaloneScript -ScriptPath c:\temp\old.ps1
    Create a new script
.EXAMPLE
    Set-VenafiStandaloneScript -ScriptPath c:\temp\old.ps1 -ModuleVersion 3.2
    Create a new script with a specific version of the VenafiPS module code
.NOTES
    don't use VenafiPS aliases, not supported
    TODO
    - add classes/enums - done
    - remove requires/import statements?
    -
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateScript({
            if (Test-Path $_) {
                $true
            }
            else {
                throw "$_ does not exist"
            }
        })]
    [string] $ScriptPath,

    [Parameter()]
    [string] $ModuleVersion
)

begin {
    function Get-PsOneAst {
        <#
            .SYNOPSIS
                Retrieve Ast objects of given type
            .LINK
                https://powershell.one/powershell-internals/parsing-and-tokenization/abstract-syntax-tree#returning-ast-objects
            #>
        param
        (
            # PowerShell code to examine:
            [Parameter(Mandatory, ValueFromPipeline)]
            [string] $Code,

            # requested Ast type
            # use dynamic argument completion:
            [ArgumentCompleter({
                    # receive information about current state:
                    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)


                    # get all ast types
                    [PSObject].Assembly.GetTypes().Where{ $_.Name.EndsWith('Ast') }.Name |
                    Sort-Object |
                    # filter results by word to complete
                    Where-Object { $_.LogName -like "$wordToComplete*" } |
                    Foreach-Object {
                        # create completionresult items:
                        [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
                    }
                })]
            [string[]] $AstType = '*',

            # when set, do not recurse into nested scriptblocks:
            [Switch] $NoRecursion
        )

        begin {
            # create the filter predicate by using the submitted $AstType
            # if the user did not specify it is "*" by default, including all:
            if ( $AstType.Count -eq 1 ) {
                $predicate = { param($astObject) $astObject.GetType().Name -like $AstType }
            }
            else {
                $predicate = { param($astObject) $astObject.GetType().Name -in $AstType }
            }
        }
        # do this for every submitted code:
        process {
            # we need to read the errors because we are accepting text which
            # can contain syntax errors:
            $errors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($Code, [ref]$null, [ref]$errors)

            # if the code contains syntax errors and is invalid, bail out:
            if ($errors) { throw [System.InvalidCastException]::new("Submitted text could not be converted to PowerShell because it contains syntax errors: $($errors | Out-String)") }

            # search for all requested ast...
            $ast.FindAll($predicate, !$NoRecursion) |
            # and dynamically add a visible property for the ast object type:
            Add-Member -MemberType ScriptProperty -Name Type -Value { $this.GetType().Name } -PassThru
        }
    }

    function Get-ModuleFunction {
        <#
            .SYNOPSIS
                Get public and private module functions
            .DESCRIPTION
                Long description
            .EXAMPLE
                Get-ModuleCommand -ModuleName VenafiPS
                Get module and function info from most recent module version found
            .EXAMPLE
                Get-ModuleCommand -ModuleName VenafiPS -Version
                Get module and function info from specific version
            .INPUTS
                ModuleName
            .OUTPUTS
                Hashtable, Module and Functions
            #>

        [CmdLetBinding()]
        [OutputType([System.Management.Automation.FunctionInfo[]])]

        param (
            # Specifies the name of the Module(s)
            [Parameter(Mandatory, ValueFromPipeline)]
            [ValidateNotNullOrEmpty()]
            [string] $ModuleName,

            [Parameter()]
            [string] $Version
        )

        Begin {
            # this throws an error if the module isn't already loaded so make it quiet
            Remove-Module $ModuleName -ErrorAction SilentlyContinue
        }

        Process {
            $params = @{
                Name  = $ModuleName
                Force = $true
            }

            if ( $Version ) {
                $params.RequiredVersion = $Version
            }

            $thisModule = Import-Module @params

            if ( $thisModule ) {
                $functions = $thisModule.Invoke({ Get-Command -Module $ModuleName -CommandType Function })

                @{
                    Module    = $module
                    Functions = $functions
                }
            }
        }
    }
}

process {
    $astTypes = 'CommandAst', 'TypeExpressionAst'
    $script = (Get-Command $scriptPath).ScriptBlock

    $module = Get-ModuleFunction -Module VenafiPS -Version $ModuleVersion
    # make sure the module exists before we continue
    if ( -not $module ) {
        throw 'VenafiPS module not found'
    }

    $moduleRootPath = Split-Path $module.Module.Path -Parent
    $enumFiles = Get-ChildItem "$moduleRootPath\Enum"
    $classFiles = Get-ChildItem "$moduleRootPath\Classes"

    $scriptCommands = Get-PsOneAst -Code (Get-Content -Path $scriptPath -Raw) -AstType $astTypes

    $functionsToAdd = $enumsToAdd = @()
    foreach ($cmd in $scriptCommands ) {

        # get module function calls and add to list of functions to be added

        $moduleFunction = $module.Functions | Where-Object { $_.Name -eq $cmd.CommandElements.Value }

        if ( $moduleFunction -and $cmd.CommandElements.Value -notin $functionsToAdd.Name ) {
            Write-Verbose ('Adding direct function {0}' -f $moduleFunction.Name)
            $functionsToAdd += $moduleFunction

            # get module function calls from within the functions we've already added
            # these could be public or private functions
            $functionItems = Get-PsOneAst -Code $moduleFunction.Definition -AstType $astTypes
            foreach ($thisFunctionItem in $functionItems) {
                switch ($thisFunctionItem.Type) {
                    'CommandAst' {
                        $moduleFunctionInner = $moduleFunctions | Where-Object { $_.Name -eq $thisFunctionItem.CommandElements.Value }
                        if ( $moduleFunctionInner -and $thisFunctionItem.CommandElements.Value -notin $functionsToAdd.Name ) {
                            Write-Verbose ('Adding nested function {0} used in {1}' -f $moduleFunctionInner.Name, $moduleFunction.Name)
                            $functionsToAdd += $moduleFunctionInner
                        }
                    }

                    'TypeExpressionAst' {
                        $enumName = $thisFunctionItem.TypeName.ToString()
                        $thisEnum = $enumFiles | Where-Object { $_.Name -eq "$enumName.ps1" }
                        if ( $thisEnum -and $thisEnum.Name -notin $enumsToAdd.Name ) {
                            Write-Verbose ('Found type {0}' -f $enumName)
                            $enumsToAdd += $thisEnum
                        }
                    }

                    Default {}
                }
            }
        }
    }

    $newScript = [System.Text.StringBuilder]::new($script)

    # add to begin block if there is one, otherwise add to end of script
    if ( $Script.Ast.BeginBlock ) {
        $addOffset = $Script.Ast.BeginBlock.Extent.StartOffset + 1
    }
    else {
        $addOffset = $Script.Ast.Extent.EndScriptPosition.Offset
    }

    # build the full function string and write to new script
    foreach ($functionToAdd in $functionsToAdd) {
        $fullFunction = "`r`n{0} {1} {{`r`n# v{2}{3}`r`n}}`r`n`r`n" -f $functionToAdd.CommandType, $functionToAdd.Name, $functionToAdd.Version, $functionToAdd.Definition
        $newScript.Insert($addOffset, $fullFunction) | Out-Null
        $addOffset += $fullFunction.Length
    }

    # add enums into script
    foreach ($thisEnum in $enumsToAdd) {
        $fullEnum = "`r`n{0}`r`n`r`n" -f (Get-Content $thisEnum.FullName -Raw)
        $newScript.Insert($addOffset, $fullEnum) | Out-Null
        $addOffset += $fullEnum.Length
    }

    # add classes into script
    # currently all are being added
    foreach ($thisClass in $classFiles) {
        $fullClass = "`r`n{0}`r`n`r`n" -f (Get-Content $thisClass.FullName -Raw)
        $newScript.Insert($addOffset, $fullClass) | Out-Null
        $addOffset += $fullEnum.Length
    }

    $fileExt = [System.IO.Path]::GetExtension($ScriptPath)
    $newScript | Set-Content -Path ($ScriptPath.Replace($fileExt, "-Standalone$fileExt"))
}

end {

}



