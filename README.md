# PSMotd

A Message of the Day (MOTD) for your PowerShell profile.

## Overview

PSMotd lets you decide when a message of the day should show up and lets your
profile decide what it says.

Define `Get-MessageOfTheDay` in your PowerShell profile for custom content. If
you do not define one, PSMotd falls back to the built-in banner.

Automatic cadence values are:

- `Never`
- `EverySession`
- `Daily`
- `Weekly`

## Installation

```powershell
Install-Module PSMotd
```

PSMotd depends on the `Configuration` module. Installing from the PowerShell
Gallery pulls required modules automatically. If you copy the source module into
your profile by hand, make sure `Configuration` 1.6.0 is available too.

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

Inspect the current cadence settings with `Get-MOTDConfig`:

```powershell
PS C:\> Get-MOTDConfig

Name                           Value
----                           -----
MOTDFrequency                  Daily
LastMOTDWrite                  2024-01-01T00:00:00.0000000
```

Set your preferred cadence with `Set-MOTDConfig`:

```powershell
Set-MOTDConfig -Frequency Daily
```

Stop automatic output entirely:

```powershell
Set-MOTDConfig -Frequency Never
```

Render the MOTD immediately without waiting for the cadence window:

```powershell
Get-MOTD -Now
```

`Set-MOTDConfig` controls when a MOTD is shown. It does not store or execute
custom message content.

## Shout Out

This is mostly a copy paste of DeadlyDog's tiPS module. It is a way more robust
framework, you should go and try it and buy him a bagel.
