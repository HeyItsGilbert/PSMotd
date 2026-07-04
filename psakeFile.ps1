Properties {
    # Set this to $true to create a module with a monolithic PSM1
    $PSBPreference.Build.CompileModule = $false
    $PSBPreference.Help.DefaultLocale = 'en-US'
    $PSBPreference.Test.OutputFile = 'out/testResults.xml'
    $PSBPreference.Test.ScriptAnalysis.SettingsPath = 'tests/ScriptAnalyzerSettings.psd1'
}
TaskTearDown {
    param($task)

    if ($task.Name -ne 'GenerateMarkdown' -or -not $task.Success) {
        return
    }

    Get-ChildItem -Path (Join-Path $PSScriptRoot 'docs/en-US/*.md') -File | ForEach-Object {
        $content = Get-Content -Path $_.FullName -Raw
        $content = $content -replace ' \[-ProgressAction <ActionPreference>\]', ''
        $content = $content -replace '(?ms)^### -ProgressAction\r?\n\{\{ Fill ProgressAction Description \}\}\r?\n\r?\n```yaml\r?\nType: ActionPreference\r?\nParameter Sets: \(All\)\r?\nAliases: proga\r?\n\r?\nRequired: False\r?\nPosition: Named\r?\nDefault value: None\r?\nAccept pipeline input: False\r?\nAccept wildcard characters: False\r?\n```\r?\n', ''
        Set-Content -Path $_.FullName -Value $content
    }
}


Task Default -Depends Test

Task Test -FromModule PowerShellBuild -MinimumVersion '0.6.1'
