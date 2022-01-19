<#
.SYNOPSIS
Create new custom field in Venafi of the specified class and type.

.DESCRIPTION
Creates a new custom field in Venafi. Required parameters are name, label, class and type.
See Venafi docs for information about other metadata items.

.PARAMETER Name
Name of new custom field

.PARAMETER Label
Label of new custom field

.PARAMETER Class
Class of new custom field, either 'Device' or 'X509 Certificate'

.PARAMETER Type
Type of new custom field, one of 'String', 'List', 'DateTime', 'Identity'

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.INPUTS
None

.OUTPUTS
Query returns a PSCustomObject with the following properties:
    AllowedValues
    Class
    DateOnly
    DN
    ErrorMessage
    Guid
    Help
    Label
    Mandatory
    Name
    Policyable
    RegularExpression
    RenderHidden
    RenderReadOnly
    Single
    TimeOnly
    Type

.EXAMPLE
New-TppCustomField -Name "Last Date" -Label "Last Date" -Class "X509 Certificate" -Type "String" -RenderReadOnly -Help "Last Date of certificate import"
Create new custom field for certificates

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/New-TppCustomField/

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-DefineItem.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Metadata-Item.php

#>

function New-TppCustomField {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Label,

        [Parameter(Mandatory)]
        [ValidateSet('Device', 'X509 Certificate')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Class,

        [Parameter(Mandatory)]
        [ValidateSet('String', 'List', 'DateTime', 'Identity')]
        [ValidateNotNullOrEmpty()]
        [string]$Type,

        [Parameter()]
        [string[]]$AllowedValue,

        [Parameter()]
        [string]$Single,

        [Parameter()]
        [string]$Help,

        [Parameter()]
        [string]$ErrorMessage,

        [Parameter()]
        [switch]$Mandatory,

        [Parameter()]
        [switch]$Policyable,

        [Parameter()]
        [string]$RegEx,

        [Parameter()]
        [switch]$RenderHidden,

        [Parameter()]
        [switch]$RenderReadOnly,

        [Parameter()]
        [switch]$DateOnly,

        [Parameter()]
        [switch]$TimeOnly,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    begin {
        $VenafiSession.Validate('TPP')

        $resultObj = @()

        if ( $Type -eq 'String' ) {
            $ItemType = '1'
        } elseif ( $Type -eq 'List' ) {
            $ItemType = '2'
        } elseif ( $Type -eq 'DateTime' ) {
            $ItemType = '4'
        } elseif ( $Type -eq 'Identity' ) {
            $ItemType = '5'
        }

        $params = @{
            VenafiSession = $VenafiSession
            Method     = 'Post'
            UriLeaf    = 'Metadata/DefineItem'
            Body       = @{
                "Item" = @{
                    "Name" = $Name
                    "Classes" = @($Class)
                    "Label" = $Label
                    "Type" = $ItemType
                    "Mandatory" = $Mandatory.ToString().ToLower()
                    "Policyable" = $Policyable.ToString().ToLower()
                    "RenderHidden" = $RenderHidden.ToString().ToLower()
                    "RenderReadOnly" = $RenderReadOnly.ToString().ToLower()
                    "DateOnly" = $DateOnly.ToString().ToLower()
                    "TimeOnly" = $TimeOnly.ToString().ToLower()
                }
            }
        }
        if ( $PSBoundParameters.ContainsKey('Help') ) {
            $params.Body.Item['Help'] = $Help
        }
        if ( $PSBoundParameters.ContainsKey('AllowedValue') ) {
            $params.Body.Item['AllowedValues'] = @($AllowedValue)
        }
        if ( $PSBoundParameters.ContainsKey('Single') ) {
            $params.Body.Item['Single'] = $Single
        }
        if ( $PSBoundParameters.ContainsKey('ErrorMessage') ) {
            $params.Body.Item['ErrorMessage'] = $ErrorMessage
        }
        if ( $PSBoundParameters.ContainsKey('RegEx') ) {
            $params.Body.Item['RegularExpression'] = $RegEx
        }
    }

    end {
        if ( $PSCmdlet.ShouldProcess($Label) ) {
            
            $response = Invoke-VenafiRestMethod @params

            if ( $response.Result -eq [TppMetadataResult]::Success ) {
                if (( $PassThru )) {
                    $resultObj = [PSCustomObject] @{
                    "Path"    = $response.Item.DN
                    "Label" = $response.Item.Label
                    "Name"  = $response.Item.Name
                    "Guid"  = [guid]$response.Item.Guid
                    "Type"  = $response.Item.Type
                    "Class" = $response.Item.Classes
                    }
                    if ($response.Item.Mandatory) {
                    $resultObj | Add-Member -MemberType NoteProperty -Name "Mandatory" -Value $response.Item.Mandatory
                    }
                    if ($response.Item.Policyable) {
                    $resultObj | Add-Member -MemberType NoteProperty -Name "Policyable" -Value $response.Item.Policyable
                    }
                    if ($response.Item.RenderHidden) {
                    $resultObj | Add-Member -MemberType NoteProperty -Name "RenderHidden" -Value $response.Item.RenderHidden
                    }
                    if ($response.Item.RenderReadOnly) {
                    $resultObj | Add-Member -MemberType NoteProperty -Name "RenderReadOnly" -Value $response.Item.RenderReadOnly
                    }
                    if ($response.Item.DateOnly) {
                    $resultObj | Add-Member -MemberType NoteProperty -Name "DateOnly" -Value $response.Item.DateOnly
                    }
                    if ($response.Item.TimeOnly) {
                    $resultObj | Add-Member -MemberType NoteProperty -Name "TimeOnly" -Value $response.Item.TimeOnly
                    }
                    if ($response.Item.Help) {
                    $resultObj | Add-Member -MemberType NoteProperty -Name "Help" -Value $response.Item.Help
                    }
                    if ($response.Item.AllowedValues) {
                    $resultObj | Add-Member -MemberType NoteProperty -Name "AllowedValues" -Value $response.Item.AllowedValues
                    }
                    if ($response.Item.Single) {
                    $resultObj | Add-Member -MemberType NoteProperty -Name "Single" -Value $response.Item.Single
                    }
                    if ($response.Item.ErrorMessage) {
                    $resultObj | Add-Member -MemberType NoteProperty -Name "ErrorMessage" -Value $response.Item.ErrorMessage
                    }
                    if ($response.Item.RegularExpression) {
                    $resultObj | Add-Member -MemberType NoteProperty -Name "RegularExpression" -Value $response.Item.RegularExpression
                    }
                    return $resultObj
                }
            } else {
                throw $response.Error
            }
        }
    }
}
