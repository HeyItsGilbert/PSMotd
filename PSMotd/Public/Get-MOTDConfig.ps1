<#
.SYNOPSIS
Gets the persisted PSMotd configuration.

.DESCRIPTION
Get-MOTDConfig loads the layered PSMotd configuration from the owned
configuration identity. The returned object includes the configured cadence and
the last timestamp that successfully rendered a message of the day.

.EXAMPLE
PS C:\> Get-MOTDConfig

Returns the current PSMotd configuration.

.LINK
Set-MOTDConfig
#>
function Get-MOTDConfig {
    [CmdletBinding()]
    [OutputType([object])]
    param ()
    Import-MOTDConfiguration
}
