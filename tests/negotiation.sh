#!/usr/bin/env bash
#
# Proves that several plugins bundling mai-logger load the newest copy,
# whatever order the plugins load in.
#
# Builds three throwaway "plugins", each with a real Composer install of a copy
# of this working tree stamped with a different version. Real installs matter:
# the bug this guards against lived in how Composer's own autoloader treats
# the same package installed in several vendor folders, which a hand-written
# require would never show.
#
#   ./tests/negotiation.sh
#
# Needs Composer. No network: the copies install from local path repositories.

set -euo pipefail

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
WORK="$( mktemp -d )"
trap 'rm -rf "$WORK"' EXIT

CURRENT="$( sed -n "s/.*const VERSION = '\([^']*\)'.*/\1/p" "$ROOT/Mai_Logger.php" )"

# Each plugin is a name and the version its copy claims to be.
PLUGINS=( "aaa:0.1.0" "mmm:9.0.0" "zzz:0.5.0" )

for plugin in "${PLUGINS[@]}"; do
	name="${plugin%%:*}"
	version="${plugin##*:}"
	pkg="$WORK/pkg-$name"

	mkdir -p "$pkg" "$WORK/$name"
	cp "$ROOT/init.php" "$ROOT/Mai_Logger.php" "$ROOT/composer.json" "$pkg/"
	sed -i.bak "s/register( '$CURRENT'/register( '$version'/" "$pkg/init.php"
	sed -i.bak "s/const VERSION = '$CURRENT'/const VERSION = '$version'/" "$pkg/Mai_Logger.php"

	cat > "$WORK/$name/composer.json" <<JSON
{
	"repositories": [ { "type": "path", "url": "$pkg", "options": { "symlink": false, "versions": { "maithemewp/mai-logger": "$version" } } } ],
	"require": { "maithemewp/mai-logger": "$version" }
}
JSON
	( cd "$WORK/$name" && composer install --quiet --no-interaction )
done

cat > "$WORK/run.php" <<'PHP'
<?php
// Load each plugin's autoloader in the order given, the way WordPress includes
// plugin files, then use the logger once.
foreach ( array_slice( $argv, 1 ) as $plugin ) {
	require __DIR__ . "/$plugin/vendor/autoload.php";
}
echo Mai_Logger::VERSION;
PHP

failed=0

for order in "aaa mmm zzz" "zzz mmm aaa" "mmm aaa zzz" "aaa zzz mmm"; do
	# shellcheck disable=SC2086
	got="$( php "$WORK/run.php" $order )"

	if [ "$got" = "9.0.0" ]; then
		echo "  ok   loading $order picks 9.0.0"
	else
		echo "  FAIL loading $order picks $got, expected 9.0.0"
		failed=1
	fi
done

[ "$failed" -eq 0 ] && echo "All checks passed." || echo "FAILED"
exit $failed
