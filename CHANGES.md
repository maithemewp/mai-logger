# Changelog

All notable changes to `mai-logger` are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) · Versioning: [Semantic Versioning](https://semver.org/).

## [0.1.3] - 2026-10-03

### Fixed

- `init.php` registered version `0.1.1` while the class was `0.1.2`. Version negotiation picks the highest registered version, so a stale number could load an older copy bundled by another plugin. Both now say `0.1.3`.
- The docs said `error()` always reaches `debug.log`. It only does when `WP_DEBUG_LOG` is on, which is the intended behaviour. The method docblocks and the README now say so. No behaviour changed.

## [0.1.2] - 2026-07-08

### Changed

- Added a `.gitattributes` with `export-ignore` so dev-only paths are stripped from the Composer dist archive (preventive; the package currently ships only its PHP sources).

## [0.1.1] - 2026-07-06

### Fixed

- Allow the class to load under CLI (PHPUnit) without `ABSPATH` defined, so a bundling plugin can run its test suite on a clean checkout or in CI. Added `@param`/`@return` docblocks across the public methods.

## [0.1.0] - 2026-04-27

### Added

- Initial release. `Mai_Logger`, a lightweight logger for WordPress plugins, loaded via a bootstrap autoloader that selects the newest registered version across all installed plugins.
