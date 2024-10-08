<#
.SYNOPSIS
    Create standalone script with VenafiPS functionality, but without the module installed
.DESCRIPTION
    Search the provided script for VenafiPS references and create a new script with all the required VenafiPS code in it.
    The new script will be created in the same folder as the original with -Standalone appended.
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
                Get-ModuleCommand -ModuleName VenafiPS -Version 3.2
                Get module and function info from specific version
            .INPUTS
                ModuleName
            .OUTPUTS
                Hashtable, Module and Functions keys
            #>

        [CmdletBinding()]
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
                Name     = $ModuleName
                Force    = $true
                PassThru = $true
            }

            if ( $Version ) {
                $params.RequiredVersion = $Version
            }

            $thisModule = Import-Module @params | Where-Object { $_.Name -eq $ModuleName }

            if ( $thisModule ) {
                # must precreate the scriptblock to ensure $ModuleName is expanded
                $sb = [scriptblock]::Create("Get-Command -Module $ModuleName -CommandType Function")
                # invoking from within the module is how we get the private functions
                $functions = $thisModule.Invoke($sb, $null)

                @{
                    Module    = $thisModule
                    Functions = $functions
                }
            }
        }
    }

    function Remove-Sig {

        [CmdletBinding()]
        param (
            [Parameter(Mandatory, ValueFromPipeline)]
            [string] $Path
        )

        process {

            # Define start and end markers
            $startMarker = "# SIG # Begin signature block"
            $endMarker = "# SIG # End signature block"

            # Read the file content
            $fileContent = Get-Content $Path

            # Initialize flags
            $insideSection = $false
            $outputContent = @()

            # Process each line
            foreach ($line in $fileContent) {
                if ($line -match $startMarker) {
                    $insideSection = $true
                    continue
                }
                if ($line -match $endMarker) {
                    $insideSection = $false
                    continue
                }
                if (-not $insideSection) {
                    $outputContent += $line
                }
            }

            # Write the output content back to the file
            $outputContent -join "`n"
        }
    }
}

