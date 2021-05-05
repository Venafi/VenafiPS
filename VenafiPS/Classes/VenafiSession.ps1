class VenafiSession {

    [string] $ServerUrl
    [datetime] $Expires
    [PSCustomObject] $Key
    [PSCustomObject] $Token
    [PSCustomObject] $CustomField
    [string] $Version

    VenafiSession () {
    }

    VenafiSession ([Hashtable] $initHash) {
        $this._init($initHash)
    }

    [string] Validate() {
        return $this.Validate(($this | Get-VenafiAuthType))
    }

    # AuthType can be key, token or vaas
    # key is TPP and all functions
    # token is TPP and some functions require it
    # vaas is Venafi as a Service

    # return $AuthType so functions know what we're working with
    [string] Validate(
        [string] $AuthType
    ) {

        if ( -not $this.Key -and -not $this.Token ) {
            switch ($AuthType) {
                'vaas' {
                    throw "You must first connect to Venafi as a Service with New-VenafiSession -VaasKey"
                }

                Default {
                    throw "You must first connect to the TPP server with New-VenafiSession"
                }
            }

        }

        # newer api calls may only accept token based auth
        if ( $AuthType -eq 'token' -and -not $this.Token ) {
            throw "This function requires the use of token-based authentication"
        }

        # make sure the auth type and url we have match
        # this keeps folks from calling a vaas function with a token and vice versa
        if ( $AuthType -eq 'vaas' ) {
            if ( $this.ServerUrl -ne $script:CloudUrl ) {
                throw 'This function is only accessible for Venafi as a Service, not TPP'
            }
        } else {
            if ( $this.ServerUrl -eq $script:CloudUrl ) {
                throw 'This function is only accessible for TPP, not Venafi as a Service'
            }
        }

        # if we know the session is still valid, don't bother checking with the server
        # add a couple of seconds so we don't get caught making the call as it expires
        Write-Verbose ("Expires: {0}, Current (+2s): {1}" -f $this.Expires, (Get-Date).ToUniversalTime().AddSeconds(2))
        if ( $this.Expires -lt (Get-Date).ToUniversalTime().AddSeconds(2) ) {
            if ( $this.Key ) {

                try {
                    $params = @{
                        Method      = 'Get'
                        Uri         = ("{0}/vedsdk/authorize/checkvalid" -f $this.ServerUrl)
                        Headers     = @{
                            "X-Venafi-Api-Key" = $this.Key.ApiKey
                        }
                        ContentType = 'application/json'
                    }
                    Invoke-RestMethod @params
                } catch {
                    # tpp sessions timeout after 3 mins of inactivity
                    # reestablish connection
                    if ( $_.Exception.Response.StatusCode.value__ -eq '401' ) {
                        Write-Verbose "Unauthorized, re-authenticating"
                        if ( $this.Key.Credential ) {
                            $this.Connect($this.Key.Credential)
                        } else {
                            $this.Connect($null)
                        }
                    } else {
                        throw ('"{0} {1}: {2}' -f $_.Exception.Response.StatusCode.value__, $_.Exception.Response.StatusDescription, $_ | Out-String )
                    }
                }
            } else {
                # token
                # By default, access tokens are long-lived (90 day default). Refreshing the token should be handled outside of this class, so that the
                #  refresh token and access token can be properly maintained and passed to the script.

                # We have to assume a good token here and ensure Invoke-TPPRestMethod catches and handles the condition where a token expires
            }
        }
        return $AuthType
    }

    # connect for key based
    [void] Connect(
        [PSCredential] $Credential
    ) {
        if ( -not ($this.ServerUrl) ) {
            throw "You must provide a value for ServerUrl"
        }

        $params = @{
            ServerUrl = $this.ServerUrl
        }

        if ( $Credential ) {
            $params.Method = 'Post'
            $params.UriLeaf = 'authorize'
            $params.Body = @{
                Username = $Credential.UserName
                Password = $Credential.GetNetworkCredential().Password
            }
        } else {
            $params.Method = 'Get'
            $params.UriLeaf = 'authorize/integrated'
            $params.UseDefaultCredentials = $true
        }

        $response = Invoke-TppRestMethod @params
        $this.Expires = $response.ValidUntil
        $this.Key = [pscustomobject] @{
            ApiKey     = $response.ApiKey
            Credential = $Credential
        }
    }

    hidden [void] _init ([Hashtable] $initHash) {

        if ( -not ($initHash.ServerUrl) ) {
            throw "ServerUrl is required"
        }

        $this.ServerUrl = $initHash.ServerUrl
        if ( $initHash.Credential ) {
            $this.Credential = $initHash.Credential
        }
        $this.CustomField = $null
    }
}

