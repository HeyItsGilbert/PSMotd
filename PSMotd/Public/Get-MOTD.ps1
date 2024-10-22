function Get-MOTD {
    param (
        [switch]
        $Now
    )
    try {
        if ($Now) {
            Write-Verbose "Getting MOTD regardless of last run."
            Write-MOTD
        } else {
            Write-Verbose "Checking if MOTD should be run"
            # Check if we need to run
            Write-MOTDIfDue
        }
    } catch {
        Write-Error "Failed to write MOTD: $_"
    } finally {
        Write-LastMOTDDate
    }
}