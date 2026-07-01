$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent

Write-Host '== Smoke-loading module from source (.psm1) =='
Import-Module (Join-Path $root 'PSMotd' 'PSMotd.psm1') -Force
$cmds = (Get-Module PSMotd).ExportedCommands.Keys | Sort-Object
Write-Host "Exported: $($cmds -join ', ')"
$enumGone = $false
try { $null = [MotdFrequency]::Daily } catch { $enumGone = $true }
if (-not $enumGone) { throw 'MotdFrequency type still resolvable' }
Write-Host 'Confirmed: [MotdFrequency] type is gone'

Write-Host ''
Write-Host '== Running unit tests =='
$cfg = New-PesterConfiguration
$cfg.Run.Path         = (Join-Path $PSScriptRoot 'Unit')
$cfg.Output.Verbosity = 'Normal'
$cfg.Run.PassThru     = $true
$result = Invoke-Pester -Configuration $cfg
exit $result.FailedCount
