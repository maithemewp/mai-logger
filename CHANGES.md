# Changelog

All notable changes to `mai-logger` are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) · Versioning: [Semantic Versioning](https://semver.org/).

## [0.2.0] - unreleased

0.1.3 was never tagged. This release replaces its version negotiation with the loader, and includes its other fixes, listed below.

### Changed

- **Loaded by [maithemewp/mai-package-loader](https://github.com/maithemewp/mai-package-loader)**, through a `mai-package.php` declaration, instead of this package's own bootstrap. `init.php` and `Mai_Logger_Bootstrap` are gone. Requires `maithemewp/mai-package-loader` `^0.1`.
- **Needs PHP 8.1**, up from 7.4, because the loader does. Every plugin bundling mai-logger already requires 8.1 or later: mai-analytics 8.1, the rest 8.2.

### Fixed

- **The newest copy now loads.** Composer runs a package's `files` entry only once per request, so only the first plugin's bootstrap ever registered. Older copies keep working beside this one: the loader answers first. `tests/coexistence.sh` proves it against a 0.1.2 copy.

## [0.1.3] - never tagged, included in 0.2.0

### Fixed

- Version negotiation picked the first plugin to load, not the newest copy. Composer includes a package's `init.php` once per request, because every bundled copy gets the same file ID, so later copies never registered. The bootstrap now asks Composer for every registered vendor folder on first use and reads each copy's version from its class file. Takes effect once the plugin that loads first on a site bundles 0.1.3. `tests/negotiation.sh` proves it with real Composer installs in four load orders.
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
