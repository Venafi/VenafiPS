<#
.SYNOPSIS
Remove sensitive information when writing verbose info

.DESCRIPTION
Remove sensitive information when writing verbose info

.PARAMETER InputObject
JSON string or other object

.PARAMETER SecretName
Name of secret(s) to hide their values.  Default value is 'Password', 'AccessToken', 'RefreshToken', 'access_token', 'refresh_token', 'Authorization', 'KeystorePassword', 'tppl-api-key', 'CertficateData'

.INPUTS
InputObject

.OUTPUTS
None

.EXAMPLE
@{'password'='foobar'} | Write-VerboseWithSecret
Hide password value from hashtable

.EXAMPLE
$jsonString | Write-VerboseWithSecret
Hide value(s) from JSON string

#>
function Write-VerboseWithSecret {

    [CmdletBinding()]

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyString()]
        [psobject] $InputObject,

        [Parameter()]
        [string[]] $PropertyName = @('AccessToken', 'Password', 'RefreshToken', 'access_token', 'refresh_token', 'Authorization', 'KeystorePassword', 'tppl-api-key', 'CertificateData')
    )

    begin {
    }

    process {

        if ( -not $InputObject -or [System.Management.Automation.ActionPreference]::SilentlyContinue -eq $VerbosePreference ) {
            return
        }

        Write-Debug ('Write-VerboseWithSecret input type: {0}' -f $InputObject.GetType().FullName)

        # default to json string
        $processMe = $InputObject
        if ($InputObject.GetType().FullName -ne 'System.String') {
            # if hashtable or other object, convert to json first
            $processMe = $InputObject | ConvertTo-Json -Depth 5
        }

        foreach ($prop in $PropertyName) {
            # look for secret name and replace value if found

            # look for values in multiline json string, eg. "Body": "{\r\n  \"Password\": \"MyPass\"\r\n}"
            # look for values in standard key:value pair, eg. "Authorization": "Bearer adflkjandsfsmmmsdfkhsdf=="
            # PS v5 has 2 spaces between "key":  "value"
            # PS v7 has 1 space between "key": "value"
            if ( $processMe -match "(?s).*\\{0,1}""$prop\\{0,1}"": {1,2}\\{0,1}""(.*?)\\{0,1}"".*" ) {
                $secret = $processMe -replace "(?s).*\\{0,1}""$prop\\{0,1}"": {1,2}\\{0,1}""(.*?)\\{0,1}"".*", '$1'
                $processMe = ($processMe.replace($secret, '***hidden***'))
            }
        }

        Write-Verbose $processMe

    }
}