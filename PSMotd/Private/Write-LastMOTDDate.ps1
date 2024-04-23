function Write-LastMOTDDate {
    [CmdletBinding()]
    [OutputType([void])]
    Param()

    $filePath = Get-LastMOTDDateFile
    [System.IO.File]::WriteAllText($filePath, $(Get-Date).ToString())
}
