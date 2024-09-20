function Write-LastMOTDDate {
    [CmdletBinding()]
    [OutputType([void])]
    Param()

    $config = Get-MOTDConfig
    $config.LastMOTDWrite = [datetime]::Now
    $config | Export-Configuration
}
