BeforeAll {
    $script:privateDir = Join-Path $PSScriptRoot '..' '..' 'PSMotd' 'Private'
    $script:publicDir  = Join-Path $PSScriptRoot '..' '..' 'PSMotd' 'Public'
    . (Join-Path $script:privateDir 'Write-MOTD.ps1')
    . (Join-Path $script:publicDir 'Set-MOTDConfig.ps1')
}

Describe 'Write-MOTD does not execute disk-sourced code (RCE regression)' {

    BeforeEach {
        # A hostile config carrying an executable payload, as a pre-fix config
        # file would have. Write-MOTD must NEVER invoke this.
        $env:PSMOTD_RCE_MARKER = Join-Path $TestDrive "rce-$(New-Guid).txt"
        function Get-MOTDConfig {
            @{
                MOTDFrequency   = 'EverySession'
                MOTDScriptBlock = { New-Item -ItemType File -Path $env:PSMOTD_RCE_MARKER -Force | Out-Null }
            }
        }
        function Get-DefaultMessageOfTheDay { 'default-banner' }
        # Ensure no user profile hook interferes with the default path.
        if (Test-Path Function:\Get-MessageOfTheDay) { Remove-Item Function:\Get-MessageOfTheDay -Force }
    }

    AfterEach {
        Remove-Item Env:\PSMOTD_RCE_MARKER -ErrorAction Ignore
    }

    It 'never invokes a MOTDScriptBlock planted in config' {
        Write-MOTD | Out-Null
        Test-Path $env:PSMOTD_RCE_MARKER | Should -BeFalse
    }

    It 'renders the default banner when no Get-MessageOfTheDay hook exists' {
        Write-MOTD | Should -Be 'default-banner'
    }

    It 'uses the user Get-MessageOfTheDay hook when present, still no config code path' {
        function Get-MessageOfTheDay { 'user-hook' }
        try {
            Write-MOTD | Should -Be 'user-hook'
            Test-Path $env:PSMOTD_RCE_MARKER | Should -BeFalse
        } finally {
            Remove-Item Function:\Get-MessageOfTheDay -Force
        }
    }
}

Describe 'Set-MOTDConfig parameter surface (RCE regression)' {

    It 'no longer exposes a -MOTDScriptBlock parameter' {
        (Get-Command Set-MOTDConfig).Parameters.Keys | Should -Not -Contain 'MOTDScriptBlock'
    }

    It '-Frequency is a [string] constrained to the four named cadences' {
        $p = (Get-Command Set-MOTDConfig).Parameters['Frequency']
        $p.ParameterType | Should -Be ([string])
        $set = $p.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }
        $set.ValidValues | Should -Be @('Never', 'EverySession', 'Daily', 'Weekly')
    }
}
