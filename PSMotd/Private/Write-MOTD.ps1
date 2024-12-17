function Write-MOTD {
    [CmdletBinding()]
    [OutputType([void])]
    Param()
    $config = Get-MOTDConfig

    if (Test-Path Function:\Get-MessageOfTheDay) {
        Get-MessageOfTheDay
    } elseif ($config.MOTDScriptBlock) {
        $config.MOTDScriptBlock.Invoke()
    } else {
        Get-DefaultMessageOfTheDay
    }
}
