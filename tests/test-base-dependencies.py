
#!/usr/bin/env python3
"""Regression tests for debtap's base dependency extraction."""

import re
import subprocess
import sys
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "debtap"

def fail(message):
    print(f"FAIL: {message}")
    sys.exit(1)

source = SCRIPT.read_text()

# Extract the actual AWK program from debtap.
match = re.search(
    r"LC_ALL=C pacman -Qi base 2>/dev/null \| awk '\n(.*?)\n'"
    r" > /var/cache/debtap/base-packages",
    source,
    re.DOTALL,
)

if not match:
    fail("Could not find the patched AWK extraction in debtap.")

awk_program = match.group(1)

if ": > /var/cache/debtap/base-packages" not in source:
    fail("Output file is not explicitly initialized.")

fixture = """\
Name            : base
Version         : 3-3
Depends On      : filesystem gcc-libs glibc bash coreutils file findutils
                  gawk grep procps-ng sed tar gettext pciutils psmisc
                  shadow util-linux bzip2 gzip xz licenses pacman
                  archlinux-keyring systemd systemd-sysvcompat
Optional Deps   : None
Required By     : None
"""

expected = [
    "filesystem", "gcc-libs", "glibc", "bash", "coreutils",
    "file", "findutils", "gawk", "grep", "procps-ng", "sed",
    "tar", "gettext", "pciutils", "psmisc", "shadow",
    "util-linux", "bzip2", "gzip", "xz", "licenses", "pacman",
    "archlinux-keyring", "systemd", "systemd-sysvcompat",
]

result = subprocess.run(
    ["awk", awk_program],
    input=fixture,
    text=True,
    capture_output=True,
)

if result.returncode != 0:
    fail(f"AWK exited with status {result.returncode}: {result.stderr}")

actual = result.stdout.split()

if actual != expected:
    fail(
        "Dependency extraction differs from expected output.\n"
        f"Expected: {expected}\n"
        f"Actual:   {actual}"
    )

print("PASS: All dependencies extracted correctly.")
print(f"PASS: {len(actual)} dependencies found, including wrapped lines.")
print("PASS: Test uses the AWK code extracted directly from debtap.")
