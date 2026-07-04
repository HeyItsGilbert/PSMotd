# PSMotd

A Message of the Day (MOTD) for your PowerShell profile.

---

PSMotd lets you decide when a message of the day should show up and lets your
profile decide what it says.

```powershell
Install-Module PSMotd
```

## Profile setup

Add this to your profile:

```powershell
Import-Module PSMotd
Get-MOTD
```

## Custom content

Define `Get-MessageOfTheDay` in your profile to supply your own content:

```powershell
function Get-MessageOfTheDay {
    $weatherAlerts = Invoke-RestMethod 'https://api.weather.gov/alerts/active?area=CA'
    if ($weatherAlerts.Features) {
        'Weather alerts in California'
        $weatherAlerts.Features | ForEach-Object {
            "== $($_.properties.headline) =="
            "Severity: $($_.properties.severity)"
            $_.properties.description
        }
    }
}
```

PSMotd checks for `Get-MessageOfTheDay` first. If it is not present, the module
returns the built-in banner from `Get-DefaultMessageOfTheDay`.

## Configuration

Inspect the current cadence settings with `Get-MOTDConfig`, and set your
preferred cadence with `Set-MOTDConfig`:

```powershell
Set-MOTDConfig -Frequency Daily
```

Automatic cadence values are:

- `Never`
- `EverySession`
- `Daily`
- `Weekly`

## Next steps

- [Commands](en-US/) -- full reference for every exported cmdlet
- [Changelog](https://github.com/HeyItsGilbert/PSMotd/blob/main/CHANGELOG.md) -- what's new
