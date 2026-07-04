BeforeAll {
    $script:publicDir  = Join-Path $PSScriptRoot '..' '..' 'PSMotd' 'Public'
    $script:bannerPath = Join-Path $script:publicDir 'Get-DefaultMessageOfTheDay.ps1'

    . $script:bannerPath

    if (-not ('PSMotd.Tests.BannerHost' -as [type])) {
        Add-Type -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Management.Automation;
using System.Management.Automation.Host;
using System.Security;

namespace PSMotd.Tests {
    public sealed class BannerRawUi : PSHostRawUserInterface {
        private readonly int width;
        private readonly bool throwOnWidth;
        private Size bufferSize = new Size(120, 300);
        private Coordinates cursorPosition = new Coordinates(0, 0);
        private int cursorSize = 1;
        private ConsoleColor backgroundColor = ConsoleColor.Black;
        private ConsoleColor foregroundColor = ConsoleColor.White;
        private Coordinates windowPosition = new Coordinates(0, 0);
        private string windowTitle = "Test Host";

        public BannerRawUi(int width, bool throwOnWidth) {
            this.width = width;
            this.throwOnWidth = throwOnWidth;
        }

        public override ConsoleColor BackgroundColor {
            get { return backgroundColor; }
            set { backgroundColor = value; }
        }

        public override Size BufferSize {
            get { return bufferSize; }
            set { bufferSize = value; }
        }

        public override Coordinates CursorPosition {
            get { return cursorPosition; }
            set { cursorPosition = value; }
        }

        public override int CursorSize {
            get { return cursorSize; }
            set { cursorSize = value; }
        }

        public override ConsoleColor ForegroundColor {
            get { return foregroundColor; }
            set { foregroundColor = value; }
        }

        public override bool KeyAvailable => false;

        public override Size MaxPhysicalWindowSize => new Size(200, 200);

        public override Size MaxWindowSize => new Size(200, 200);

        public override Coordinates WindowPosition {
            get { return windowPosition; }
            set { windowPosition = value; }
        }

        public override Size WindowSize {
            get {
                if (throwOnWidth) {
                    throw new NotSupportedException("RawUI width unavailable");
                }

                return new Size(width, 40);
            }
            set { }
        }

        public override string WindowTitle {
            get { return windowTitle; }
            set { windowTitle = value; }
        }

        public override void FlushInputBuffer() { }

        public override BufferCell[,] GetBufferContents(Rectangle rectangle) {
            throw new NotSupportedException();
        }

        public override KeyInfo ReadKey(ReadKeyOptions options) {
            throw new NotSupportedException();
        }

        public override void ScrollBufferContents(Rectangle source, Coordinates destination, Rectangle clip, BufferCell fill) { }

        public override void SetBufferContents(Coordinates origin, BufferCell[,] contents) { }

        public override void SetBufferContents(Rectangle rectangle, BufferCell fill) { }
    }

    public sealed class BannerUi : PSHostUserInterface {
        private readonly PSHostRawUserInterface rawUi;

        public BannerUi(int width, bool throwOnWidth) {
            rawUi = new BannerRawUi(width, throwOnWidth);
        }

        public override PSHostRawUserInterface RawUI => rawUi;

        public override Dictionary<string, PSObject> Prompt(string caption, string message, Collection<FieldDescription> descriptions) {
            return new Dictionary<string, PSObject>();
        }

        public override int PromptForChoice(string caption, string message, Collection<ChoiceDescription> choices, int defaultChoice) {
            return defaultChoice;
        }

        public override PSCredential PromptForCredential(string caption, string message, string userName, string targetName) {
            return null;
        }

        public override PSCredential PromptForCredential(string caption, string message, string userName, string targetName, PSCredentialTypes allowedCredentialTypes, PSCredentialUIOptions options) {
            return null;
        }

        public override string ReadLine() {
            return String.Empty;
        }

        public override SecureString ReadLineAsSecureString() {
            return new SecureString();
        }

        public override void Write(string value) { }

        public override void Write(ConsoleColor foregroundColor, ConsoleColor backgroundColor, string value) { }

        public override void WriteLine(string value) { }

        public override void WriteErrorLine(string value) { }

        public override void WriteDebugLine(string message) { }

        public override void WriteProgress(long sourceId, ProgressRecord record) { }

        public override void WriteVerboseLine(string message) { }

        public override void WriteWarningLine(string message) { }
    }

    public sealed class BannerHost : PSHost {
        private readonly Guid instanceId = Guid.NewGuid();
        private readonly PSHostUserInterface ui;

        public BannerHost(int width, bool throwOnWidth) {
            ui = new BannerUi(width, throwOnWidth);
        }

        public override CultureInfo CurrentCulture => CultureInfo.InvariantCulture;

        public override CultureInfo CurrentUICulture => CultureInfo.InvariantCulture;

        public override Guid InstanceId => instanceId;

        public override string Name => "BannerHost";

        public override PSHostUserInterface UI => ui;

        public override Version Version => new Version(1, 0);

        public override void EnterNestedPrompt() {
            throw new NotSupportedException();
        }

        public override void ExitNestedPrompt() {
            throw new NotSupportedException();
        }

        public override void NotifyBeginApplication() { }

        public override void NotifyEndApplication() { }

        public override void SetShouldExit(int exitCode) { }
    }
}
"@ -ErrorAction Stop
    }

    function Invoke-DefaultBannerInHost {
        param(
            [int] $Width = 120,
            [switch] $ThrowOnWidth
        )

        $testHost = [PSMotd.Tests.BannerHost]::new($Width, $ThrowOnWidth.IsPresent)
        $runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($testHost)
        $runspace.Open()

        try {
            $ps = [powershell]::Create()
            $ps.Runspace = $runspace

            $quotedPath = $script:bannerPath.Replace("'", "''")
            [void] $ps.AddScript(". '$quotedPath'")
            [void] $ps.AddScript('Get-DefaultMessageOfTheDay')

            $result = $ps.Invoke()
            if ($ps.HadErrors) {
                throw $ps.Streams.Error[0].Exception
            }

            return [string] $result[0]
        } finally {
            if ($null -ne $ps) {
                $ps.Dispose()
            }

            $runspace.Dispose()
        }
    }

    function Get-BannerLines {
        param([string] $Banner)

        $Banner -split '\r?\n'
    }
}

