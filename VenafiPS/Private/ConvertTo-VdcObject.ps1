function ConvertTo-VdcObject {

    [CmdletBinding(DefaultParameterSetName = 'Path')]

    param (
        [Parameter(Mandatory, ParameterSetName = 'ByObject', ValueFromPipeline)]
        [pscustomobject] $InputObject,

        [Parameter(Mandatory, ParameterSetName = 'Path', ValueFromPipeline)]
        [Parameter(Mandatory, ParameterSetName = 'All')]
        [string] $Path,

        [Parameter(Mandatory, ParameterSetName = 'Guid', ValueFromPipeline)]
        [Parameter(Mandatory, ParameterSetName = 'All')]
        [guid] $Guid,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'Guid')]
        [Parameter(Mandatory, ParameterSetName = 'All')]
        [string] $TypeName,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'Guid')]
        [Alias('Key', 'AccessToken')]
        [psobject] $VenafiSession
    )

    begin {
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {

            'ByObject' {
                $thisPath = $InputObject.Path
                $thisGuid = $InputObject.Guid
                $thisTypeName = $InputObject.TypeName
            }

            'Path' {
                $thisPath = $Path
                $info = $Path | ConvertTo-VdcGuid -IncludeType
                $thisGuid = $info.Guid
                $thisTypeName = $info.TypeName
            }

            'Guid' {
                $thisGuid = $Guid
                $info = ConvertTo-VdcPath -Guid $Guid -IncludeType
                $thisPath = $info.Path
                $thisTypeName = $info.TypeName
            }

            Default {
                $thisPath = $Path
                $thisGuid = $Guid
                $thisTypeName = $TypeName
            }
        }

        $out = [pscustomobject]@{
            Path     = $thisPath.Replace('\\', '\')
            TypeName = $thisTypeName
            Guid     = $thisGuid
            Name     = $thisPath.Split('\')[-1]
        }

        $out | Add-Member @{'ParentPath' = $out.Path.Substring(0, $out.Path.LastIndexOf("\$($out.Name)")) }
        $out | Add-Member -MemberType ScriptMethod -Name ToString -Value { $out.Path } -Force
        $out
    }
}