# PSMotd

## about_PSMotd

# SHORT DESCRIPTION

PSMotd shows a message of the day in your PowerShell profile on the cadence you choose.

# LONG DESCRIPTION

PSMotd is a small profile helper for people who want useful startup information
without turning every shell launch into noise.

The module does two separate jobs:

- It decides when a message of the day is due.
- It renders the content for that message.

Cadence is stored through the Configuration module. Use Set-MOTDConfig to pick
Never, EverySession, Daily, or Weekly. The default scope is User.

Content comes from your profile. If you define a Get-MessageOfTheDay function in
your PowerShell profile, PSMotd runs that function when a message is due.
If you do not define one, PSMotd falls back to the built-in banner from
Get-DefaultMessageOfTheDay.

The built-in banner is intentionally simple. It shows the current machine, the
current user, and the current date. It exists as a safe fallback, not as the
main customization surface.

# EXAMPLES

```powershell
Import-Module PSMotd
Set-MOTDConfig -Frequency Daily
Get-MOTD
```

Shows the message of the day at most once per calendar day.

```powershell
function Get-MessageOfTheDay {
    "Today's focus: ship the boring fix first."
}

Import-Module PSMotd
Get-MOTD -Now
```

Uses your profile-defined Get-MessageOfTheDay function and renders it
immediately.

# NOTE

Set-MOTDConfig controls when a message is shown. It does not store or execute
custom message content.

# SEE ALSO

- Get-MOTD
- Get-MOTDConfig
- Set-MOTDConfig
- Get-DefaultMessageOfTheDay

# KEYWORDS

- PSMotd
- PowerShell profile
- message of the day
- MOTD


