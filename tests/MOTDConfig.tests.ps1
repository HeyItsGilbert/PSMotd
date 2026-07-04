BeforeAll {
    function Import-Configuration {
        [CmdletBinding()]
        param(
            [string]
            $Name,

            [string]
            $CompanyName
        )
    }

    function Export-Configuration {
        [CmdletBinding()]
        param(
            [Parameter(ValueFromPipeline)]
            $InputObject,

            [string]
            $Scope,

            [string]
            $Name,

            [string]
            $CompanyName
        )

        process {}
    }

    . (Join-Path $PSScriptRoot '..' 'PSMotd' 'Private' 'ConfigurationGateway.ps1')
    . (Join-Path $PSScriptRoot '..' 'PSMotd' 'Public' 'Get-MOTDConfig.ps1')
    . (Join-Path $PSScriptRoot '..' 'PSMotd' 'Public' 'Set-MOTDConfig.ps1')
    . (Join-Path $PSScriptRoot '..' 'PSMotd' 'Private' 'Get-LastMOTDWrite.ps1')
    . (Join-Path $PSScriptRoot '..' 'PSMotd' 'Private' 'Write-LastMOTDDate.ps1')
}

Describe 'MOTD configuration helpers' -Tag 'Unit' {
    Context 'Set-MOTDConfig' {
        BeforeEach {
            $config = [pscustomobject]@{
                MOTDFrequency = 'Daily'
                LastMOTDWrite = '2024-01-01T00:00:00.0000000Z'
                Theme         = 'Midnight'
            }

            Mock Get-MOTDConfig { $config }
        }

        It 'saves Frequency Never without dropping untouched settings' {
            Mock Save-MOTDConfig {}

            Set-MOTDConfig -Frequency Never -Scope User

            Should -Invoke Save-MOTDConfig -Times 1 -Exactly -ParameterFilter {
                $Scope -eq 'User' -and
                $InputObject.MOTDFrequency -eq 'Never' -and
                $InputObject.LastMOTDWrite -eq '2024-01-01T00:00:00.0000000Z' -and
                $InputObject.Theme -eq 'Midnight'
            }
        }

        It 'does not save when WhatIf is used' {
            Mock Save-MOTDConfig {}

            Set-MOTDConfig -Frequency Weekly -Scope User -WhatIf

            Should -Invoke Save-MOTDConfig -Times 0
        }
    }

    Context 'Save-MOTDConfig' {
        It 'exports with the selected scope and PSMOTD identity' {
            $config = [pscustomobject]@{
                MOTDFrequency = 'Daily'
                LastMOTDWrite = '2024-01-01T00:00:00.0000000Z'
            }

            Mock Export-Configuration {}

            $config | Save-MOTDConfig -Scope Machine

            Should -Invoke Export-Configuration -Times 1 -Exactly -ParameterFilter {
                $Scope -eq 'Machine' -and
                $Name -eq 'PSMOTD' -and
                $CompanyName -eq 'PSMOTD' -and
                $InputObject.MOTDFrequency -eq 'Daily' -and
                $InputObject.LastMOTDWrite -eq '2024-01-01T00:00:00.0000000Z'
            }
        }
    }

    Context 'timestamp helpers' {
        It 'round-trips timestamps using invariant o format' {
            $timestamp = [datetime]'2026-07-01T12:34:56.1234567Z'
            $script:savedConfig = $null

            Mock Get-MOTDConfig {
                if ($script:savedConfig) {
                    return $script:savedConfig
                }

                return [pscustomobject]@{
                    MOTDFrequency = 'Daily'
                    LastMOTDWrite = $null
                }
            }

            Mock Save-MOTDConfig {
                $script:savedConfig = [pscustomobject]@{
                    MOTDFrequency = $InputObject.MOTDFrequency
                    LastMOTDWrite = $InputObject.LastMOTDWrite
                }
            }

            Write-LastMOTDDate -Timestamp $timestamp

            $expected = $timestamp.ToString('o', [System.Globalization.CultureInfo]::InvariantCulture)
            $script:savedConfig.LastMOTDWrite | Should -Be $expected
            Get-LastMOTDWrite | Should -Be $timestamp
        }

        It 'parses legacy persisted timestamps' {
            Mock Get-MOTDConfig {
                [pscustomobject]@{
                    LastMOTDWrite = 'Monday, January 1, 2024 12:00:00 AM'
                }
            }

            Get-LastMOTDWrite | Should -Be ([datetime]'2024-01-01T00:00:00')
        }

        It 'treats <RawLastWrite> as never shown' -ForEach @(
            @{ RawLastWrite = $null }
            @{ RawLastWrite = '' }
            @{ RawLastWrite = '   ' }
            @{ RawLastWrite = 'not-a-date' }
        ) {
            Mock Get-MOTDConfig {
                [pscustomobject]@{
                    LastMOTDWrite = $RawLastWrite
                }
            }

            Get-LastMOTDWrite | Should -Be ([datetime]::MinValue)
        }
    }
}
