<#
.SYNOPSIS
Returns the built-in PSMotd banner.

.DESCRIPTION
Get-DefaultMessageOfTheDay returns the fallback banner that PSMotd uses when no
Get-MessageOfTheDay function exists in the user's PowerShell profile. The
banner includes the current machine, user, and date, and it uses the host width
when it is available.

.EXAMPLE
PS C:\> Get-DefaultMessageOfTheDay

Returns the default PSMotd banner as a string.

.LINK
Get-MOTD
#>
function Get-DefaultMessageOfTheDay {
    [CmdletBinding()]
    [OutputType([string])]
    Param()

    $width = 80
    try {
        if ($Host.UI.RawUI.WindowSize.Width -gt 0) {
            $width = $Host.UI.RawUI.WindowSize.Width
        }
    } catch {
    }

    $dash = '.' * $width
    @"
$dash
______  _____  ___  ________ ___________
| ___ \/  ___| |  \/  |  _  |_   _|  _  \
| |_/ /\ `--.  | .  . | | | | | | | | | |
|  __/  `--. \ | |\/| | | | | | | | | | |
| |    /\__/ / | |  | \ \_/ / | | | |/ /
\_|    \____/  \_|  |_/\___/  \_/ |___/

- Hostname: $([Environment]::MachineName)
- User: $([Environment]::UserName)
- Date: $(Get-Date)

Set your own MOTD! Define Get-MessageOfTheDay in your Profile!
$dash
"@
}
