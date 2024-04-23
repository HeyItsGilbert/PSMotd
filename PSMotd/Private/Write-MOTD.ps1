function Write-MOTD {
    [CmdletBinding()]
    [OutputType([void])]
    Param()

    if (Test-Path Function:\Get-MessageOfTheDay) {
        Get-MessageOfTheDay
    } else {
        Get-DefaultMessageOfTheDay
    }
}
