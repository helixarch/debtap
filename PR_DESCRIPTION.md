# Fix locale-dependent base package detection

## Related issue

Fixes the locale-dependent package detection reported in #121.

## Problem

The base package dependency list is extracted from `pacman -Qi base`
using a grep expression that expects the English field name `Depends`.

On systems using another locale, this field name is translated.
Consequently, the extraction can return no dependencies.

Additionally, the original expression only captures the first line
of the dependency list and misses wrapped continuation lines.

## Changes

- Force the `pacman` query to use the C locale.
- Extract the complete dependency list, including wrapped continuation lines.
- Initialize the temporary output file before extraction.
- Add a regression test for the dependency parser.
- Add an integration test that runs the repository version of `debtap`.

## Testing

The following checks passed:

- `bash -n debtap`
- Regression test: `python3 tests/test-base-dependencies.py`
  - 25 dependencies extracted from the multiline fixture.
  - The test extracts and executes the AWK program directly from `debtap`.
- Integration test: `./tests/test-integration.sh`
  - Executed on CachyOS with `de_DE.UTF-8`.
  - `debtap -u` completed successfully using the repository version.
  - 27 direct dependencies detected.
  - All 27 direct dependencies were present in the generated package list.
  - 154 unique packages were present in the generated extended package list.
  - Result: 7 checks passed, 0 failed.

### Integration test notes

The integration test uses the real Pacman environment and runs `debtap -u`.
It requires `pacman`, `pactree`, `sudo`, and network access to synchronize
the package metadata. It updates the local debtap cache under
`/var/cache/debtap`; it does not install or remove system packages.

The integration test invokes the repository script directly, so the
installed AUR version does not need to be replaced.
