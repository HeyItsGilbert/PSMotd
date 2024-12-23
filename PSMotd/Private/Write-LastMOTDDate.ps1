function Write-LastMOTDDate {
    [CmdletBinding()]
    [OutputType([void])]
    Param()

    Write-Verbose "Updating the MOTD timestamp to $([datetime]::Now)"
    @{LastMOTDWrite = [datetime]::Now } | Export-Configuration -Scope 'User' -Name 'PSMOTD' -CompanyName 'PSMOTD'
}
