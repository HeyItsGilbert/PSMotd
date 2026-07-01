<#
.SYNOPSIS
Renders and timestamps the MOTD only when it is due in an interactive session.
#>
function Write-MOTDIfDue {
    [CmdletBinding()]
    [OutputType([void])]
    Param()
    $config = Get-MOTDConfig
    Write-Verbose "Config: $($config | ConvertTo-Json -Compress)"

    [datetime] $lastMotd = Get-LastMOTDWrite
    if (-not (Test-MotdIsDue -Frequency $config.MOTDFrequency -LastWrite $lastMotd)) {
        Write-Debug 'Showing a PSMotd is not needed at this time.'
        return
    }

    if (-not (Test-PowerShellInteractive)) {
        Write-Verbose 'PSMotd is configured to write a MOTD, but this session is non-interactive. PSMotd will only write automatic tips when it is imported into an interactive PowerShell session. This prevents a tip from being written at unexpected times, such as when the user or an automated process runs PowerShell scripts.'
        return
    }

    Write-MOTD
    try {
        Write-LastMOTDDate
    } catch {
        Write-Verbose "Failed to persist the MOTD timestamp: $_"
    }
}
