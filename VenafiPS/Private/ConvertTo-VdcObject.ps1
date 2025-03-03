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
        [string] $TypeName
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
                $params = @{
                    Method  = 'Post'
                    UriLeaf = 'config/DnToGuid'
                    Body    = @{
                        ObjectDN = $Path
                    }
                }
                $response = Invoke-VenafiRestMethod @params

                switch ($response.Result) {
                    1 {
                        # success
                        $thisGuid = $response.Guid
                        $thisTypeName = $response.ClassName
                    }
        
                    7 {
                        throw [System.UnauthorizedAccessException]::new($response.Error)
                    }
        
                    400 {
                        throw [System.Management.Automation.ItemNotFoundException]::new($response.Error)
                    }
        
                    Default {
                        throw $response.Error
                    }
                }
        
                $thisPath = $Path
            }

            'Guid' {
                $params = @{
                    Method     = 'Post'
                    UriLeaf    = 'config/GuidToDN'
                    Body       = @{
                        ObjectGUID = "{$Guid}"
                    }
                }
        
                $response = Invoke-VenafiRestMethod @params

                switch ($response.Result) {
                    1 {
                        # success
                        $thisPath = $response.ObjectDN
                        $thisTypeName = $response.ClassName
                    }
        
                    7 {
                        throw [System.UnauthorizedAccessException]::new($response.Error)
                    }
        
                    400 {
                        throw [System.Management.Automation.ItemNotFoundException]::new($response.Error)
                    }
        
                    Default {
                        throw $response.Error
                    }
                }

                $thisGuid = $Guid
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
            Guid     = [Guid] $thisGuid
            Name     = $thisPath.Split('\')[-1]
        }

        $out | Add-Member @{'ParentPath' = $out.Path.Substring(0, $out.Path.LastIndexOf("\$($out.Name)")) }
        $out | Add-Member -MemberType ScriptMethod -Name ToString -Value { $out.Path } -Force
        $out
    }
}