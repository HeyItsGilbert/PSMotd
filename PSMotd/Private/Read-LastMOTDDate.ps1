function Read-LastMOTDDate {
    [CmdletBinding()]
    [OutputType([DateTime])]
    Param()

    [DateTime] $lastMOTDWriteDate = [DateTime]::MinValue
    [string] $lastMOTDWriteDateFile = Get-LastMOTDDateFile
    if (Test-Path -Path $lastMOTDWriteDateFile -PathType Leaf) {
        [string] $lastMOTDWriteDateString = [System.IO.File]::ReadAllText($lastMOTDWriteDateFile)
        $lastMOTDWriteDate = [DateTime]::Parse($lastMOTDWriteDateString)
    }
    return $lastMOTDWriteDate
}
