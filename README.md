# debtap

A script for converting Debian `.deb` packages into Arch Linux packages, with a focus on accurate package metadata.

## Usage

```bash
debtap -o output_directory [other_options] package_filename
```

Run `debtap --help` for the available options.

## Changes

![Cache-check fix](debtap-fix.png)

- **Cache-check fix:** Replaced the malformed `ls | grep` cache lookup with explicit checks for `/var/cache/pkgfile/core.files` and `/var/cache/pkgfile/extra.files`.
- **Fix for #110:** Added cleanup for the temporary `namcap-checks`, `namcap-dependencies`, and `namcap-libraries` files before generating `.MTREE` and the final package archive, preventing leftover analysis files from being included in generated packages.

## Testing

Check the Bash syntax and patch formatting:

```bash
bash -n debtap
git diff --check
```

Also test conversion of a `.deb` package without `Depends` or `Pre-Depends`, then inspect the generated archive to verify that the temporary files are not included.
