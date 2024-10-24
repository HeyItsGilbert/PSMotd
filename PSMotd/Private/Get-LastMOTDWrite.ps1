function Get-LastMOTDWrite {
    [CmdletBinding()]
    [OutputType([string])]
    Param()
    $config = Get-MOTDConfig
    return $config.LastMOTDWrite
}
