# State
Updated: 2026-10-03 by Claude (Opus 5.5)

## Now

0.2.0 is released: tagged `v0.2.0` on `main`, which is pushed. It loads through mai-package-loader from `mai-package.php`; `init.php` and `Mai_Logger_Bootstrap` are gone. Needs PHP 8.1.

Consumers on 0.2, committed locally, not pushed: mai-analytics, mai-auth, mai-reactions, mai-sportsdataio, springwire-publish-wp, balloon-juice-plugin.

## Next

mai-publisher gets mai-logger through mai-analytics, so it moves to 0.2 after a mai-analytics release that requires `^0.2`.

## Blocked / waiting on

Mike, for pushing and releasing the consumers.

## Verify

```sh
./tests/coexistence.sh
```

Expect "All checks passed": this copy serves ahead of the old 0.1.2 bootstrap in both load orders.

## Gotchas

- Bump `version` in `mai-package.php` and `Mai_Logger::VERSION` together.
- This repo has only `main`, no `develop`.
