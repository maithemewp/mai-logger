#!/usr/bin/env bash
#
# Proves this copy loads ahead of an older one with the old bootstrap,
# whichever plugin loads first.
#
# Builds two throwaway plugins with real Composer installs: one with this
# working copy, loaded through mai-package-loader, and one with the released
# 0.1.2, which uses its own bootstrap.
#
#   ./tests/coexistence.sh
#
# Needs Composer, and mai-package-loader beside this repo in ~/LocalPackages.

set -euo pipefail

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
LOADER="${LOADER:-$ROOT/../mai-package-loader}"
WORK="$( mktemp -d )"
trap 'rm -rf "$WORK"' EXIT

WANT="$( sed -n "s/.*const VERSION = '\([^']*\)'.*/\1/p" "$ROOT/Mai_Logger.php" )"

mkdir -p "$WORK/old-src" "$WORK/new" "$WORK/old"
git -C "$ROOT" archive v0.1.2 | tar -x -C "$WORK/old-src"

cat > "$WORK/new/composer.json" <<JSON
{
	"name": "demo/new",
	"repositories": [
		{ "type": "path", "url": "$ROOT", "options": { "symlink": false } },
		{ "type": "path", "url": "$LOADER", "options": { "symlink": false } }
	],
	"require": { "maithemewp/mai-logger": "@dev", "maithemewp/mai-package-loader": "@dev" }
}
JSON

cat > "$WORK/old/composer.json" <<JSON
{
	"name": "demo/old",
	"repositories": [
		{ "type": "path", "url": "$WORK/old-src", "options": { "symlink": false, "versions": { "maithemewp/mai-logger": "0.1.2" } } }
	],
	"require": { "maithemewp/mai-logger": "0.1.2" }
}
JSON

( cd "$WORK/new" && composer install --quiet --no-interaction )
( cd "$WORK/old" && composer install --quiet --no-interaction )

failed=0

for order in "new old" "old new"; do
	# shellcheck disable=SC2086
	got="$( php -r 'foreach ( array_slice( $argv, 2 ) as $p ) { require $argv[1] . "/$p/vendor/autoload.php"; } echo Mai_Logger::VERSION;' "$WORK" $order )"

	if [ "$got" = "$WANT" ]; then
		echo "  ok   loading $order serves $WANT"
	else
		echo "  FAIL loading $order serves $got, expected $WANT"
		failed=1
	fi
done

[ "$failed" -eq 0 ] && echo "All checks passed." || echo "FAILED"
exit $failed
