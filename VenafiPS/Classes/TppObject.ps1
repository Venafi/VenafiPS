class TppObject {

    [string] $Name
    [string] $TypeName
    [string] $Path
    [guid] $Guid

    [HashTable] ToHashtable() {

        $hash = @{}
        $propNames = $this | Get-Member | Where-Object {$_.MemberType -eq 'Property'} | Select-Object -ExpandProperty Name

        foreach ($prop in $propNames) {
            if ($this.GetType().GetProperty($prop)) {
                $hash.Add($prop, $this.$prop)
            }
        }

        return $hash
    }

    TppObject ([Hashtable] $InitHash) {

        if ( -not ($InitHash.Name -and $InitHash.Path -and $InitHash.TypeName -and $InitHash.Guid) ) {
            throw "Name, TypeName, Path, and Guid are required"
        }

        $this.Name = $InitHash.Name
        $this.TypeName = $InitHash.TypeName
        $this.Path = $InitHash.Path
        $this.Guid = $InitHash.Guid
    }

    TppObject (
        [string] $Name,
        [string] $TypeName,
        [string] $Path,
        [guid] $Guid
    ) {
        $this.Name = $Name
        $this.TypeName = $TypeName
        $this.Path = $Path
        $this.Guid = $Guid
    }

    TppObject ([string] $Path) {
        $info = $Path | ConvertTo-TppGuid -IncludeType
        $this.Path = $Path
        $this.Name = Split-Path $Path -Leaf
        $this.Guid = $info.Guid
        $this.TypeName = $info.TypeName
    }

    TppObject ([string] $Path, [PSObject] $VenafiSession) {
        $info = $Path | ConvertTo-TppGuid -IncludeType -VenafiSession $VenafiSession
        $this.Path = $Path
        $this.Name = Split-Path $Path -Leaf
        $this.Guid = $info.Guid
        $this.TypeName = $info.TypeName
    }

    TppObject ([guid] $Guid) {
        $info = ConvertTo-TppPath -Guid $Guid -IncludeType
        $this.Guid = $Guid
        $this.Name = Split-Path $info.Path -Leaf
        $this.Path = $info.Path
        $this.TypeName = $info.TypeName
    }

    TppObject ([guid] $Guid, [PSObject] $VenafiSession) {
        $info = ConvertTo-TppPath -Guid $Guid -IncludeType -VenafiSession $VenafiSession
        $this.Guid = $Guid
        $this.Name = Split-Path $info.Path -Leaf
        $this.Path = $info.Path
        $this.TypeName = $info.TypeName
    }

    [string] ParentPath() {
        $leafName = Split-Path $this.Path -Leaf
        # split-path -parent doesn't work on this path so use this workaround
        return $this.Path.Replace(("\{0}" -f $leafName), "")
    }

}

