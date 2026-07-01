# Taken with love from @juneb_get_help (https://raw.githubusercontent.com/juneb/PesterTDD/master/Module.Help.Tests.ps1)

BeforeDiscovery {

    function global:FilterOutCommonParams {
        param ($Params)
        $commonParams = @(
            'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable',
            'OutBuffer', 'OutVariable', 'PipelineVariable', 'ProgressAction', 'Verbose',
            'WarningAction', 'WarningVariable', 'Confirm', 'Whatif'
        )
        $params | Where-Object { $_.Name -notin $commonParams } | Sort-Object -Property Name -Unique
    }

    function global:ConvertTo-HelpText {
        param ($Value)

        $text = foreach ($item in @($Value)) {
            if ($null -eq $item) {
                continue
            }

            if ($item -is [string]) {
                $candidate = $item
            }
            elseif ($item.PSObject.Properties.Name -contains 'Text') {
                $candidate = $item.Text
            }
            elseif ($item.PSObject.Properties.Name -contains 'Code') {
                $candidate = $item.Code
            }
            else {
                $candidate = [string]$item
            }

            if (-not [string]::IsNullOrWhiteSpace($candidate)) {
                $candidate.Trim()
            }
        }

        @($text) -join [Environment]::NewLine
    }

    function global:Test-MeaningfulHelpText {
        param (
            [AllowNull()]
            [AllowEmptyString()]
            [string]$Text
        )

        -not [string]::IsNullOrWhiteSpace($Text) -and $Text -notmatch '\{\{.*\}\}'
    }

    function global:ConvertTo-HelpLinkReference {
        param ($NavigationLink)

        if ($null -eq $NavigationLink) {
            return $null
        }

        $uriText = ConvertTo-HelpText $NavigationLink.uri
        $linkText = ConvertTo-HelpText $NavigationLink.linkText
        $target = if (-not [string]::IsNullOrWhiteSpace($uriText)) {
            $uriText
        }
        else {
            $linkText
        }

        if ([string]::IsNullOrWhiteSpace($target)) {
            return $null
        }

        $target = $target.Trim()
        $absoluteUri = $null
        $isNetworkLink = [uri]::TryCreate($target, [System.UriKind]::Absolute, [ref]$absoluteUri) -and $absoluteUri.Scheme -in @('http', 'https')

        [pscustomobject]@{
            Kind   = if ($isNetworkLink) { 'Network' } else { 'Local' }
            Target = $target
        }
    }

    $manifest             = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
    $outputDir            = Join-Path -Path $env:BHProjectPath -ChildPath 'Output'
    $outputModDir         = Join-Path -Path $outputDir -ChildPath $env:BHProjectName
    $outputModVerDir      = Join-Path -Path $outputModDir -ChildPath $manifest.ModuleVersion
    $outputModVerManifest = Join-Path -Path $outputModVerDir -ChildPath "$($env:BHProjectName).psd1"

    # Get module commands
    # Remove all versions of the module from the session. Pester can't handle multiple versions.
    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module -Name $outputModVerManifest -Verbose:$false -ErrorAction Stop
    $params = @{
        Module      = (Get-Module $env:BHProjectName)
        CommandType = [System.Management.Automation.CommandTypes[]]'Cmdlet, Function' # Not alias
    }
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        $params.CommandType[0] += 'Workflow'
    }
    $commands = Get-Command @params

    ## When testing help, remember that help is cached at the beginning of each session.
    ## To test, restart session.
}

Describe 'Help test harness' -Tag 'Unit' {
    It 'filters ProgressAction out of common parameter comparisons' {
        $params = @(
            [pscustomobject]@{ Name = 'Name' }
            [pscustomobject]@{ Name = 'ProgressAction' }
            [pscustomobject]@{ Name = 'Verbose' }
        )

        $names = @(global:FilterOutCommonParams -Params $params | Select-Object -ExpandProperty Name)

        $names | Should -HaveCount 1
        $names | Should -Contain 'Name'
    }

    It 'treats PlatyPS placeholders as incomplete help text' {
        Test-MeaningfulHelpText '{{ Fill in the Synopsis }}' | Should -BeFalse
        Test-MeaningfulHelpText 'PS C:\> {{ Add example code here }}' | Should -BeFalse
        Test-MeaningfulHelpText 'Returns the configured MOTD.' | Should -BeTrue
    }

    It 'classifies command-name help links as local references and only absolute web URIs as network links' {
        $localCommandLink = [pscustomobject]@{
            linkText = 'Get-MOTD'
            uri      = ''
        }
        $remoteLink = [pscustomobject]@{
            linkText = 'Docs'
            uri      = 'https://example.com/psmotd'
        }
        $relativeLink = [pscustomobject]@{
            linkText = 'about_PSMotd'
            uri      = 'about_PSMotd'
        }

        $localReference = ConvertTo-HelpLinkReference $localCommandLink
        $localReference.Kind | Should -Be 'Local'
        $localReference.Target | Should -Be 'Get-MOTD'

        $remoteReference = ConvertTo-HelpLinkReference $remoteLink
        $remoteReference.Kind | Should -Be 'Network'
        $remoteReference.Target | Should -Be 'https://example.com/psmotd'

        $relativeReference = ConvertTo-HelpLinkReference $relativeLink
        $relativeReference.Kind | Should -Be 'Local'
        $relativeReference.Target | Should -Be 'about_PSMotd'
    }
}


