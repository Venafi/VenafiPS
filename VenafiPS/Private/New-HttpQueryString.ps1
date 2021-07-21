<#
.SYNOPSIS
    Generate http query string
.LINK
    https://powershellmagazine.com/2019/06/14/pstip-a-better-way-to-generate-http-query-strings-in-powershell/
#>
function New-HttpQueryString {
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'No state is actually changing')]

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Uri,

        [Parameter(Mandatory = $true)]
        [Hashtable]
        $QueryParameter
    )
    # Add System.Web
    Add-Type -AssemblyName System.Web

    # Create a http name value collection from an empty string
    $nvCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    foreach ($key in $QueryParameter.Keys) {
        $nvCollection.Add($key, $QueryParameter.$key)
    }

    # Build the uri
    $uriRequest = [System.UriBuilder]$uri
    $uriRequest.Query = $nvCollection.ToString()

    return $uriRequest.Uri.OriginalString
}