# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.2.1] Fix Config Load

### Changes

- Fix the config load sites to explicitly pass company and module name.

## [0.2.0] Use the PoshCode/Configuration

### Added

- Support configuration via the PoshCode Configuration module.
- Allow

## [0.1.0] Initial Version

The code mostly checks whether it should show or not. Right now it's using an
env var to determine when to show. Future versions will likely use a shared
module based off of tiPS to do the logic when to show. This version is the MVP.
