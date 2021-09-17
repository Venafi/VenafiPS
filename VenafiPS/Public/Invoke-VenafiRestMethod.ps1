<#
.SYNOPSIS
Generic REST API call

.DESCRIPTION
Generic REST API call

.PARAMETER VenafiSession
VenafiSession object from New-VenafiSession.
For typical calls to New-VenafiSession, the object will be stored as a session object named $VenafiSession.
Otherwise, if -PassThru was used, provide the resulting object.

.PARAMETER Method
API method, either get, post, patch, put or delete.

.PARAMETER UriLeaf
Path to the api endpoint excluding the base url and site, eg. certificates/import

.PARAMETER Header
Optional additional headers.  The authorization header will be included automatically.

.PARAMETER Body
Optional body to pass to the endpoint

.INPUTS
None

.OUTPUTS
PSCustomObject

.EXAMPLE

#>
function Invoke-VenafiRestMethod {
    [CmdletBinding(DefaultParameterSetName = 'Session')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Session')]
        [ValidateNotNullOrEmpty()]
        [VenafiSession] $VenafiSession,

        [Parameter(Mandatory, ParameterSetName = 'URL')]
        [ValidateNotNullOrEmpty()]
        [String] $ServerUrl,

        [Parameter(ParameterSetName = 'URL')]
        [Alias('UseDefaultCredentials')]
        [switch] $UseDefaultCredential,

        [Parameter(ParameterSetName = 'URL')]
        [X509Certificate] $Certificate,

        [Parameter()]
        [ValidateSet("Get", "Post", "Patch", "Put", "Delete", 'Head')]
        [String] $Method = 'Get',

        [Parameter()]
        [String] $UriRoot = 'vedsdk',

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $UriLeaf,

        [Parameter()]
        [hashtable] $Header,

        [Parameter()]
        [Hashtable] $Body,

        [Parameter()]
        [switch] $FullResponse
    )

    switch ($PSCmdLet.ParameterSetName) {
        'Session' {
            $ServerUrl = $VenafiSession.ServerUrl

            switch ($VenafiSession | Get-VenafiAuthType) {
                'key' {
                    $hdr = @{
                        "X-Venafi-Api-Key" = $VenafiSession.Key.ApiKey
                    }
                }
                'token' {
                    $hdr = @{
                        'Authorization' = 'Bearer {0}' -f $VenafiSession.Token.AccessToken.GetNetworkCredential().password
                    }
                }
                'vaas' {
                    $hdr = @{
                        "tppl-api-key" = $VenafiSession.Key.GetNetworkCredential().password
                    }
                }
                Default {}
            }

            $uri = '{0}/{1}/{2}' -f $ServerUrl, $UriRoot, $UriLeaf

        }

        'URL' {
            $uri = '{0}/{1}/{2}' -f $ServerUrl, $UriRoot, $UriLeaf
        }

        Default {}
    }


    if ( $Header ) {
        $hdr += $Header
    }

    $params = @{
        Method          = $Method
        Uri             = $uri
        Headers         = $hdr
        ContentType     = 'application/json'
        UseBasicParsing = $true
    }

    if ( $Body ) {
        $restBody = $Body
        switch ($Method.ToLower()) {
            'head' {
                # a head method requires the params be provided as a query string, not body
                # invoke-webrequest does not do this so we have to build the string manually
                $newUri = New-HttpQueryString -Uri $uri -QueryParameter $Body
                $params.Uri = $newUri
                $params.Body = $null
                Write-Verbose $newUri
            }

            'get' {
                $params.Body = $restBody
            }

            Default {
                $restBody = ConvertTo-Json $Body -Depth 20
                $params.Body = $restBody
            }
        }
    }

    if ( $UseDefaultCredential.IsPresent -and $Certificate ) {
        throw 'You cannot use UseDefaultCredential and Certificate parameters together'
    }

    if ( $UseDefaultCredential.IsPresent ) {
        $params.Add('UseDefaultCredentials', $true)
    }

    $params | Write-VerboseWithSecret

    # ConvertTo-Json, used in Write-VerboseWithSecret, has an issue with certificates
    # add this param after
    if ( $Certificate ) {
        $params.Add('Certificate', $Certificate)
    }

    $oldProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'

    try {
        $verboseOutput = $($response = Invoke-WebRequest @params -ErrorAction Stop) 4>&1
        $verboseOutput.Message | Write-VerboseWithSecret
    }
    catch {

        # if trying with a slash below doesn't work, we want to provide the original error
        $originalError = $_
        $originalStatusCode = $originalError.Exception.Response.StatusCode.value__

        Write-Verbose ('Response status code {0}' -f $originalStatusCode)

        switch ($originalStatusCode) {

            '409' {
                # item already exists.  some functions use this for a 'force' option, eg. Set-TppPermission
                $response = $originalError.Exception.Response
            }

            { $_ -in '307', '401' } {
                # try with trailing slash as some GETs return a 307/401 without it
                if ( -not $uri.EndsWith('/') ) {

                    Write-Verbose "'$Method' call failed, trying again with a trailing slash"

                    $params.Uri += '/'

                    try {
                        $verboseOutput = $($response = Invoke-WebRequest @params -ErrorAction Stop) 4>&1
                        $verboseOutput.Message | Write-VerboseWithSecret
                        Write-Warning ('This ''{0}'' call requires a trailing slash, please create an issue at https://github.com/gdbarron/VenafiPS/issues and mention api endpoint {1}' -f $Method, ('{0}/{1}' -f $UriRoot, $UriLeaf))
                    }
                    catch {
                        # this didn't work, provide details from pre slash call
                        throw ('"{0} : {1}' -f $originalStatusCode, $originalError | Out-String )
                    }
                }
            }

            Default {
                throw ('"{0} : {1}' -f $originalStatusCode, $originalError | Out-String )
            }
        }
    }
    finally {
        $ProgressPreference = $oldProgressPreference
    }

    if ( $FullResponse.IsPresent ) {
        $response
    }
    else {
        if ( $response.Content ) {
            $response.Content | ConvertFrom-Json
        }
    }
}