<#
.SYNOPSIS
Saves the persisted PSMotd cadence configuration.

.DESCRIPTION
Set-MOTDConfig updates the saved cadence that Get-MOTD uses to decide whether a
message of the day is due. This command only manages cadence persistence. To
customize the content itself, define Get-MessageOfTheDay in your PowerShell
profile.

User scope is the default. Machine and Enterprise scope writes may require an
elevated PowerShell session.

.PARAMETER Frequency
Sets how often PSMotd should render automatically. Valid values are Never,
EverySession, Daily, and Weekly.

.PARAMETER Scope
Selects which Configuration-module scope stores the settings. User is the
default. Machine and Enterprise usually require elevation.

.EXAMPLE
PS C:\> Set-MOTDConfig -Frequency Daily

Configures PSMotd to show once per calendar day.

.EXAMPLE
PS C:\> Set-MOTDConfig -Frequency Never

Disables automatic message-of-the-day output.

.EXAMPLE
PS C:\> Set-MOTDConfig -Frequency Weekly -Scope Machine

Saves the cadence for the machine-wide configuration store.

.LINK
Get-MOTDConfig

.LINK
Get-MOTD
#>
function Set-MOTDConfig {
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([void])]
    param (
        [Parameter()]
        [ValidateSet('Never', 'EverySession', 'Daily', 'Weekly')]
        [string]
        $Frequency,
        [Parameter()]
        [ValidateSet('User', 'Enterprise', 'Machine')]
        [string]
        $Scope = $script:MOTDConfigurationDefaultScope
    )

    $base = Get-MOTDConfig
    if ($PSBoundParameters.ContainsKey('Frequency')) {
        $base.MOTDFrequency = $Frequency
    }

    if ($PSCmdlet.ShouldProcess("PSMOTD configuration ($Scope)", 'Save')) {
        if (
            $Scope -in @('Machine', 'Enterprise') -and
            [Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT
        ) {
            $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
            $principal = [Security.Principal.WindowsPrincipal]::new($currentIdentity)
            if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
                throw "Saving PSMOTD configuration to scope '$Scope' requires an elevated PowerShell session."
            }
        }

        try {
            $base | Save-MOTDConfig -Scope $Scope
        } catch [System.UnauthorizedAccessException] {
            throw "Saving PSMOTD configuration to scope '$Scope' requires an elevated PowerShell session."
        }
    }
}