Describe "Test help for <_.Name>" -ForEach $commands {

    BeforeDiscovery {
        # Get command help, parameters, and links
        $command               = $_
        $commandHelp           = Get-Help $command.Name -ErrorAction SilentlyContinue
        $commandParameters     = global:FilterOutCommonParams -Params $command.ParameterSets.Parameters
        $commandParameterNames = $commandParameters.Name
        $helpLinks             = @($commandHelp.relatedLinks.navigationLink | ForEach-Object { ConvertTo-HelpLinkReference $_ } | Where-Object { $null -ne $_ })
        $localHelpLinks        = @($helpLinks | Where-Object Kind -eq 'Local')
        $networkHelpLinks      = @($helpLinks | Where-Object Kind -eq 'Network')
    }

    BeforeAll {
        # These vars are needed in both discovery and test phases so we need to duplicate them here
        $command                = $_
        $commandName            = $_.Name
        $commandHelp            = Get-Help $command.Name -ErrorAction SilentlyContinue
        $commandParameters      = global:FilterOutCommonParams -Params $command.ParameterSets.Parameters
        $commandParameterNames  = $commandParameters.Name
        $helpLinks              = @($commandHelp.relatedLinks.navigationLink | ForEach-Object { ConvertTo-HelpLinkReference $_ } | Where-Object { $null -ne $_ })
        $localHelpLinks         = @($helpLinks | Where-Object Kind -eq 'Local')
        $networkHelpLinks       = @($helpLinks | Where-Object Kind -eq 'Network')
        $helpParameters         = global:FilterOutCommonParams -Params $commandHelp.Parameters.Parameter
        $helpParameterNames     = $helpParameters.Name
    }

    # If help is not found, synopsis in auto-generated help is the syntax diagram
    It 'Help is not auto-generated' {
        $commandHelp.Synopsis | Should -Not -BeLike '*`[`<CommonParameters`>`]*'
    }

    It 'Has real synopsis' -Tag 'HelpContent' {
        Test-MeaningfulHelpText (ConvertTo-HelpText $commandHelp.Synopsis) | Should -BeTrue
    }

    # Should be a description for every function
    It 'Has description' -Tag 'HelpContent' {
        Test-MeaningfulHelpText (ConvertTo-HelpText $commandHelp.Description) | Should -BeTrue
    }

    # Should be at least one example
    It 'Has example code' -Tag 'HelpContent' {
        Test-MeaningfulHelpText (ConvertTo-HelpText (($commandHelp.Examples.Example | Select-Object -First 1).Code)) | Should -BeTrue
    }

    # Should be at least one example description
    It 'Has example help' -Tag 'HelpContent' {
        Test-MeaningfulHelpText (ConvertTo-HelpText (($commandHelp.Examples.Example | Select-Object -First 1).Remarks)) | Should -BeTrue
    }

    It 'Help link <_.Target> resolves locally' -ForEach $localHelpLinks {
        $resolvedHelp = Get-Help $_.Target -ErrorAction SilentlyContinue

        $resolvedHelp | Should -Not -BeNullOrEmpty
        $resolvedHelp.Name | Should -Be $_.Target
    }

    It 'Help link <_.Target> is valid' -Tag 'HelpNetwork' -ForEach $networkHelpLinks {
        (Invoke-WebRequest -Uri $_.Target -UseBasicParsing).StatusCode | Should -Be 200
    }

    Context "Parameter <_.Name>" -Foreach $commandParameters {

        BeforeAll {
            $parameter         = $_
            $parameterName     = $parameter.Name
            $parameterHelp     = $commandHelp.parameters.parameter | Where-Object Name -eq $parameterName
            $parameterHelpType = if ($parameterHelp.ParameterValue) { $parameterHelp.ParameterValue.Trim() }
        }

        # Should be a description for every parameter
        It 'Has description' -Tag 'HelpContent' {
            Test-MeaningfulHelpText (ConvertTo-HelpText $parameterHelp.Description) | Should -BeTrue
        }

        # Required value in Help should match IsMandatory property of parameter
        It "Has correct [mandatory] value" {
            $codeMandatory = $_.IsMandatory.toString()
            $parameterHelp.Required | Should -Be $codeMandatory
        }

        # Parameter type in help should match code
        It "Has correct parameter type" {
            $parameterHelpType | Should -Be $parameter.ParameterType.Name
        }
    }

    Context "Test <_> help parameter help for <commandName>" -Foreach $helpParameterNames {

        # Shouldn't find extra parameters in help.
        It 'finds help parameter in code: <_>' {
            $_ -in $commandParameterNames | Should -Be $true
        }
    }
}
