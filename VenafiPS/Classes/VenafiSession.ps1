class VenafiSession {

    [string] $ServerUrl
    # [datetime] $Expires
    [PSCustomObject] $Key
    [PSCustomObject] $Token
    [PSCustomObject] $CustomField
    [Version] $Version

    VenafiSession () {
    }

    VenafiSession ([Hashtable] $initHash) {
        $this._init($initHash)
    }

    [void] Validate() {
        $this.Validate($this.Platform, $this.AuthType)
    }

    [void] Validate(
        [string] $Platform
    ) {
        $this.Validate($Platform, $this.AuthType)
    }

    [void] Validate(
        [string] $Platform,
        [string] $AuthType
    ) {

        if ( -not $this.Key -and -not $this.Token ) {
            switch ($Platform) {
                'VaaS' {
                    throw "You must first connect to Venafi as a Service with New-VenafiSession -VaasKey"
                }

                'TPP' {
                    throw "You must first connect to a TPP server with New-VenafiSession"
                }

                Default {
                    throw "You must first connect to either Venafi as a Service or a TPP server with New-VenafiSession"
                }
            }
        }

        # newer api calls may only accept token based auth
        if ( $AuthType -ne $this.AuthType ) {
            throw "This function requires the use of $AuthType authentication"
        }

        # make sure the auth type and url we have match
        # this keeps folks from calling a vaas function with a token and vice versa
        if ( $Platform -ne $this.Platform ) {
            throw "This function is only accessible for $Platform"
        }

        Write-Verbose ("Key/Token expires: {0}, Current (+2s): {1}" -f $this.Expires, (Get-Date).ToUniversalTime().AddSeconds(2))
        if ( $this.Expires -gt (Get-Date).ToUniversalTime().AddSeconds(2) ) {
            return
        }

        # expired, perform refresh
        Write-Verbose 'Key/token expired.  Attempting refresh.'

        if ( $this.Platform -eq 'TPP' ) {
            if ( $this.AuthType -eq 'Key' ) {
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
                }
                catch {
                    # tpp sessions timeout after 3 mins of inactivity
                    # reestablish connection
                    if ( $_.Exception.Response.StatusCode.value__ -eq '401' ) {
                        Write-Verbose "Unauthorized, re-authenticating"
                        if ( $this.Key.Credential ) {
                            $this.Connect($this.Key.Credential)
                        }
                        else {
                            $this.Connect($null)
                        }
                    }
                    else {
                        throw ('"{0} {1}: {2}' -f $_.Exception.Response.StatusCode.value__, $_.Exception.Response.StatusDescription, $_ | Out-String )
                    }
                }
            }
            else {
                # token
                if ( $this.Token.RefreshExpires ) {
                    Write-Verbose ("Refresh token expires: {0}, Current: {1}" -f $this.Token.RefreshExpires, (Get-Date).ToUniversalTime())
                }

                $newToken = New-TppToken -VenafiSession $this
                $this.Token = $newToken
                # $this.Expires = $newToken.Expires
            }
        } else {
            # no refresh for vaas
        }
    }

    # AuthType can be key, token or vaas
    # key is TPP and all functions
    # token is TPP and some functions require it
    # tpp is key or token for tpp
    # vaas is Venafi as a Service

    # return $AuthType so functions know what we're working with
    # [string] Validate(
    #     [string] $AuthType
    # ) {

    #     if ( -not $this.Key -and -not $this.Token ) {
    #         switch ($AuthType) {
    #             'vaas' {
    #                 throw "You must first connect to Venafi as a Service with New-VenafiSession -VaasKey"
    #             }

    #             'tpp' {
    #                 throw "You must first connect to a TPP server with New-VenafiSession"
    #             }

    #             Default {
    #                 throw "You must first connect to either Venafi as a Service or a TPP server with New-VenafiSession"
    #             }
    #         }

    #     }

    #     # newer api calls may only accept token based auth
    #     if ( $AuthType -eq 'token' -and -not $this.Token ) {
    #         throw "This function requires the use of token-based authentication"
    #     }

    #     # make sure the auth type and url we have match
    #     # this keeps folks from calling a vaas function with a token and vice versa
    #     if ( $AuthType -eq 'vaas' ) {
    #         if ( $this.ServerUrl -ne $script:CloudUrl ) {
    #             throw 'This function is only accessible for Venafi as a Service, not TPP'
    #         }
    #     }
    #     else {
    #         if ( $this.ServerUrl -eq $script:CloudUrl ) {
    #             throw 'This function is only accessible for TPP, not Venafi as a Service'
    #         }
    #     }

    #     # if we know the session is still valid, don't bother checking with the server
    #     # add a couple of seconds so we don't get caught making the call as it expires
    #     Write-Verbose ("Key/Token expires: {0}, Current (+2s): {1}" -f $this.Expires, (Get-Date).ToUniversalTime().AddSeconds(2))
    #     if ( $this.Expires -gt (Get-Date).ToUniversalTime().AddSeconds(2) ) {
    #         return $AuthType
    #     }

    #     # expired, perform refresh
    #     Write-Verbose 'Key/token expired.  Attempting refresh.'

    #     switch ( $AuthType ) {
    #         'key' {

    #             try {
    #                 $params = @{
    #                     Method      = 'Get'
    #                     Uri         = ("{0}/vedsdk/authorize/checkvalid" -f $this.ServerUrl)
    #                     Headers     = @{
    #                         "X-Venafi-Api-Key" = $this.Key.ApiKey
    #                     }
    #                     ContentType = 'application/json'
    #                 }
    #                 Invoke-RestMethod @params
    #             }
    #             catch {
    #                 # tpp sessions timeout after 3 mins of inactivity
    #                 # reestablish connection
    #                 if ( $_.Exception.Response.StatusCode.value__ -eq '401' ) {
    #                     Write-Verbose "Unauthorized, re-authenticating"
    #                     if ( $this.Key.Credential ) {
    #                         $this.Connect($this.Key.Credential)
    #                     }
    #                     else {
    #                         $this.Connect($null)
    #                     }
    #                 }
    #                 else {
    #                     throw ('"{0} {1}: {2}' -f $_.Exception.Response.StatusCode.value__, $_.Exception.Response.StatusDescription, $_ | Out-String )
    #                 }
    #             }
    #         }

    #         'token' {
    #             if ( $this.Token.RefreshExpires ) {
    #                 Write-Verbose ("Refresh token expires: {0}, Current: {1}" -f $this.Token.RefreshExpires, (Get-Date).ToUniversalTime())
    #             }

    #             $newToken = New-TppToken -VenafiSession $this
    #             $this.Token = $newToken
    #             $this.Expires = $newToken.Expires
    #         }

    #         'tpp' {
    #             # handled by key/token above
    #         }

    #         'vaas' {
    #             # nothing yet
    #         }

    #         Default {
    #             throw "Unknown auth type $AuthType"
    #         }
    #     }
    #     return $AuthType
    # }

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
        }
        else {
            $params.Method = 'Get'
            $params.UriLeaf = 'authorize/integrated'
            $params.UseDefaultCredentials = $true
        }

        $response = Invoke-TppRestMethod @params
        # $this.Expires = $response.ValidUntil
        $this.Key = [pscustomobject] @{
            ApiKey     = $response.ApiKey
            Credential = $Credential
            Expires = $response.ValidUntil
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

        $this | Add-Member -MemberType ScriptProperty -Name Platform -Value {
            if ( $this.ServerUrl -eq $script:CloudUrl ) {
                'VaaS'
            }
            else {
                'TPP'
            }
        }

        $this | Add-Member -MemberType ScriptProperty -Name AuthType -Value {
            if ( $this.Key ) {
                'Key'
            }
            elseif ($this.Token ) {
                'Token'
            }
            else {
                $null
            }
        }

        $this | Add-Member -MemberType ScriptProperty -Name Expires -Value {
            if ( $this.Token ) {
                $this.Token.Expires
            }
            elseif ($this.Key ) {
                $this.Key.Expires
            }
            else {
                $null
            }
        }
    }
}