process {
    $astTypes = 'CommandAst', 'TypeExpressionAst', 'ParamBlockAst', 'NamedBlockAst'
    $script = (Get-Command $scriptPath).ScriptBlock

    $module = Get-ModuleFunction -Module VenafiPS -Version $ModuleVersion
    # make sure the module exists before we continue
    if ( -not $module ) {
        throw 'VenafiPS module not found'
    }

    $moduleRootPath = Split-Path $module.Module.Path -Parent
    $enumFiles = Get-ChildItem "$moduleRootPath\Enum"
    $classFiles = Get-ChildItem "$moduleRootPath\Classes"

    $scriptCommands = @(Get-PsOneAst -Code (Get-Content -Path $scriptPath -Raw))
    # $scriptCommands = @(Get-PsOneAst -Code (Get-Content -Path $scriptPath -Raw) -AstType $astTypes)

    $functionsToAdd = $enumsToAdd = @()

    for ($i = 0; $i -lt $scriptCommands.Count; $i++) {

        $thisCommand = $scriptCommands[$i]

        switch ($thisCommand.Type) {
            'CommandAst' {
                $moduleFunction = $module.Functions | Where-Object { $_.Name -eq ($thisCommand.CommandElements.Value | Select-Object -First 1) }
                if ( $moduleFunction -and $moduleFunction.Name -notin $functionsToAdd.Name ) {
                    Write-Verbose ('Adding function {0}' -f $moduleFunction.Name)
                    $functionsToAdd += $moduleFunction

                    # add new function to loop to be checked
                    $scriptCommands += Get-PsOneAst -Code $moduleFunction.Definition -AstType $astTypes
                }
            }

            'TypeExpressionAst' {
                $enumName = $thisCommand.TypeName.ToString()
                $thisEnum = $enumFiles | Where-Object { $_.Name -eq "$enumName.ps1" }
                if ( $thisEnum -and $thisEnum.Name -notin $enumsToAdd.Name ) {
                    Write-Verbose ('Adding type {0}' -f $enumName)
                    $enumsToAdd += $thisEnum
                }
            }
        }
    }

    $addToScript = [System.Text.StringBuilder]::new()

    $null = $addToScript.AppendLine(('# Including VenafiPS code v{0}' -f $module.Module.Version.ToString()))

    # add enums into script
    # currently all are being added as ast isn't picking them all up
    # eg. TppManagementType isn't picked up from Find-VdcCertificate
    foreach ($thisEnum in $enumFiles) {
        $raw = Remove-Sig -Path $thisEnum.FullName

        $fullEnum = "`r`n{0}`r`n`r`n" -f $raw
        $null = $addToScript.AppendLine($fullEnum)
    }

    # add classes into script
    # currently all are being added
    foreach ($thisClass in $classFiles) {
        $raw = Remove-Sig -Path $thisClass.FullName

        $fullClass = "`r`n{0}`r`n`r`n" -f $raw
        $null = $addToScript.AppendLine($fullClass)
    }

    # build the full function string and write to new script
    foreach ($functionToAdd in $functionsToAdd) {
        $fullFunction = "`r`n{0} {1} {{`r`n{2}`r`n}}`r`n`r`n" -f $functionToAdd.CommandType, $functionToAdd.Name, $functionToAdd.Definition
        $null = $addToScript.AppendLine($fullFunction)
    }

    $newScript = [System.Text.StringBuilder]::new($script)

    $paramBlock = $scriptCommands | Where-Object { $_.Type -eq 'ParamBlockAst' -and $_.Parent.ToString() -eq $script.ToString() }

    $fileContent = @(Get-Content $scriptPath)
    $addOffset = 0

    # add to begin block if there is one
    if ( $Script.Ast.BeginBlock ) {
        $addOffset = $Script.Ast.BeginBlock.Extent.StartOffset
    }
    elseif ( $paramBlock ) {
        # param block exists, add after

        $insideParamBlock = $false

        # Process each line to find the end of the param block
        for ($i = 0; $i -lt $fileContent.Length; $i++) {
            $line = $fileContent[$i]
            $addOffset += $line.Length + 1

            if ($line -match "^param\s*\(") {
                $insideParamBlock = $true
            }

            if ($insideParamBlock -and $line -match "\)\s*$") {
                $insideParamBlock = $false
                break
            }
        }
    }
    else {

        $insideCommentBlock = $false

        # check for comments and requires at the top of the script
        for ($i = 0; $i -lt $fileContent.Length; $i++) {
            $line = $fileContent[$i]
            $lineTrimmed = $line.Trim()

            if ( $lineTrimmed -like '*<#*' ) {
                # block comment
                $insideCommentBlock = $true
                $addOffset += $line.Length
            }
            elseif ( $lineTrimmed -like '*#>*' ) {
                # end block comment
                $insideCommentBlock = $false
                $addOffset += $line.Length
            }
            elseif ( $lineTrimmed -like '#*' -or $lineTrimmed -eq '' ) {
                # comment or blank line, keep going
                $addOffset += $line.Length
            }
            elseif ( $insideCommentBlock ) {
                # inside block comment, keep going
                $addOffset += $line.Length
            }
            else {
                break
            }
            $addOffset += 1
        }
    }

    $null = $newScript.Insert($addOffset, $addToScript.ToString())

    # existing script cleanup
    $newScriptClean = $newScript.ToString()
    $newScriptClean = $newScriptClean -replace '#Requires -Modules venafips', ''
    $newScriptClean = $newScriptClean -replace 'import-module.*venafips', ''

    $fileExt = [System.IO.Path]::GetExtension($ScriptPath)
    $newScriptClean | Set-Content -Path ($ScriptPath.Replace($fileExt, "-Standalone$fileExt"))
}

end {

}



