<#
.SYNOPSIS
Renders the profile-defined MOTD content or the built-in fallback banner.
#>
function Write-MOTD {
    [CmdletBinding()]
    [OutputType([object])]
    Param()
    if (Test-Path Function:\Get-MessageOfTheDay) {
        Get-MessageOfTheDay
    } else {
        Get-DefaultMessageOfTheDay
    }
}
