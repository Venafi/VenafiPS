function Invoke-VenafiRestMethod {
    <#
    .SYNOPSIS
    Ability to execute REST API calls which don't exist in a dedicated function yet

    .DESCRIPTION
    Ability to execute REST API calls which don't exist in a dedicated function yet

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
    Invoke-VenafiRestMethod -Method Delete -UriLeaf 'Discovery/{1345311e-83c5-4945-9b4b-1da0a17c45c6}'
    Api call

    .EXAMPLE
    Invoke-VenafiRestMethod -Method Post -UriLeaf 'Certificates/Revoke' -Body @{'CertificateDN'='\ved\policy\mycert.com'}
    Api call with optional payload

    #>

    [CmdletBinding(DefaultParameterSetName = 'Session')]
    [Alias('Invoke-TppRestMethod')]

    param (
        [Parameter(ParameterSetName = 'Session')]
        [AllowNull()]
        [Alias('Key', 'AccessToken')]
        [psobject] $VenafiSession = $script:VenafiSession,

        [Parameter(Mandatory, ParameterSetName = 'URL')]
        [ValidateNotNullOrEmpty()]
        [Alias('ServerUrl')]
        [String] $Server,

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


    if ( $PSCmdLet.ParameterSetName -eq 'Session' ) {

        if ( -not $VenafiSession ) {
            if ( $env:TPP_TOKEN ) {
                $VenafiSession = $env:TPP_TOKEN
            } elseif ( $env:VAAS_KEY ) {
                $VenafiSession = $env:VAAS_KEY
            } else {
                throw 'Please run New-VenafiSession or provide a VaaS key or TPP token.'
            }
        }

        switch ($VenafiSession.GetType().Name) {
            'VenafiSession' {
                $Server = $VenafiSession.Server
                if ( $VenafiSession.Platform -eq 'VaaS' ) {
                    $platform = 'VaaS'
                    $auth = $VenafiSession.Key.GetNetworkCredential().password
                } else {
                    # TPP
                    if ( $VenafiSession.AuthType -eq 'Token' ) {
                        $platform = 'TppToken'
                        $auth = $VenafiSession.Token.AccessToken.GetNetworkCredential().password
                    } else {
                        $platform = 'TppKey'
                        $auth = $VenafiSession.Key.ApiKey
                    }
                }
                break
            }

            'String' {
                $auth = $VenafiSession
                $objectGuid = [System.Guid]::empty
                if ( [System.Guid]::TryParse($VenafiSession, [System.Management.Automation.PSReference]$objectGuid) ) {
                    $Server = $script:CloudUrl
                    $platform = 'VaaS'
                } else {
                    # TPP access token
                    # get server from environment variable
                    if ( -not $env:TPP_SERVER ) {
                        throw 'TPP_SERVER environment variable was not found'
                    }
                    $Server = $env:TPP_SERVER
                    if ( $Server -notlike 'https://*') {
                        $Server = 'https://{0}' -f $Server
                    }
                    $platform = 'TppToken'
                }
            }

            Default {
                throw "Unknown session '$VenafiSession'.  Please run New-VenafiSession or provide a VaaS key or TPP token."
            }
        }

        switch ($platform) {
            'VaaS' {
                $hdr = @{
                    "tppl-api-key" = $auth
                }
                if ( -not $PSBoundParameters.ContainsKey('UriRoot') ) {
                    $UriRoot = 'v1'
                }
            }

            'TppToken' {
                $hdr = @{
                    'Authorization' = 'Bearer {0}' -f $auth
                }
            }

            'TppKey' {
                $hdr = @{
                    "X-Venafi-Api-Key" = $auth
                }
            }

            Default {}
        }
    }

    $uri = '{0}/{1}/{2}' -f $Server, $UriRoot, $UriLeaf

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
                $restBody = ConvertTo-Json $Body -Depth 20 -Compress
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
    } catch {

        # if trying with a slash below doesn't work, we want to provide the original error
        $originalError = $_
        $originalStatusCode = $originalError.Exception.Response.StatusCode.value__

        Write-Verbose ('Response status code {0}' -f $originalStatusCode)

        if ( $originalStatusCode -eq '409' ) {
            # item already exists.  some functions use this for a 'force' option, eg. Set-TppPermission
            # treat this as non error
            $response = $_.Exception.Response
        } else {
            throw $_
        }

    } finally {
        $ProgressPreference = $oldProgressPreference
    }

    if ( $FullResponse ) {
        $response
    } else {
        if ( $response.Content ) {
            try {
                $response.Content | ConvertFrom-Json
            } catch {
                throw ('Invalid JSON response {0}' -f $response.Content)
            }
        }
    }
}