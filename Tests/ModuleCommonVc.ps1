
. $PSScriptRoot/ModuleCommon.ps1

Mock -CommandName 'Get-VenafiSession' -MockWith {
    [pscustomobject]@{
        Platform             = 'VC'
        Server               = 'https://api.venafi.cloud'
        TimeoutSec           = 0
        SkipCertificateCheck = $false
        Key                  = New-Object System.Management.Automation.PSCredential('VcKey', ('c7afbda6-0ae4-43b2-b775-42ab2940ba9e' | ConvertTo-SecureString -AsPlainText -Force))
        User                 = @{
            userId                       = '67d2583d-01ae-405b-bac3-1640c1177211'
            username                     = 'greg.brownstein@cyberark.com'
            companyId                    = '09b24f81-b22b-11ea-91f3-ebd6dea5452e'
            firstname                    = 'Greg'
            lastname                     = 'Brownstein'
            emailAddress                 = 'ggreg.brownstein@cyberark.com'
            userType                     = 'EXTERNAL'
            userAccountType              = 'WEB_UI'
            ssoStatus                    = 'INACTIVE'
            userStatus                   = 'ACTIVE'
            systemRoles                  = '{SYSTEM_ADMIN}'
            productRoles                 = $null
            localLoginDisabled           = $False
            hasPassword                  = $true
            forceLocalPasswordExpiration = $false
            firstLoginDate               = (Get-Date)
            creationDate                 = (Get-Date)
            ownedTeams                   = '{59920180-a3e2-11ec-8dcd-3fcbf84c7da7, 2ff7b010-a967-11ec-86d1-6374f196212d, f397c880-a6cd-11ec-98c8-fb6d4b26eea3, 895f9650-a709-11ec-98c8-fb6d4b26eea3…}'
            memberedTeams                = '{59920180-a3e2-11ec-8dcd-3fcbf84c7da7}'
            disabled                     = $false
            signupAttributes             = $null
        }
    }
} -ModuleName $ModuleName
