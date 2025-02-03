function Find-VdcVaultId {
    <#
    .SYNOPSIS
    Find vault IDs in the secret store

    .DESCRIPTION
    Find vault IDs in the secret store by their attributes and associated values

    .PARAMETER Attribute
    Name and value to search.
    See https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Secretstore-lookupbyassociation.php for more details.

    .PARAMETER VenafiSession
    Authentication for the function.
    The value defaults to the script session object $VenafiSession created by New-VenafiSession.
    A TLSPDC token can also be provided.
    If providing a TLSPDC token, an environment variable named VDC_SERVER must also be set.

    .INPUTS
    Attribute

    .OUTPUTS
    String

    .EXAMPLE
    Find-VdcVaultId -Attribute @{'Serial'='0812E11D213DE8E07890BCC1234567'}
    Find a vault id

    .LINK
    http://VenafiPS.readthedocs.io/en/latest/functions/Find-VdcVaultId/

    .LINK
    https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Find-VdcVaultId.ps1

    .LINK
    https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Secretstore-lookupbyassociation.php

    #>

    [CmdletBinding()]
    [Alias('Find-TppVaultId')]

    param (

        [Parameter(Mandatory, ValueFromPipeline)]
        [hashtable] $Attribute,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [psobject] $VenafiSession
    )

    begin {
        Test-VenafiSession $PSCmdlet.MyInvocation

        $params = @{

            Method        = 'Post'
            UriLeaf       = 'SecretStore/LookupByAssociation'
            Body          = @{}
        }
    }

    process {

        $thisKey = "$($Attribute.Keys[0])"
        $thisValue = "$($Attribute.Values[0])"

        switch ($thisKey) {

            { $_ -in 'Certificate Type', 'Key Size', 'Parent ID', 'Template Major Version' } {
                $type = 'IntValue'
            }

            { $_ -in 'Create Date', 'Revocation Check Date', 'Revocation Date', 'ValidFrom', 'ValidTo' } {
                $type = 'ValueDate'
            }

            Default {
                $type = 'StringValue'
            }
        }

        $params.Body = @{
            'Name' = $thisKey
            $type  = $thisValue
        }

        $response = Invoke-VenafiRestMethod @params

        if ( $response.Result -eq 0 ) {
            $response.VaultIDs
        }
        else {
            throw ('Secret store search failed with error code {0}' -f $response.Result)
        }
    }

    end {

    }
}