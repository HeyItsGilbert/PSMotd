# PSMotd

A Message of the Day (MOTD) for your PowerShell profile.

## Overview

This module allows you to write a function in your profile and call it a cadence
that you prefer. This is commonly something you want on first login or maybe
once a day.

## Installation

```powershell
Install-Module PSMotd
```

## Examples

An example of printing weather alerts in CA by defining a function called
`Get-MessageOfTheDay`. When the module is loaded it will determine if it should
run the function in your prompt.

```powershell
function Get-MessageOfTheDay {
  $weatherAlerts = Invoke-RestMethod "https://api.weather.gov/alerts/active?area=CA"
  if($weatherAlerts.features){
    Write-Host "Weather Alerts in California 🌤️"
    $weatherAlerts.Features | ForEach-Object{
        Write-Host "== $($_.headline) =="
        Write-Host "Severity: $($_.severity)"
        Write-Host "Description: $($_.description)"
    }
  }
}
Import-Module PSMotd
Get-Motd
```

By default the MOTD will be print once a day. You can set your environment
variable to any of the following: 'Never', 'EverySession', 'Daily', 'Weekly'

## Configuration

Configurations can be seen via `Get-MOTDConfig` and updated with
`Set-MOTDConfig`.

You can set your MOTD frequency by running:

```powershell

```

## Shout Out

This is mostly a copy paste of DeadlyDog's tiPS module. It is a way more robust
framework, you should go and try it and buy him a bagel.
