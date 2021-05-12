# Test-ModuleHash

## SYNOPSIS
Validate module files

## SYNTAX

```
Test-ModuleHash [<CommonParameters>]
```

## DESCRIPTION
Validate all module files against the cryptographic hash created when the module was published.
A file containing all hashes will be downloaded from the GitHub release and compared to the module files currently in use.

## EXAMPLES

### EXAMPLE 1
```
Test-ModuleHash
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### Boolean
## NOTES

## RELATED LINKS
