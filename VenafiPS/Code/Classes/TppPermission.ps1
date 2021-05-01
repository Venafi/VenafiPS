class TppPermission {

    [bool] $IsAssociateAllowed
    [bool] $IsCreateAllowed
    [bool] $IsDeleteAllowed
    [bool] $IsManagePermissionsAllowed
    [bool] $IsPolicyWriteAllowed
    [bool] $IsPrivateKeyReadAllowed
    [bool] $IsPrivateKeyWriteAllowed
    [bool] $IsReadAllowed
    [bool] $IsRenameAllowed
    [bool] $IsRevokeAllowed
    [bool] $IsViewAllowed
    [bool] $IsWriteAllowed

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
}

