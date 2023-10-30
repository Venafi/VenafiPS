BeforeAll {
    Remove-Module 'VenafiPS' -Force -ErrorAction SilentlyContinue
    Import-Module ./VenafiPS/VenafiPS.psd1
}
Describe 'New-VenafiSession' {
    BeforeAll {
        $cred = New-Object System.Management.Automation.PSCredential('AccessToken', ('9655b66c-8e5e-4b2b-b43e-edfa33b70e5f' | ConvertTo-SecureString -AsPlainText -Force))
    }
    Context 'TLSPC key' {
        # BeforeAll {
        #     Mock New-VenafiSession -MockWith {
        #         $newSession = [VenafiSession] @{
        #             Server = 'https://api.venafi.cloud'
        #         }
        #         $newSession.AuthType = 'Key'
        #         $newSession.Key = $cred
        #         $newSession
        #     }
        #     $sess = New-VenafiSession -VaasKey $cred -PassThru
        # }
        # It 'should set platform to TLSPC' {
        #     $sess.Platform | Should -Be 'TLSPC'
        # }
        # It 'should set AuthType to Key' {
        #     $sess.AuthType | Should -Be 'Key'
        # }
        # It 'should set Server url' {
        #     $sess.Server | Should -Be 'https://api.venafi.cloud'
        # }
        # It 'should set key to the credential provided' {
        #     $sess.Key | Should -Be $cred
        # }
    }

}
