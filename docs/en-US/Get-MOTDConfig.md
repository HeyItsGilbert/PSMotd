---
external help file: PSMotd-help.xml
Module Name: PSMotd
online version:
schema: 2.0.0
---

# Get-MOTDConfig

## SYNOPSIS
Gets the persisted PSMotd configuration.

## SYNTAX

```
Get-MOTDConfig [<CommonParameters>]
```

## DESCRIPTION
Get-MOTDConfig loads the layered PSMotd configuration from the owned
configuration identity.
The returned object includes the configured cadence and
the last timestamp that successfully rendered a message of the day.

## EXAMPLES

### EXAMPLE 1
```
PS C:\> Get-MOTDConfig

Name                           Value
----                           -----
MOTDFrequency                  Daily
LastMOTDWrite                  2024-01-01T00:00:00.0000000
```

Returns the current PSMotd cadence configuration.

## PARAMETERS


### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[Set-MOTDConfig]()



