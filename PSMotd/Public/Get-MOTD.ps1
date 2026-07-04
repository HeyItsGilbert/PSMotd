<#
.SYNOPSIS
Shows the message of the day when it is due.

.DESCRIPTION
Get-MOTD renders the message-of-the-day content for the current session.
If you define Get-MessageOfTheDay in your PowerShell profile, that function
provides the content. Otherwise PSMotd renders the built-in banner from
Get-DefaultMessageOfTheDay.

Without -Now, Get-MOTD checks the configured cadence and suppresses automatic
output in non-interactive sessions. With -Now, it renders immediately and
updates the last-shown timestamp.

.PARAMETER Now
Renders the message of the day immediately and bypasses the due check.

.EXAMPLE
PS C:\> Import-Module PSMotd
PS C:\> Get-MOTD

Shows the message of the day when the configured cadence says it is due.

.EXAMPLE
PS C:\> Get-MOTD -Now

Shows the message of the day immediately and records the current timestamp.

.LINK
Get-MOTDConfig

.LINK
Set-MOTDConfig
#>
function Get-MOTD {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [switch]
        $Now
        # [ ] Add support for showing different scopes
    )

    try {
        if ($Now) {
            Write-Verbose 'Getting MOTD regardless of last run.'
            Write-MOTD
            try {
                Write-LastMOTDDate
            } catch {
                Write-Verbose "Failed to persist the MOTD timestamp: $_"
            }
        } else {
            Write-Verbose 'Checking if MOTD should be run'
            # Check if we need to run
            Write-MOTDIfDue
        }
    } catch {
        Write-Error "Failed to write MOTD: $_"
    }
}
