BeforeAll {
    . (Join-Path $PSScriptRoot '..' '..' 'PSMotd' 'Private' 'Test-MotdIsDue.ps1')
    # Fixed reference "now" so the boundary table is deterministic (no real clock).
    $script:Now = [datetime]'2026-07-01 09:00:00'
}

Describe 'Test-MotdIsDue' {

    Context 'calendar-day boundary table' {
        It 'Frequency <Frequency> with last-write <LastWrite> is due = <Expected>' -ForEach @(
            # Never: never due, regardless of elapsed time
            @{ Frequency = 'Never';        LastWrite = '2020-01-01 09:00:00'; Expected = $false }

            # EverySession: always due, even when just shown
            @{ Frequency = 'EverySession'; LastWrite = '2026-07-01 08:59:59'; Expected = $true }

            # Daily: due on a NEW calendar date, not a rolling 24h window
            @{ Frequency = 'Daily';        LastWrite = '2026-07-01 00:00:01'; Expected = $false } # same date
            @{ Frequency = 'Daily';        LastWrite = '2026-06-30 23:59:59'; Expected = $true }  # yesterday, only ~9h ago
            @{ Frequency = 'Daily';        LastWrite = '2026-06-30 09:00:00'; Expected = $true }  # exactly 1 day

            # Weekly: due after a 7+ calendar-day gap
            @{ Frequency = 'Weekly';       LastWrite = '2026-06-25 00:00:00'; Expected = $false } # 6 days
            @{ Frequency = 'Weekly';       LastWrite = '2026-06-24 09:00:00'; Expected = $true }  # exactly 7 days
            @{ Frequency = 'Weekly';       LastWrite = '2026-06-01 09:00:00'; Expected = $true }  # well past
        ) {
            Test-MotdIsDue -Frequency $Frequency -LastWrite ([datetime]$LastWrite) -Now $script:Now |
                Should -Be $Expected
        }
    }

    Context 'input contract' {
        It 'rejects an unknown frequency (ValidateSet)' {
            { Test-MotdIsDue -Frequency 'Hourly' -LastWrite $script:Now } | Should -Throw
        }

        It 'returns a [bool]' {
            Test-MotdIsDue -Frequency 'Daily' -LastWrite ([datetime]'2020-01-01') -Now $script:Now |
                Should -BeOfType ([bool])
        }

        It 'defaults -Now to the current time when omitted' {
            # last write far in the past => Daily is due regardless of the real clock
            Test-MotdIsDue -Frequency 'Daily' -LastWrite ([datetime]'2000-01-01') | Should -BeTrue
        }
    }
}
