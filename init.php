<?php
/**
 * Mai Logger — bootstrap.
 *
 * This file is loaded automatically by Composer (via "autoload": { "files": [...] })
 * when each plugin's vendor/autoload.php is required.
 *
 * It registers the bundled Mai_Logger version into a shared registry.
 * The actual class is loaded lazily on first use, picking the newest registered version.
 *
 * Bootstrap protocol — FROZEN. Never change Mai_Logger_Bootstrap::register()'s signature.
 * Old plugins out in the wild call the old signature on whichever bootstrap loaded first.
 */

defined( 'ABSPATH' ) || 'cli' === PHP_SAPI || exit;

if ( ! class_exists( 'Mai_Logger_Bootstrap', false ) ) {
	/**
	 * Tiny registry for Mai_Logger versions across plugins.
	 *
	 * First plugin to load defines this class. All subsequent plugins
	 * call register() on this same class.
	 */
	class Mai_Logger_Bootstrap {

		/**
		 * Registered versions: [ '0.6.0' => '/abs/path/to/Mai_Logger.php', ... ].
		 *
		 * @var array<string,string>
		 */
		private static array $versions = [];

		/**
		 * Whether the autoloader has been registered yet.
		 *
		 * @var bool
		 */
		private static bool $autoloader_registered = false;

		/**
		 * Register a bundled Mai_Logger version + path.
		 *
		 * Signature is frozen; do not change.
		 *
		 * @param string $version Semver version string of the bundled class.
		 * @param string $path    Absolute path to the Mai_Logger.php file for this version.
		 */
		public static function register( string $version, string $path ): void {
			self::$versions[ $version ] = $path;

			if ( self::$autoloader_registered ) {
				return;
			}

			self::$autoloader_registered = true;

			spl_autoload_register( static function ( string $class ): void {
				if ( 'Mai_Logger' !== $class ) {
					return;
				}

				self::discover();

				if ( empty( self::$versions ) ) {
					return;
				}

				uksort( self::$versions, 'version_compare' );
				$path = end( self::$versions );

				if ( is_string( $path ) && is_readable( $path ) ) {
					require $path;
				}
			} );
		}

		/**
		 * Finds every bundled copy, not only the one whose init.php ran.
		 *
		 * Composer includes a "files" entry once per request, keyed by package
		 * name and path, which are the same in every plugin bundling this
		 * package. So only the first plugin's init.php ever runs, and on its
		 * own register() would only ever see that first copy: load order would
		 * pick the version, not the version number.
		 *
		 * Composer does keep a list of every vendor folder whose autoloader has
		 * been registered. Each one holding a copy is added here, with the
		 * version read from that copy's class file, so a stale number in an
		 * init.php cannot pick the wrong file either.
		 *
		 * Only copies whose plugin has loaded by the first use are seen, which
		 * is every active plugin once `plugins_loaded` has fired.
		 */
		private static function discover(): void {
			$loader = 'Composer\Autoload\ClassLoader';

			if ( ! class_exists( $loader, false ) || ! method_exists( $loader, 'getRegisteredLoaders' ) ) {
				return;
			}

			foreach ( array_keys( $loader::getRegisteredLoaders() ) as $vendor_dir ) {
				$path = $vendor_dir . '/maithemewp/mai-logger/Mai_Logger.php';

				if ( ! is_readable( $path ) ) {
					continue;
				}

				$source = (string) file_get_contents( $path );

				if ( preg_match( "/const VERSION = '([^']+)'/", $source, $match ) && ! isset( self::$versions[ $match[1] ] ) ) {
					self::$versions[ $match[1] ] = $path;
				}
			}
		}
	}
}

// Register THIS plugin's bundled version. Bump the string when releasing.
Mai_Logger_Bootstrap::register( '0.1.3', __DIR__ . '/Mai_Logger.php' );
