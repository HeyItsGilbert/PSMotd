function Get-MOTDConfig {
    [CmdletBinding()]
    param ()
    Import-Configuration -Name 'PSMOTD' -CompanyName 'PSMOTD'
}
