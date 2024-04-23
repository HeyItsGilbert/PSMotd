function Test-PowerShellInteractive {
    [CmdletBinding()]
    [OutputType([bool])]
    Param()

    if (-not [Environment]::UserInteractive) {
        Write-Debug "The [Environment]::UserInteractive property shows this PowerShell session is not interactive."
        return $false
    }

    [string[]] $typicalNonInteractiveCommandLineArguments = @(
        '-Command'
        '-c'
        '-EncodedCommand'
        '-e'
        '-ec'
        '-File'
        '-f'
        '-NonInteractive'
    )

    [string[]] $commandLineArgs = [Environment]::GetCommandLineArgs()
    Write-Debug "The PowerShell command line arguments are '$commandLineArgs'."

    [string[]] $nonInteractiveArgMatches = $commandLineArgs |
        Where-Object { $_ -in $typicalNonInteractiveCommandLineArguments }
    [bool] $isNonInteractive = $null -ne $nonInteractiveArgMatches -and $nonInteractiveArgMatches.Count -gt 0

    if ($isNonInteractive) {
        return $false
    }

    return $true
}
