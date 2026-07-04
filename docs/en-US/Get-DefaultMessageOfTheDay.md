---
external help file: PSMotd-help.xml
Module Name: PSMotd
online version:
schema: 2.0.0
---

# Get-DefaultMessageOfTheDay

## SYNOPSIS
Returns the built-in PSMotd banner.

## SYNTAX

```
Get-DefaultMessageOfTheDay [<CommonParameters>]
```

## DESCRIPTION
Get-DefaultMessageOfTheDay returns the fallback banner that PSMotd uses when no
Get-MessageOfTheDay function exists in the user's PowerShell profile.
The
banner includes the current machine, user, and date, and it uses the host width
when it is available.

## EXAMPLES

### EXAMPLE 1
```
PS C:\> Get-DefaultMessageOfTheDay
```

Returns the default PSMotd banner as a string.

## PARAMETERS


### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
## NOTES

## RELATED LINKS

[Get-MOTD]()



