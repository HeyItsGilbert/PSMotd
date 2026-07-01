<#
.SYNOPSIS
Persists the timestamp for the last successfully rendered MOTD.
#>
function Write-LastMOTDDate {
    [CmdletBinding()]
    [OutputType([void])]
    Param(
        [datetime]
        $Timestamp = [datetime]::Now
    )

    $config = Get-MOTDConfig
    $config.LastMOTDWrite = $Timestamp.ToString('o', [System.Globalization.CultureInfo]::InvariantCulture)
    $config | Save-MOTDConfig
}
