function Set-MOTDConfig {
    param (
        [Parameter()]
        [MotdFrequency]
        $Frequency,
        [Parameter()]
        [scriptblock]
        $MOTDScriptBlock,
        [Parameter()]
        [ValidateSet('User', 'Enterprise', 'Machine')]
        $Scope = 'User'
    )
    $base = Get-MOTDConfig
    if ($Frequency) {
        $base.MOTDFrequency = $Frequency.ToString()
    }
    if ($MOTDScriptBlock) {
        $base.MOTDScriptBlock = $MOTDScriptBlock
    }
    $base | Export-Configuration -Scope $Scope
}
