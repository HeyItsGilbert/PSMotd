<#
.SYNOPSIS
Reads and parses the persisted last-rendered MOTD timestamp.
#>
function Get-LastMOTDWrite {
    [CmdletBinding()]
    [OutputType([datetime])]
    Param()

    [string] $rawLastWrite = (Get-MOTDConfig).LastMOTDWrite
    if ([string]::IsNullOrWhiteSpace($rawLastWrite)) {
        return [datetime]::MinValue
    }

    $culture = [System.Globalization.CultureInfo]::InvariantCulture
    try {
        return [datetime]::ParseExact(
            $rawLastWrite,
            'o',
            $culture,
            [System.Globalization.DateTimeStyles]::RoundtripKind
        )
    } catch [System.FormatException] {
        try {
            return [datetime]::Parse($rawLastWrite, $culture)
        } catch [System.FormatException] {
            Write-Verbose "Invalid LastMOTDWrite '$rawLastWrite'. Treating the MOTD as never shown."
            return [datetime]::MinValue
        }
    }
}
