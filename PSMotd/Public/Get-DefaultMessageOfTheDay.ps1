function Get-DefaultMessageOfTheDay {
    [CmdletBinding()]
    [OutputType([string])]
    Param()

    Write-Host ("." * 100)
    Write-Host @"
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
"@
    Write-Host ("." * 100)
}
