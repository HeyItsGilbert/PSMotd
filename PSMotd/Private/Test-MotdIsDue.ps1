<#
.SYNOPSIS
Determines whether the configured cadence says a MOTD is due.
#>
function Test-MotdIsDue {
    [CmdletBinding()]
    [OutputType([bool])]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet('Never', 'EverySession', 'Daily', 'Weekly')]
        [string]
        $Frequency,

        [Parameter(Mandatory)]
        [datetime]
        $LastWrite,

        [datetime]
        $Now = [datetime]::Now
    )

    # Calendar-day semantics: Daily is due on a new calendar date, Weekly after
    # a whole-day gap of this many days. Never/EverySession are explicit cases.
    $requiredDayGap = @{
        Daily  = 1
        Weekly = 7
    }

    switch ($Frequency) {
        'Never'        { return $false }
        'EverySession' { return $true }
        default        { return ($Now.Date - $LastWrite.Date).Days -ge $requiredDayGap[$Frequency] }
    }
}
