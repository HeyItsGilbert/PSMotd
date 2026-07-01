---
external help file: PSMotd-help.xml
Module Name: PSMotd
online version:
schema: 2.0.0
---

# Get-MOTD

## SYNOPSIS
Shows the message of the day when it is due.

## SYNTAX

```
Get-MOTD [-Now] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get-MOTD renders the message-of-the-day content for the current session.
If you define Get-MessageOfTheDay in your PowerShell profile, that function
provides the content.
Otherwise PSMotd renders the built-in banner from
Get-DefaultMessageOfTheDay.

Without -Now, Get-MOTD checks the configured cadence and suppresses automatic
output in non-interactive sessions.
With -Now, it renders immediately and
updates the last-shown timestamp.

## EXAMPLES

### EXAMPLE 1
```
PS C:\> Import-Module PSMotd
PS C:\> Get-MOTD
```

Shows the message of the day when the configured cadence says it is due.

### EXAMPLE 2
```
Get-MOTD -Now
```

Shows the message of the day immediately and records the current timestamp.

## PARAMETERS

### -Now
Renders the message of the day immediately and bypasses the due check.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```



### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[Get-MOTDConfig]()

[Set-MOTDConfig]()



