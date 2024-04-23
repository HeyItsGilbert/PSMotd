function Get-LastMOTDDateFile {
    [CmdletBinding()]
    [OutputType([string])]
    Param()

    $dateFile = "$(Get-Date -Format FileDate).txt"
    $tempDir = [System.IO.Path]::GetTempPath()
    [string]$filePath = Join-Path $tempDir $dateFile
    return $filePath
}
