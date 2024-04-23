function Get-LastMOTDDateFile {
    [CmdletBinding()]
    [OutputType([string])]
    Param()

    $dateFile = "$(Get-Date -Format FileDate).txt"
    [string]$filePath = Join-Path $env:Temp $dateFile
    return $filePath
}
