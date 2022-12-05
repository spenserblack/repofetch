# Changelog

:warning: Further updates will be tracked in the [release notes](https://github.com/spenserblack/repofetch/releases).

## [Unreleased]

### Other

- NetBSD installation option (@0323pin)

## [0.3.3]

### Fixed

- Crash caused by `-r`/`--repository` type mismatch (@orhun)
- GitHub repository names not being detected when they didn't have the optional
  `.git` suffix

## [0.3.2]

Internal changes only

## [0.3.1]

### Changed

- CLI help to be colored
- Order of CLI help

## [0.3.0]

### Added

- GitHub ASCII art
- Option to select local repository to detect remote owner and repository

### Changed

- Date created and updated to be human-readable durations

## [0.2.1]

### Added

- config option for a personal access token

## [0.2.0]

### Added

- Issues counts
- Pull Requests counts
- Count of available issues with the `help wanted` label
- Count of available issues with the `good first issue` label
- Customizable behavior via `repofetch.yml` config file

## 0.1.0
Initial version :tada:

[Unreleased]: https://github.com/spenserblack/repofetch/compare/v0.3.3...HEAD
[0.3.3]: https://github.com/spenserblack/repofetch/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/spenserblack/repofetch/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/spenserblack/repofetch/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/spenserblack/repofetch/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/spenserblack/repofetch/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/spenserblack/repofetch/compare/v0.1.0...v0.2.0
