
#!/usr/bin/env bash
set -Eeuo pipefail

# debtap integration test
# Tests the repository version against the real pacman environment.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_SCRIPT="$SCRIPT_DIR/debtap"
OUTPUT_FILE="/var/cache/debtap/extended-base-packages-list"

PASS=0
FAIL=0

pass() {
    echo "[PASS] $1"
    ((PASS += 1))
}

fail() {
    echo "[FAIL] $1" >&2
    ((FAIL += 1))
}

echo "========================================"
echo " debtap integration test"
echo "========================================"
echo

# 1. Check prerequisites
for command in pacman pactree sudo awk sort comm; do
    if ! command -v "$command" >/dev/null 2>&1; then
        fail "Required command not found: $command"
        exit 1
    fi
done

if [[ ! -f "$SOURCE_SCRIPT" ]]; then
    fail "Repository script not found: $SOURCE_SCRIPT"
    exit 1
fi

pass "Required commands and repository script found"

# 2. Verify repository script syntax
if ! bash -n "$SOURCE_SCRIPT"; then
    fail "Repository script has invalid Bash syntax."
    exit 1
fi

pass "Repository script syntax is valid"

# 3. Check the effective locale
CURRENT_LOCALE="$(locale | sed -n 's/^LC_MESSAGES=//p' | tr -d '"')"

echo "System message locale: $CURRENT_LOCALE"

if [[ "$CURRENT_LOCALE" == "C" || "$CURRENT_LOCALE" == "POSIX" ]]; then
    fail "Integration test requires a non-C system locale."
    exit 1
fi

pass "Non-C system locale detected"

# 4. Get expected direct dependencies independently
EXPECTED_FILE="$(mktemp)"
ACTUAL_FILE="$(mktemp)"
MISSING_FILE="$(mktemp)"

cleanup() {
    rm -f "$EXPECTED_FILE" "$ACTUAL_FILE" "$MISSING_FILE"
}
trap cleanup EXIT

LC_ALL=C pacman -Qi base | awk '
/^Depends On[[:space:]]*:/ {
    sub(/^[^:]*:[[:space:]]*/, "")
    for (i=1; i<=NF; i++) print $i
    in_deps=1
    next
}
in_deps && /^[[:space:]]/ {
    for (i=1; i<=NF; i++) print $i
    next
}
in_deps { exit }
' | sort -u > "$EXPECTED_FILE"

if [[ ! -s "$EXPECTED_FILE" ]]; then
    fail "Could not determine base dependencies."
    exit 1
fi

EXPECTED_COUNT="$(wc -l < "$EXPECTED_FILE")"
pass "Detected $EXPECTED_COUNT direct base dependencies"

# 5. Run the repository version
echo
echo "Running repository version: sudo bash '$SOURCE_SCRIPT' -u"
echo "This may download package metadata and update the debtap cache."
echo

sudo -v

if ! sudo bash "$SOURCE_SCRIPT" -u; then
    fail "Repository debtap -u returned an error."
    exit 1
fi

pass "Repository debtap -u completed successfully"

# 6. Verify generated package list
if ! sudo test -s "$OUTPUT_FILE"; then
    fail "Generated package list is missing or empty."
    exit 1
fi

sudo cat "$OUTPUT_FILE" | sort -u > "$ACTUAL_FILE"

pass "Extended base package list exists and is non-empty"

# 7. Verify every direct dependency is present
comm -23 "$EXPECTED_FILE" "$ACTUAL_FILE" > "$MISSING_FILE"

if [[ -s "$MISSING_FILE" ]]; then
    fail "Some direct dependencies are missing:"
    cat "$MISSING_FILE"
else
    pass "All direct dependencies are present in generated list"
fi

# 8. Summary
echo
echo "========================================"
echo " Test summary"
echo "========================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "Expected direct dependencies: $EXPECTED_COUNT"
echo "Generated unique packages: $(wc -l < "$ACTUAL_FILE")"
echo

if (( FAIL > 0 )); then
    echo "RESULT: FAILED"
    exit 1
fi

echo "RESULT: SUCCESS"
