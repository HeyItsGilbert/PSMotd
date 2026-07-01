BeforeAll {
    $script:privateDir = Join-Path $PSScriptRoot '..' '..' 'PSMotd' 'Private'
    $script:publicDir  = Join-Path $PSScriptRoot '..' '..' 'PSMotd' 'Public'

    . (Join-Path $script:privateDir 'Test-MotdIsDue.ps1')
    . (Join-Path $script:privateDir 'Test-PowerShellInteractive.ps1')
    . (Join-Path $script:privateDir 'Get-LastMOTDWrite.ps1')
    . (Join-Path $script:privateDir 'Write-LastMOTDDate.ps1')
    . (Join-Path $script:privateDir 'Write-MOTD.ps1')
    . (Join-Path $script:privateDir 'Write-MOTDIfDue.ps1')
    . (Join-Path $script:publicDir 'Get-MOTDConfig.ps1')
    . (Join-Path $script:publicDir 'Get-MOTD.ps1')
}

Describe 'Write-MOTDIfDue flow' -Tag 'Unit' {
    BeforeEach {
        Mock Get-MOTDConfig { @{ MOTDFrequency = 'Daily'; LastMOTDWrite = $null } }
        Mock Get-LastMOTDWrite { [datetime]'2026-07-01T09:00:00' }
        Mock Test-MotdIsDue { $true }
        Mock Test-PowerShellInteractive { $true }
        Mock Write-MOTD {}
        Mock Write-LastMOTDDate {}
    }

    It 'does not render or stamp when the MOTD is not due' {
        Mock Test-MotdIsDue { $false }

        Write-MOTDIfDue

        Should -Invoke Test-MotdIsDue -Times 1 -Exactly
        Should -Invoke Test-PowerShellInteractive -Times 0 -Exactly
        Should -Invoke Write-MOTD -Times 0 -Exactly
        Should -Invoke Write-LastMOTDDate -Times 0 -Exactly
    }

    It 'does not render or stamp when the session is due but non-interactive' {
        Mock Test-PowerShellInteractive { $false }

        Write-MOTDIfDue

        Should -Invoke Test-MotdIsDue -Times 1 -Exactly
        Should -Invoke Test-PowerShellInteractive -Times 1 -Exactly
        Should -Invoke Write-MOTD -Times 0 -Exactly
        Should -Invoke Write-LastMOTDDate -Times 0 -Exactly
    }

    It 'renders and stamps once when the MOTD is due in an interactive session' {
        Write-MOTDIfDue

        Should -Invoke Test-MotdIsDue -Times 1 -Exactly
        Should -Invoke Test-PowerShellInteractive -Times 1 -Exactly
        Should -Invoke Write-MOTD -Times 1 -Exactly
        Should -Invoke Write-LastMOTDDate -Times 1 -Exactly
    }
}

Describe 'Get-MOTD orchestration' -Tag 'Unit' {
    BeforeEach {
        Mock Write-MOTDIfDue {}
        Mock Write-MOTD {}
        Mock Write-LastMOTDDate {}
        Mock Write-Error {}
        Mock Write-Verbose {}
    }

    It 'renders and stamps without a due check when -Now is specified' {
        Get-MOTD -Now

        Should -Invoke Write-MOTDIfDue -Times 0 -Exactly
        Should -Invoke Write-MOTD -Times 1 -Exactly
        Should -Invoke Write-LastMOTDDate -Times 1 -Exactly
    }

    It 'does not stamp when rendering fails before the MOTD is shown' {
        Mock Write-MOTD { throw 'render failed' }

        { Get-MOTD -Now } | Should -Not -Throw

        Should -Invoke Write-MOTD -Times 1 -Exactly
        Should -Invoke Write-LastMOTDDate -Times 0 -Exactly
        Should -Invoke Write-Error -Times 1 -Exactly
    }

    It 'swallows stamp persistence failures at the public entrypoint' {
        Mock Write-LastMOTDDate { throw 'disk full' }

        { Get-MOTD -Now } | Should -Not -Throw

        Should -Invoke Write-MOTD -Times 1 -Exactly
        Should -Invoke Write-LastMOTDDate -Times 1 -Exactly
        Should -Invoke Write-Error -Times 0 -Exactly
        Should -Invoke Write-Verbose -Times 1 -Exactly -ParameterFilter { $Message -like 'Failed to persist the MOTD timestamp:*' }
    }
}