Describe 'Get-DefaultMessageOfTheDay' -Tag 'Unit' {
    AfterEach {
        foreach ($commandName in 'hostname', 'whoami') {
            if (Test-Path "Function:\$commandName") {
                Remove-Item "Function:\$commandName" -Force
            }
        }
    }

    It 'returns the rendered banner string and ignores hostname/whoami command shadowing' {
        function global:hostname { 'shadow-hostname' }
        function global:whoami { 'shadow-user' }

        $banner = Get-DefaultMessageOfTheDay

        $banner | Should -BeOfType ([string])
        $banner | Should -Match ([regex]::Escape("- Hostname: $([Environment]::MachineName)"))
        $banner | Should -Match ([regex]::Escape("- User: $([Environment]::UserName)"))
        $banner | Should -Not -Match ([regex]::Escape('shadow-hostname'))
        $banner | Should -Not -Match ([regex]::Escape('shadow-user'))
        $banner | Should -Match ([regex]::Escape('Set your own MOTD! Define Get-MessageOfTheDay in your Profile!'))
    }

    It 'falls back to an 80-column border when RawUI width throws' {
        $banner = Invoke-DefaultBannerInHost -ThrowOnWidth
        $lines = Get-BannerLines $banner

        $lines[0] | Should -BeExactly ('.' * 80)
        $lines[-1] | Should -BeExactly ('.' * 80)
    }

    It 'falls back to an 80-column border when RawUI width is non-positive' {
        $banner = Invoke-DefaultBannerInHost -Width 0
        $lines = Get-BannerLines $banner

        $lines[0] | Should -BeExactly ('.' * 80)
        $lines[-1] | Should -BeExactly ('.' * 80)
    }
}

AfterAll {
    if (Test-Path Function:\Get-DefaultMessageOfTheDay) {
        Remove-Item Function:\Get-DefaultMessageOfTheDay -Force
    }
}
