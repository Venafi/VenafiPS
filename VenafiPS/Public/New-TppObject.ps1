<#
.SYNOPSIS
Create a new object

.DESCRIPTION
Generic use function to create a new object if a specific function hasn't been created yet for the class.

.PARAMETER Path
Full path, including name, for the object to be created.

.PARAMETER Class
Class name of the new object.
See https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/SchemaReference/r-SDK-CNattributesWhere.php for more info.

.PARAMETER Attribute
Hashtable with initial values for the new object.
These will be specific to the object class being created.

.PARAMETER PushCertificate
If creating an application object, you can optionally push the certificate once the creation is complete.
Only available if a 'Certificate' key containing the certificate path is provided for Attribute.
Please note, this feature was added in v18.3.

.PARAMETER PassThru
Return a TppObject representing the newly created object.

.PARAMETER VenafiSession
Session object created from New-VenafiSession method.  The value defaults to the script session object $VenafiSession.

.EXAMPLE
New-TppObject -Path '\VED\Policy\Test Device' -Class 'Device' -Attribute @{'Description'='new device testing'}
Create a new device

.EXAMPLE
New-TppObject -Path '\VED\Policy\Test Device' -Class 'Device' -Attribute @{'Description'='new device testing'} -PassThru
Create a new device and return the resultant object

.EXAMPLE
New-TppObject -Path '\VED\Policy\Test Device\App' -Class 'Basic' -Attribute @{'Driver Name'='appbasic';'Certificate'='\Ved\Policy\mycert.com'}
Create a new Basic application and associate it to a device and certificate

.INPUTS
none

.OUTPUTS
TppObject, if PassThru provided

.LINK
http://VenafiPS.readthedocs.io/en/latest/functions/New-TppObject/

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/New-TppObject.ps1

.LINK
https://github.com/Venafi/VenafiPS/blob/main/VenafiPS/Public/Add-TppCertificateAssociation.ps1

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/r-SDK-POST-Config-create.php

.LINK
https://docs.venafi.com/Docs/current/TopNav/Content/SDK/WebSDK/SchemaReference/r-SDK-CNattributesWhere.php

#>
function New-TppObject {

    [CmdletBinding(DefaultParameterSetName = 'NonApplicationObject', SupportsShouldProcess)]
    [OutputType([TppObject])]

    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if ( $_ | Test-TppDnPath ) {
                    $true
                }
                else {
                    throw "'$_' is not a valid DN path"
                }
            })]
        [string] $Path,

        [Parameter(Mandatory)]
        [String] $Class,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Hashtable] $Attribute,

        [Parameter()]
        [Alias('ProvisionCertificate')]
        [switch] $PushCertificate,

        [Parameter()]
        [switch] $PassThru,

        [Parameter()]
        [VenafiSession] $VenafiSession = $script:VenafiSession
    )

    $VenafiSession.Validate('TPP')

    # ensure the object doesn't already exist
    # if ( Test-TppObject -Path $Path -ExistOnly -VenafiSession $VenafiSession ) {
    #     throw ("New object to be created, {0}, already exists" -f $Path)
    # }

    # ensure the parent folder exists
    # if ( -not (Test-TppObject -Path (Split-Path -Path $Path -Parent) -ExistOnly -VenafiSession $VenafiSession) ) {
    #     throw ("The parent folder, {0}, of your new object does not exist" -f (Split-Path -Path $Path -Parent))
    # }

    if ( $PushCertificate.IsPresent -and (-not $Attribute.Certificate) ) {
        Write-Warning 'A ''Certificate'' key containing the certificate path must be provided for Attribute when using PushCertificate, eg. -Attribute @{''Certificate''=''\Ved\Policy\mycert.com''}.  Certificate provisioning will not take place.'
    }

    $params = @{
        VenafiSession = $VenafiSession
        Method     = 'Post'
        UriLeaf    = 'config/create'
        Body       = @{
            ObjectDN = $Path
            Class    = $Class
        }
    }

    if ( $PSBoundParameters.ContainsKey('Attribute') ) {
        # api requires a list of hashtables for nameattributelist
        # with 2 items per hashtable, with key names 'name' and 'value'
        # this is cumbersome for the user so allow them to pass a standard hashtable and convert it for them
        $updatedAttribute = @($Attribute.GetEnumerator() | ForEach-Object { @{'Name' = $_.name; 'Value' = $_.value } })
        $params.Body.Add('NameAttributeList', $updatedAttribute)
    }

    if ( $PSCmdlet.ShouldProcess($Path, ('Create {0} Object' -f $Class)) ) {

        $response = Invoke-TppRestMethod @params

        if ( $response.Result -ne [TppConfigResult]::Success ) {
            Throw $response.Error
        }

        Write-Verbose "Successfully created $Class at $Path"

        if ( $Attribute.Certificate ) {
            $associateParams = @{
                CertificatePath = $Attribute.Certificate
                ApplicationPath = $response.Object.DN
            }
            if ( $PushCertificate.IsPresent ) {
                $associateParams.Add('PushCertificate', $true)
            }

            Add-TppCertificateAssociation @associateParams -VenafiSession $VenafiSession
        }

        if ( $PassThru ) {

            $object = $response.Object

            [TppObject] @{
                Name     = $object.Name
                TypeName = $object.TypeName
                Path     = $object.DN
                Guid     = $object.Guid
            }
        }
    }
}
