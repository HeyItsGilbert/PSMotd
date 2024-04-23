function Write-MOTDIfDue {
    [CmdletBinding()]
    [OutputType([bool])]
    Param()

    # For performance reasons, check if we should never write a tip before doing anything else.
    if ($env:MotdCadence -eq [MotdFrequency]::Never) {
        return
    }

    [DateTime] $lastMotd = Read-LastMOTDDate
    [TimeSpan] $timeSinceLastMotd = [DateTime]::Now - $lastMotd
    [int] $daysSinceLastMotd = $timeSinceLastMotd.Days

    [bool] $shouldShowMotd = $false
    switch ($env:MotdCadence) {
        ([MotdFrequency]::Never) { $shouldShowMotd = $false; break }
        ([MotdFrequency]::EverySession) { $shouldShowMotd = $true; break }
        ([MotdFrequency]::Daily) { $shouldShowMotd = $daysSinceLastMotd -ge 1; break }
        ([MotdFrequency]::Weekly) { $shouldShowMotd = $daysSinceLastMotd -ge 7; break }
    }

    if ($shouldShowMotd) {
        [bool] $isSessionInteractive = Test-PowerShellInteractive
        if (-not $isSessionInteractive) {
            Write-Verbose "PSMotd is configured to write a MOTD, but this session is non-interactive. PSMotd will only write automatic tips when it is imported into an interactive PowerShell session. This prevents a tip from being written at unexpected times, such as when the user or an automated process runs PowerShell scripts."
            return
        }

        Write-Motd
    } else {
        Write-Debug "Showing a PSMotd is not needed at this time."
    }
}
