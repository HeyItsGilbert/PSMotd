BeforeAll {
    Set-StrictMode -Version Latest

    $script:manifestPath = Join-Path $PSScriptRoot '..' 'PSMotd' 'PSMotd.psd1'
    $script:expectedPublicCommands = @(
        'Get-DefaultMessageOfTheDay'
        'Get-MOTD'
        'Get-MOTDConfig'
        'Set-MOTDConfig'
    )

    $script:manifestData = Import-PowerShellDataFile -Path $script:manifestPath
    $script:psData = $script:manifestData.PrivateData.PSData

    Remove-Module PSMotd -Force -ErrorAction SilentlyContinue

    try {
        $script:importError = $null
        $script:importedModule = Import-Module $script:manifestPath -Force -PassThru -ErrorAction Stop
    } catch {
        $script:importError = $_
        $script:importedModule = $null
    }
}

Describe 'Source module manifest' -Tag 'Unit' {
    Context 'public command exports' {
        It 'declares the intended public functions explicitly in the source manifest' {
            $actual = @($script:manifestData.FunctionsToExport | Sort-Object)
            $expected = @($script:expectedPublicCommands | Sort-Object)

            $actual.Count | Should -Be $expected.Count
            ($actual -join ',') | Should -Be ($expected -join ',')
        }

        It 'exports the intended public functions when imported from the source manifest' {
            $script:importError | Should -Be $null

            $actual = @($script:importedModule.ExportedCommands.Keys | Sort-Object)
            $expected = @($script:expectedPublicCommands | Sort-Object)

            $actual.Count | Should -Be $expected.Count
            ($actual -join ',') | Should -Be ($expected -join ',')
        }
    }

    Context 'gallery metadata' {
        It 'sets a real company name instead of the default placeholder' {
            [string]::IsNullOrWhiteSpace($script:manifestData.CompanyName) | Should -BeFalse
            $script:manifestData.CompanyName | Should -Not -Be 'Unknown'
        }

        It 'publishes non-empty discovery tags' {
            $script:psData.Tags | Should -Not -BeNullOrEmpty
            @($script:psData.Tags).Count | Should -BeGreaterThan 0

            foreach ($tag in $script:psData.Tags) {
                [string]::IsNullOrWhiteSpace($tag) | Should -BeFalse
            }
        }

        It 'declares LicenseUri as an absolute URI' {
            [string]::IsNullOrWhiteSpace($script:psData.LicenseUri) | Should -BeFalse
            { [uri]$script:psData.LicenseUri } | Should -Not -Throw

            $uri = [uri]$script:psData.LicenseUri
            $uri.IsAbsoluteUri | Should -BeTrue
        }

        It 'declares ProjectUri as an absolute URI' {
            [string]::IsNullOrWhiteSpace($script:psData.ProjectUri) | Should -BeFalse
            { [uri]$script:psData.ProjectUri } | Should -Not -Throw

            $uri = [uri]$script:psData.ProjectUri
            $uri.IsAbsoluteUri | Should -BeTrue
        }

        It 'publishes release notes text for the current package' {
            [string]::IsNullOrWhiteSpace($script:psData.ReleaseNotes) | Should -BeFalse
        }
    }
}

AfterAll {
    Remove-Module PSMotd -Force -ErrorAction SilentlyContinue
}
