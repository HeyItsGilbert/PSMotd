---
external help file: PSMotd-help.xml
Module Name: PSMotd
online version:
schema: 2.0.0
---

# Set-MOTDConfig

## SYNOPSIS
Saves the persisted PSMotd cadence configuration.

## SYNTAX

```
Set-MOTDConfig [[-Frequency] <String>] [[-Scope] <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Set-MOTDConfig updates the saved cadence that Get-MOTD uses to decide whether a
message of the day is due.
This command only manages cadence persistence.
To
customize the content itself, define Get-MessageOfTheDay in your PowerShell
profile.

User scope is the default.
Machine and Enterprise scope writes may require an
elevated PowerShell session.

## EXAMPLES

### EXAMPLE 1
```
PS C:\> Set-MOTDConfig -Frequency Daily
```

Configures PSMotd to show once per calendar day.

### EXAMPLE 2
```
PS C:\> Set-MOTDConfig -Frequency Never
```

Disables automatic message-of-the-day output.

### EXAMPLE 3
```
PS C:\> Set-MOTDConfig -Frequency Weekly -Scope Machine
```

Saves the cadence for the machine-wide configuration store.

## PARAMETERS

### -Frequency
Sets how often PSMotd should render automatically.
Valid values are Never,
EverySession, Daily, and Weekly.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scope
Selects which Configuration-module scope stores the settings.
User is the
default.
Machine and Enterprise usually require elevation.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: User
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```


### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Void
## NOTES

## RELATED LINKS

[Get-MOTDConfig]()

[Get-MOTD]()



