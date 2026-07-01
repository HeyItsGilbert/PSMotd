# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [1.0.0] - 2026-07-01

### Added

- Add focused tests for source-manifest exports, MOTD cadence flow,
  configuration persistence, and banner fallback behavior.
- Add real comment-based help for public commands and a real
  `about_PSMotd` help topic.

### Changed

- Unify configuration reads and writes under a single PSMotd-owned
  persistence gateway.
- Store `LastMOTDWrite` in invariant round-trip format and stamp it only
  after a MOTD actually renders.
- Return the default banner as pipeline output, use in-process machine
  and user identity APIs, and fall back to 80 columns when host width is
  unavailable.
- Export public commands directly from the source manifest and publish
  gallery metadata for the module.
- Refresh README, generated help, and release-time build cleanup so
  help output matches the shipped command surface.
- Harden CI and publish workflows with pinned actions, scoped secrets,
  `$GITHUB_OUTPUT`, and an analyzer baseline.

### Fixed

- Daily and weekly cadence now honor persisted timestamps instead of
  reading and writing different configuration stores.
- `Set-MOTDConfig -Frequency Never` now persists correctly and elevated
  scope failures return an actionable error.
- Manifest, help, and meta tests now validate real release behavior
  instead of passing vacuously.

### Security

- Remove disk-sourced `MOTDScriptBlock` execution from configuration
  loading and default MOTD rendering.
- Remove `SkipPublisherCheck` from development dependency installation.

### Removed

- Remove the `MotdFrequency` enum from the public surface in favor of
  validated string cadence values.
- Remove persisted `MOTDScriptBlock` configuration support.
- Remove the resolved local remediation issue tracker files.

## [0.2.0] - 2024-12-17

### Added

- Support configuration via the PoshCode Configuration module.
- Add `Get-MOTDConfig` and `Set-MOTDConfig` for persisted cadence control.

### Changed

- `Get-MOTD` now reads cadence from persisted configuration instead of
  environment variables.

### Removed

- Environment-variable-based cadence configuration.

## [0.1.0] - 2024-04-22

### Added

- Initial release.
- Automatic cadence checks for showing a profile MOTD.
