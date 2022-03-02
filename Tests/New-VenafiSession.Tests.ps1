BeforeAll {
    Remove-Module 'VenafiPS' -Force -ErrorAction SilentlyContinue
    Import-Module ./VenafiPS/VenafiPS.psd1
}
Describe 'New-VenafiSession' {
    BeforeAll {
        $cred = New-Object System.Management.Automation.PSCredential('AccessToken', ('9655b66c-8e5e-4b2b-b43e-edfa33b70e5f' | ConvertTo-SecureString -AsPlainText -Force))
    }
    Context 'VaaS key' {
        BeforeAll {
            $sess = New-VenafiSession -VaasKey $cred -PassThru
        }
        It 'should set platform to VaaS' {
            $sess.Platform | Should -Be 'VaaS'
        }
        It 'should set AuthType to Key' {
            $sess.AuthType | Should -Be 'Key'
        }
        It 'should set key to the credential provided' {
            $sess.Key | Should -Be $cred
        }
    }

}
