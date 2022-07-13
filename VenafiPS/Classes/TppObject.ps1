class TppObject {

    [string] $Name
    [string] $Path
    [string] $TypeName
    [guid] $Guid
    [string] $ParentPath

    hidden _init (
        [string] $Path,
        [string] $TypeName,
        [guid] $Guid
    ) {
        $this.Path = $Path.Replace('\\', '\')
        $this.TypeName = $TypeName
        $this.Guid = $Guid
        # issue 129
        $this.Name = $this.Path.Split('\')[-1]
        $this.ParentPath = $this.Path.Replace(('\{0}' -f $this.Name), '')
        $this | Add-Member -MemberType ScriptMethod -Name ToString -Value { $this.Path } -Force
    }

    TppObject (
        [string] $Path,
        [string] $TypeName,
        [guid] $Guid
    ) {
        $this._init($Path, $TypeName, $Guid)
    }

    TppObject ([string] $Path) {
        $info = $Path | ConvertTo-TppGuid -IncludeType
        $this._init($Path, $info.TypeName, $info.Guid)
    }

    TppObject ([string] $Path, [PSObject] $VenafiSession) {
        $info = $Path | ConvertTo-TppGuid -IncludeType -VenafiSession $VenafiSession
        $this._init($Path, $info.TypeName, $info.Guid)
    }

    TppObject ([guid] $Guid) {
        $info = ConvertTo-TppPath -Guid $Guid -IncludeType
        $this._init($info.Path, $info.TypeName, $Guid)
    }

    TppObject ([guid] $Guid, [PSObject] $VenafiSession) {
        $info = ConvertTo-TppPath -Guid $Guid -IncludeType -VenafiSession $VenafiSession
        $this._init($info.Path, $info.TypeName, $Guid)
    }

    [HashTable] ToHashtable() {

        $hash = @{}
        $propNames = $this | Get-Member | Where-Object { $_.MemberType -eq 'Property' } | Select-Object -ExpandProperty Name

        foreach ($prop in $propNames) {
            if ($this.GetType().GetProperty($prop)) {
                $hash.Add($prop, $this.$prop)
            }
        }

        return $hash
    }

    TppObject ([Hashtable] $InitHash) {

        if ( -not ($InitHash.Path -and $InitHash.TypeName -and $InitHash.Guid) ) {
            throw "Name, TypeName, Path, and Guid are required"
        }

        $this._init($InitHash.Path, $InitHash.TypeName, $InitHash.Guid)
    }
}

