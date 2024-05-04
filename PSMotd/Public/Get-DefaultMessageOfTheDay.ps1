function Get-DefaultMessageOfTheDay {
    [CmdletBinding()]
    [OutputType([string])]
    Param()

    $dash = "." * $Host.UI.RawUI.WindowSize.Width
    Write-Host @"
$dash
______  _____  ___  ________ ___________
| ___ \/  ___| |  \/  |  _  |_   _|  _  \
| |_/ /\ `--.  | .  . | | | | | | | | | |
|  __/  `--. \ | |\/| | | | | | | | | | |
| |    /\__/ / | |  | \ \_/ / | | | |/ /
\_|    \____/  \_|  |_/\___/  \_/ |___/

- Hostname: $(hostname)
- User: $(whoami)
- Date: $(Get-Date)

Set your own MOTD! Define Get-MessageOfTheDay in your Profile!
$dash
"@
}
