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
        [switch] $FullResponse,

        [Parameter()]
        [switch] $SkipCertificateCheck
    )


    if ( $PSCmdLet.ParameterSetName -eq 'Session' ) {

        if ( -not $VenafiSession ) {
            if ( $env:TPP_TOKEN ) {
                $VenafiSession = $env:TPP_TOKEN
            }
            elseif ( $env:VAAS_KEY ) {
                $VenafiSession = $env:VAAS_KEY
            }
            else {
                throw 'Please run New-VenafiSession or provide a VaaS key or TPP token.'
            }
        }

        switch ($VenafiSession.GetType().Name) {
            'VenafiSession' {
                $Server = $VenafiSession.Server
                if ( $VenafiSession.Platform -eq 'VaaS' ) {
                    $platform = 'VaaS'
                    $auth = $VenafiSession.Key.GetNetworkCredential().password
                }
                else {
                    # TPP
                    if ( $VenafiSession.AuthType -eq 'Token' ) {
                        $platform = 'TppToken'
                        $auth = $VenafiSession.Token.AccessToken.GetNetworkCredential().password
                    }
                    else {
                        $platform = 'TppKey'
                        $auth = $VenafiSession.Key.ApiKey
                    }
                }
                $SkipCertificateCheck = $VenafiSession.SkipCertificateCheck
                break
            }

            'String' {
                $auth = $VenafiSession
                $objectGuid = [System.Guid]::empty
                if ( [System.Guid]::TryParse($VenafiSession, [System.Management.Automation.PSReference]$objectGuid) ) {
                    $Server = $script:CloudUrl
                    $platform = 'VaaS'
                }
                else {
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
                $allHeaders = @{
                    "tppl-api-key" = $auth
                }
                if ( -not $PSBoundParameters.ContainsKey('UriRoot') ) {
                    $UriRoot = 'v1'
                }
            }

            'TppToken' {
                $allHeaders = @{
                    'Authorization' = 'Bearer {0}' -f $auth
                }
            }

            'TppKey' {
                $allHeaders = @{
                    "X-Venafi-Api-Key" = $auth
                }
            }

            Default {}
        }
    }

    $uri = '{0}/{1}/{2}' -f $Server, $UriRoot, $UriLeaf

    $params = @{
        Method          = $Method
        Uri             = $uri
        ContentType     = 'application/json'
        UseBasicParsing = $true
    }

    # append any headers passed in
    if ( $Header ) { $allHeaders += $Header }
    # if there are any headers, add to the rest payload
    # in the case of inital authentication, eg, there won't be any
    if ( $allHeaders ) { $params.Headers = $allHeaders }

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

    if ( $SkipCertificateCheck -or $env:VENAFIPS_SKIP_CERT_CHECK -eq '1' ) {
        if ( $PSVersionTable.PSVersion.Major -lt 6 ) {
            if ( [System.Net.ServicePointManager]::CertificatePolicy.GetType().FullName -ne 'TrustAllCertsPolicy' ) {
                add-type @"
                using System.Net;
                using System.Security.Cryptography.X509Certificates;
                public class TrustAllCertsPolicy : ICertificatePolicy {
                    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {
                        return true;
                    }
                }
"@
                [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
            }
        }
        else {
            $params.Add('SkipCertificateCheck', $true)
        }
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

        $statusCode = [int]$originalError.Exception.Response.StatusCode
        Write-Verbose ('Response status code {0}' -f $statusCode)

        switch ($statusCode) {
            403 {

                $permMsg = ''

                # get scope details for tpp
                if ( $platform -ne 'VaaS' ) {
                    $callingFunction = @(Get-PSCallStack)[1].InvocationInfo.MyCommand.Name
                    $callingFunctionScope = ($script:functionConfig).$callingFunction.TppTokenScope
                    if ( $callingFunctionScope ) { $permMsg += "$callingFunction requires a token scope of $callingFunctionScope." }

                    $rejectedScope = (Select-String -InputObject $originalError.ErrorDetails.Message -Pattern 'Grant rejected scope ''(.*)''').matches.groups[1].value
                    if ( $rejectedScope ) { $permMsg += "  The current scope of $rejectedScope is insufficient.`r`n`r`n" }
                }

                $permMsg += $originalError.ErrorDetails.Message

                throw $permMsg
            }

            409 {
                # 409 = item already exists.  some functions use this for a 'force' option, eg. Set-TppPermission
                # treat this as non error/exception if FullResponse provided
                if ( $FullResponse ) {
                    $response = [pscustomobject] @{
                        StatusCode = $statusCode
                        Error      =
                        try {
                            $originalError.ErrorDetails.Message | ConvertFrom-Json
                        }
                        catch {
                            $originalError.ErrorDetails.Message
                        }
                    }
                }
                else {
                    throw $originalError
                }
            }

            Default {
                throw $originalError
            }
        }

    }
    finally {
        $ProgressPreference = $oldProgressPreference
    }

    if ( $FullResponse ) {
        $response
    }
    else {
        if ( $response.Content ) {
            try {
                $response.Content | ConvertFrom-Json
            }
            catch {
                throw ('Invalid JSON response {0}' -f $response.Content)
            }
        }
    }
}