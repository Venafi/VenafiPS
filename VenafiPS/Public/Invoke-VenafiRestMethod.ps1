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
        [switch] $UseDefaultCredentials,

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
        Method      = $Method
        Uri         = $uri
        Headers     = $hdr
        ContentType = 'application/json'
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

    if ( $UseDefaultCredentials ) {
        $params.Add('UseDefaultCredentials', $true)
    }

    $params | Write-VerboseWithSecret

    # $verboseOutput = $($response = Invoke-WebRequest @params) 4>&1
    try {
        # return Invoke-WebRequest @params
        
        $oldProgressPreference = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'

        $verboseOutput = $($response = Invoke-WebRequest @params) 4>&1

        $ProgressPreference = $oldProgressPreference

        # $verboseOutput = $($response = Invoke-RestMethod @params) 4>&1
        $verboseOutput.Message | Write-VerboseWithSecret

        # switch ($Response.StatusCode) {

        #     '409' {
        #         # item already exists.  some functions use this for a 'force' option, eg. Set-TppPermission
        #         $response = $originalError.Exception.Response
        #     }

        #     { $_ -in '307', '401' } {
        #         # try with trailing slash as some GETs return a 307/401 without it
        #         if ( -not $uri.EndsWith('/') ) {

        #             Write-Verbose "$Method call failed, trying again with a trailing slash"

        #             $params.Uri += '/'

        #             try {
        #                 $verboseOutput = $($response = Invoke-WebRequest @params) 4>&1
        #                 $verboseOutput.Message | Write-VerboseWithSecret
        #                 Write-Warning ('{0} call requires a trailing slash, please create an issue at https://github.com/gdbarron/VenafiPS/issues and mention api endpoint {1}' -f $Method, ('{1}/{2}' -f $UriRoot, $UriLeaf))
        #             }
        #             catch {
        #                 # this didn't work, provide details from pre slash call
        #                 throw $originalError
        #             }
        #         }
        #     }

        #     Default {
        #     }
        # }

    }
    catch {

        # if trying with a slash below doesn't work, we want to provide the original error
        $originalError = $_

        Write-Verbose ('Response status code in catch {0}' -f $originalError.Exception.Response.StatusCode.value__)

        switch ($originalError.Exception.Response.StatusCode.value__) {

            '409' {
                # item already exists.  some functions use this for a 'force' option, eg. Set-TppPermission
                $response = $originalError.Exception.Response
            }

            { $_ -in '307', '401' } {
                # try with trailing slash as some GETs return a 307/401 without it
                if ( -not $uri.EndsWith('/') ) {

                    Write-Verbose "$Method call failed, trying again with a trailing slash"

                    $params.Uri += '/'

                    try {
                        $response = Invoke-WebRequest @params
                        # $verboseOutput = $($response = Invoke-WebRequest @params) 4>&1
                        $verboseOutput.Message | Write-VerboseWithSecret
                        Write-Warning ('{0} call requires a trailing slash, please create an issue at https://github.com/gdbarron/VenafiPS/issues and mention api endpoint {1}' -f $Method, ('{1}/{2}' -f $UriRoot, $UriLeaf))
                    }
                    catch {
                        # this didn't work, provide details from pre slash call
                        throw $originalError
                    }
                }
            }

            Default {
                throw ('"{0} {1}: {2}' -f $originalError.Exception.Response.StatusCode.value__, $originalError.Exception.Response.StatusDescription, $originalError | Out-String )
            }
        }
    }

    if ( $FullResponse.IsPresent ) {
        $response
    }
    else {
        $response.Content | ConvertFrom-Json
    }
}