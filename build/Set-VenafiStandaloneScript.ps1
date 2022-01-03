<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    don't use VenafiPS aliases, not supported
    TODO
    - add classes/enums
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

    function Get-ModuleCommand {
        <#
            .SYNOPSIS
                Get public and private module functions
            .DESCRIPTION
                Long description
            .EXAMPLE
                PS C:\> <example usage>
                Explanation of what the example does
            .INPUTS
                Inputs (if any)
            .OUTPUTS
                Output (if any)
            .NOTES
                General notes
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
            Remove-Module $ModuleName -ErrorAction SilentlyContinue
        }

        Process {
            $params = @{
                Name    = $ModuleName
                Force   = $true
                # PassThru = $true
                Verbose = $false
            }

            if ( $Version ) {
                $params.RequiredVersion = $Version
            }

            Import-Module @params

            $module = Get-Module -Name $ModuleName
            $functions = $module.Invoke({ Get-Command -Module $ModuleName -CommandType Function })
            # $functions = $module.Invoke({ Get-Command -Module $ModuleName }) | Where-Object { $_.CommandType -eq 'Function' }

            @{
                Module    = $module
                Functions = $functions
            }
        }
    }
}

process {
    $astTypes = 'CommandAst', 'TypeExpressionAst'
    $script = (Get-Command $scriptPath).ScriptBlock

    $module = Get-ModuleCommand -Module VenafiPS -Version $ModuleVersion
    $moduleRootPath = Split-Path $module.Module.Path -Parent
    $enumFiles = gci "$moduleRootPath\Enum"
    $classFiles = gci "$moduleRootPath\Classes"

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



